import Foundation
import Subprocess

struct Repository {
    let name: String
    let githubURL: String
    let theme: BlogTheme?
    let articles: [Article]
    var buildDirectory: URL

    init(config: RepoConfig, buildDirectory: URL) {
        self.name = config.name
        self.githubURL = config.repo.absoluteString
        self.theme = config.articleMetadata?.theme

        self.articles = config.notebooks.map({ notebook in 
            // Merge defaults and specific fields
            let title = notebook.title ?? config.defaults?.title
            let description = notebook.description ?? config.defaults?.description
            let pubDate = notebook.pubDate ?? config.defaults?.pubDate
            let author = notebook.author ?? config.defaults?.author
            let tags = (config.defaults?.tags ?? []) + (notebook.tags ?? [])
            let image = notebook.image ?? config.defaults?.image
            
            let mergedFrontmatter = RepoConfig.Frontmatter(
                title: title,
                description: description,
                pubDate: pubDate,
                author: author,
                tags: tags.isEmpty ? nil : tags,
                image: image
            )
            
            return Article(name: notebook.file, frontmatter: mergedFrontmatter)
        })

        self.buildDirectory = buildDirectory
    }

    func clone() async throws {
        let gitCloneResult = try await Subprocess.run(
            .name("git"), 
            arguments: ["clone", self.githubURL, self.buildDirectory.path()],
            output: .string(limit: 4096)
        )

        guard gitCloneResult.terminationStatus == .exited(0) else {
            throw AppError.failedToClone(url: self.githubURL)
        }
    }

    func processArticles(markdownScript conversionScript: String) async throws {
        for (idx, article) in articles.enumerated() {
            print("\t -> [\(idx+1)/\(self.articles.count)] Processing article: \(article.name)")
            try await processArticle(article, using: conversionScript)
        }
    }

    private func processArticle(_ article: Article, using script: String) async throws {
        let articleNotebook = self.buildDirectory
            .appendingPathComponent(article.name, isDirectory: false)
        let articleNameWithoutExtension = articleNotebook
            .deletingPathExtension()
            .lastPathComponent
        let articleMarkdownDir = self.buildDirectory
            .appendingPathComponent("markdown-builds", isDirectory: true)
            .appendingPathComponent(articleNameWithoutExtension, isDirectory: true)
            
        // Ensure directory exists
        try FileManager.default.createDirectory(at: articleMarkdownDir, withIntermediateDirectories: true)
            
        let articleMarkdown = articleMarkdownDir
            .appendingPathComponent(articleNameWithoutExtension, isDirectory: false)
            .appendingPathExtension("md")
            
        let processCommand = try await Subprocess.run(
            .name("uv"),
            arguments: [
                "run",
                "--script",
                script,
                articleNotebook.path(),
                articleMarkdown.path()
            ],
            output: .string(limit: 4096)
        )

        #if(DEBUG)
        if let output = processCommand.standardOutput {
            print("Command Output:\n \(output)")
        }
        #endif

        guard processCommand.terminationStatus == .exited(0) else {
            throw AppError.failedToProcessArticle(name: article.name)
        }
        
        // Inject Frontmatter
        try injectFrontmatter(article.frontmatter, into: articleMarkdown)
    }
    
    private func injectFrontmatter(_ frontmatter: RepoConfig.Frontmatter, into fileURL: URL) throws {
        var content = try String(contentsOf: fileURL, encoding: .utf8)
        
        var yamlLines = ["---"]
        if let title = frontmatter.title { yamlLines.append("title: '\(title)'") }
        if let pubDate = frontmatter.pubDate { yamlLines.append("pubDate: \(pubDate)") }
        if let desc = frontmatter.description { yamlLines.append("description: '\(desc)'") }
        if let author = frontmatter.author { yamlLines.append("author: '\(author)'") }
        
        if let image = frontmatter.image {
            yamlLines.append("image:")
            yamlLines.append("    url: '\(image.url)'")
            yamlLines.append("    alt: '\(image.alt)'")
        }
        
        if let tags = frontmatter.tags {
            // Simple JSON serialization for array
            let tagsString = tags.map { "\"\($0)\"" }.joined(separator: ", ")
            yamlLines.append("tags: [\(tagsString)]")
        }
        
        yamlLines.append("---\n\n")
        
        let yamlHeader = yamlLines.joined(separator: "\n")
        content = yamlHeader + content
        
        try content.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}