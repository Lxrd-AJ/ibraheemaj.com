import Foundation
import Subprocess

struct Repository {
    let name: String
    let githubURL: String
    let theme: BlogTheme?
    let articles: [Article]
    var buildDir: String?

    init(config: RepoConfig) {
        self.name = config.name
        self.githubURL = config.repo.absoluteString
        self.theme = config.articleMetadata?.theme

        self.articles = config.notebooks.map({ notebook in 
            return Article(name: notebook)
        })
    }

    mutating func cloned(to directory: String) async throws {
        let gitCloneResult = try await Subprocess.run(
            .name("git"), 
            arguments: ["clone", self.githubURL, directory],
            output: .string(limit: 4096)
        )

        guard gitCloneResult.terminationStatus == .exited(0) else {
            throw AppError.failedToClone(url: self.githubURL)
        }

        self.buildDir = directory
    }
}