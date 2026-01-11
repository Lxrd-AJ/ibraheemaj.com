import BlogBotCore
import ArgumentParser

// @main
struct App: AsyncParsableCommand {
    @Option(help: "Path to a list of repos to process.")
    public var reposFile: String

    @Option(help: "Path to the markdown conversion script.")
    public var conversionScript: String = "tools/convert-notebooks/main.py"

    mutating func run() async throws {
        let runner = BlogBotRunner(reposFile: reposFile, conversionScript: conversionScript)
        try await runner.run()
    }
}
