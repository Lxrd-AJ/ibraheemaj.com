import Foundation

enum BlogTheme: String, Codable {
    case computerVision = "computer-vision"
}

struct RepoConfig: Codable {
    let name: String
    let repo: URL
    let notebooks: [String]
    let articleMetadata: ArticleMetadata?

    struct ArticleMetadata: Codable {
        let theme: BlogTheme
    }
}