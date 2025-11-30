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
            return Article(name: notebook)
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
        let articleMarkdown = self.buildDirectory
            .appendingPathComponent("markdown-builds", isDirectory: true)
            .appendingPathComponent(articleNameWithoutExtension, isDirectory: true)
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
    }
}