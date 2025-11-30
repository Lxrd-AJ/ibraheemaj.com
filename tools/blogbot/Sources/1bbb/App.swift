import Foundation
import ArgumentParser
import Subprocess

let BUILD_DIR = URL(fileURLWithPath: ".build-repos", isDirectory: true)

enum AppError: Error {
    case failedToClone(url: String)
    case failedToProcessArticle(name: String)
}

@main
struct App: AsyncParsableCommand {

    @Option(help: "Path to a list of repos to process.")
    public var reposFile: String

    @Option(help: "Path to the markdown conversion script.")
    public var conversionScript: String = "tools/convert-notebooks/main.py"

    mutating func run() async throws {
        #if DEBUG
        let debugBanner = String(repeating: "*", count: 10)
        print("\(debugBanner) [DEBUG mode] \(debugBanner)")
        try deleteBuildDirectory()
        #endif

        try createBuildDirectory()

        let repos = try getRepositories()
        // An optimisation for later is to process repos concurrently.
        for repo in repos {
            try await processRepositories(repo)
        }
    }

    func processRepositories(_ repo: Repository) async throws {
        print("Processing repo: \(repo.name)")
        
        try await repo.clone()
        print("\t -> Cloned repo to: \(repo.buildDirectory)")
        try await repo.processArticles(markdownScript: self.conversionScript)
        print("\t -> Processed \(repo.articles.count) articles.")
    }

    func createBuildDirectory() throws {
        try FileManager.default.createDirectory(at: BUILD_DIR, withIntermediateDirectories: true)
    }

    func deleteBuildDirectory() throws {
        if FileManager.default.fileExists(atPath: BUILD_DIR.path()) {
            try FileManager.default.removeItem(at: BUILD_DIR)
        }
    }

    func getRepositories() throws -> [Repository] {
           // read the lines in the file `reposFile`
        let fileURL = URL(fileURLWithPath: reposFile)
        let data = try Data(contentsOf: fileURL)
        let configs = try JSONDecoder().decode([RepoConfig].self, from: data)

        return configs.map({ config in
            let buildDirectory = BUILD_DIR.appending(path: config.name)
            return Repository(config: config, buildDirectory: buildDirectory)
        })
    }
}
