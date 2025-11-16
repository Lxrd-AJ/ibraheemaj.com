import Foundation
import ArgumentParser
import Subprocess

let BUILD_DIR = ".build-repos"

enum AppError: Error {
    case failedToClone(url: String)
}

@main
struct App: AsyncParsableCommand {

    @Option(help: "Path to a list of repos to process.")
    public var reposFile: String

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
        // Placeholder for repo processing logic.
        print("Processing repo: \(repo.name)")
        let repoDirectory = URL(fileURLWithPath: BUILD_DIR, isDirectory: true).appending(path: repo.name)
        
        try await repo.cloned(to: repoDirectory.path)
        
        print("\t -> Cloned repo to: \(repoDirectory.path)")

        // Might have to add support for repo and ipynb file in repo
    }

    func createBuildDirectory() throws {
        let buildDir = URL(fileURLWithPath: BUILD_DIR, isDirectory: true)
        try FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
    }

    func deleteBuildDirectory() throws {
        let buildDir = URL(fileURLWithPath: BUILD_DIR, isDirectory: true)
        if FileManager.default.fileExists(atPath: buildDir.path()) {
            try FileManager.default.removeItem(at: buildDir)
        }
    }

    func getRepositories() throws -> [Repository] {
           // read the lines in the file `reposFile`
        let fileURL = URL(fileURLWithPath: reposFile)
        let data = try Data(contentsOf: fileURL)
        let configs = try JSONDecoder().decode([RepoConfig].self, from: data)

        return configs.map({ config in
            return Repository(config: config)
        })
    }
}
