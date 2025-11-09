import Foundation
import ArgumentParser
import Subprocess

let BUILD_DIR = ".build-articles"

@main
struct App: AsyncParsableCommand {

    @Option(help: "Path to a list of articles to process.")
    public var articlesFile: String

    mutating func run() async throws {
        #if DEBUG
        let debugBanner = String(repeating: "*", count: 10)
        print("\(debugBanner) [DEBUG mode] \(debugBanner)")
        try deleteBuildDirectory()
        #endif
        try createBuildDirectory()

        let articles = try getArticles()
        // An optimisation for later is to process articles concurrently.
        for article in articles {
            try await processArticle(article)
        }
    }

    func processArticle(_ article: Article) async throws {
        // Placeholder for article processing logic.
        print("Processing article: \(article)")
        let articleDirectory = URL(fileURLWithPath: BUILD_DIR, isDirectory: true).appendingPathComponent(article.name)
        
        try await article.cloned(to: articleDirectory.path)
        
        print("\t -> Cloned article to: \(articleDirectory.path)")
    }

    func createBuildDirectory() throws {
        let buildDir = URL(fileURLWithPath: BUILD_DIR, isDirectory: true)
        try FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
    }

    func deleteBuildDirectory() throws {
        let buildDir = URL(fileURLWithPath: BUILD_DIR, isDirectory: true)
        try FileManager.default.removeItem(at: buildDir)
    }

    func getArticles() throws -> [Article] {
           // read the lines in the file `articlesFile`
        let fileURL = URL(fileURLWithPath: articlesFile)
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        // create a web url for each line
        return fileContents.split(separator: "\n").map { Article(urlString: String($0)) }
    }
}
