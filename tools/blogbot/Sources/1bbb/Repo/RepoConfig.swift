import Foundation

enum BlogTheme: String, Codable {
    case computerVision = "computer-vision"
}

struct RepoConfig: Codable {
    let name: String
    let repo: URL
    let notebooks: [NotebookEntry]
    let articleMetadata: ArticleMetadata?
    let defaults: Frontmatter?

    struct ArticleMetadata: Codable {
        let theme: BlogTheme
    }

    struct NotebookEntry: Codable {
        let file: String
        let frontmatter: Frontmatter?
        
        // Flattened structure for convenience in JSON if desired, 
        // but let's stick to explicit mapping or we can use custom decoding.
        // For simplicity, let's assume the JSON has specific fields 
        // that map to Frontmatter, or we can just embed Frontmatter.
        // Let's use a flat structure in JSON for the user, 
        // so we need custom decoding or just duplicate fields.
        // User asked for "minimise duplication".
        // Let's assume JSON looks like:
        // { "file": "a.ipynb", "title": "A", ... }
        // So we need to decode `file` and the rest into `frontmatter`.
        
        let title: String?
        let description: String?
        let pubDate: String?
        let author: String?
        let tags: [String]?
        let image: ImageInfo?
    }
    
    struct Frontmatter: Codable {
        let title: String?
        let description: String?
        let pubDate: String?
        let author: String?
        let tags: [String]?
        let image: ImageInfo?
    }
    
    struct ImageInfo: Codable {
        let url: String
        let alt: String
    }
}