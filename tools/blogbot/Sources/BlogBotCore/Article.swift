import Foundation

public struct Article {
    public let name: String
    public let frontmatter: RepoConfig.Frontmatter

    public init(name: String, frontmatter: RepoConfig.Frontmatter) {
        self.name = name
        self.frontmatter = frontmatter
    }
}