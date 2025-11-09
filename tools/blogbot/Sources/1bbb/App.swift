import Foundation
import ArgumentParser

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
        for article in articles {
            try processArticle(article)
        }
    }

    func processArticle(_ article: String) throws {
        // Placeholder for article processing logic.
        print("Processing article: \(article)")
        let articleName = String(article.split(separator: "/").last!)
        let articleDirectory = URL(fileURLWithPath: BUILD_DIR, isDirectory: true).appendingPathComponent(articleName)
        print(articleDirectory)
    }

    func createBuildDirectory() throws {
        let buildDir = URL(fileURLWithPath: BUILD_DIR, isDirectory: true)
        try FileManager.default.createDirectory(at: buildDir, withIntermediateDirectories: true)
    }

    func deleteBuildDirectory() throws {
        let buildDir = URL(fileURLWithPath: BUILD_DIR, isDirectory: true)
        try FileManager.default.removeItem(at: buildDir)
    }

    func getArticles() throws -> [String] {
           // read the lines in the file `articlesFile`
        let fileURL = URL(fileURLWithPath: articlesFile)
        let fileContents = try String(contentsOf: fileURL, encoding: .utf8)
        // create a web url for each line
        return fileContents.split(separator: "\n").map { String($0) }
    }
}
