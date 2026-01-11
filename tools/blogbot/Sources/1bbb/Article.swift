import Foundation

struct Article {
    let name: String
    let frontmatter: RepoConfig.Frontmatter

    init(name: String, frontmatter: RepoConfig.Frontmatter) {
        self.name = name
        self.frontmatter = frontmatter
    }
}