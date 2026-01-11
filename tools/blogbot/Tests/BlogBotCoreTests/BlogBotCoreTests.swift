import Testing
import Foundation
@testable import BlogBotCore

struct BlogBotCoreTests {

    @Test func testRepoConfigDecoding() throws {
        let json = """
        {
            "name": "test-repo",
            "repo": "https://github.com/test/repo",
            "articleMetadata": {
                "theme": "computer-vision"
            },
            "defaults": {
                "author": "Default Author",
                "tags": ["default-tag"]
            },
            "notebooks": [
                {
                    "file": "notebook1.ipynb",
                    "title": "Notebook 1"
                },
                {
                    "file": "notebook2.ipynb",
                    "author": "Specific Author",
                    "tags": ["specific-tag"]
                }
            ]
        }
        """.data(using: .utf8)!

        let config = try JSONDecoder().decode(RepoConfig.self, from: json)
        
        #expect(config.name == "test-repo")
        #expect(config.notebooks.count == 2)
        #expect(config.defaults?.author == "Default Author")
    }

    @Test func testRepositoryMetadataMerging() throws {
        let notebooks = [
            RepoConfig.NotebookEntry(file: "n1.ipynb", title: "N1"),
            RepoConfig.NotebookEntry(file: "n2.ipynb", author: "Auth2", tags: ["tag2"])
        ]
        
        let defaults = RepoConfig.Frontmatter(
            author: "DefAuth",
            tags: ["defTag"]
        )
        
        let config = RepoConfig(
            name: "repo",
            repo: URL(string: "https://example.com")!,
            notebooks: notebooks,
            defaults: defaults
        )
        
        let repo = Repository(config: config, buildDirectory: URL(fileURLWithPath: "/tmp"))
        
        // Check first article (defaults used)
        let a1 = repo.articles[0]
        #expect(a1.frontmatter.title == "N1")
        #expect(a1.frontmatter.author == "DefAuth")
        #expect(a1.frontmatter.tags == ["defTag"])
        
        // Check second article (override/merge)
        let a2 = repo.articles[1]
        #expect(a2.frontmatter.author == "Auth2")
        // Tags are concatenated: defaults + specific
        #expect(a2.frontmatter.tags == ["defTag", "tag2"])
    }
    
    @Test func testFrontmatterInjection() throws {
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("md")
        try "# Initial Content".write(to: fileURL, atomically: true, encoding: .utf8)
        
        let frontmatter = RepoConfig.Frontmatter(
            title: "My Title",
            pubDate: "2023-01-01",
            author: "Me",
            tags: ["a", "b"]
        )
        
        let repo = Repository(
            config: RepoConfig(name: "r", repo: URL(string: "http://a")!, notebooks: []), 
            buildDirectory: URL(fileURLWithPath: "/tmp")
        )
        
        try repo.injectFrontmatter(frontmatter, into: fileURL)
        
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        
        #expect(content.contains("title: 'My Title'"))
        #expect(content.contains("pubDate: 2023-01-01"))
        #expect(content.contains("tags: [\"a\", \"b\"]"))
        #expect(content.contains("# Initial Content"))
        
        try FileManager.default.removeItem(at: fileURL)
    }
}
