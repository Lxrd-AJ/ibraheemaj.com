import Foundation
import ArgumentParser

@main
struct App: AsyncParsableCommand {

    @Option(help: "Path to a Jupyter notebook file to convert")
    public var notebookFile: String

    mutating func run() async throws {
        print("Hello, world!")
        print(notebookFile)
    }
}
