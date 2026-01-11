import Foundation

public enum BlogTheme: String, Codable {
    case computerVision = "computer-vision"
}

public struct RepoConfig: Codable {
    public let name: String
    public let repo: URL
    public let notebooks: [NotebookEntry]
    public let articleMetadata: ArticleMetadata?
    public let defaults: Frontmatter?

    public init(name: String, repo: URL, notebooks: [NotebookEntry], articleMetadata: ArticleMetadata? = nil, defaults: Frontmatter? = nil) {
        self.name = name
        self.repo = repo
        self.notebooks = notebooks
        self.articleMetadata = articleMetadata
        self.defaults = defaults
    }

    public struct ArticleMetadata: Codable {
        public let theme: BlogTheme
        
        public init(theme: BlogTheme) {
            self.theme = theme
        }
    }

    public struct NotebookEntry: Codable {
        public let file: String
        public let frontmatter: Frontmatter?
        
        public let title: String?
        public let description: String?
        public let pubDate: String?
        public let author: String?
        public let tags: [String]?
        public let image: ImageInfo?
        
        public init(file: String, title: String? = nil, description: String? = nil, pubDate: String? = nil, author: String? = nil, tags: [String]? = nil, image: ImageInfo? = nil) {
            self.file = file
            self.frontmatter = nil
            self.title = title
            self.description = description
            self.pubDate = pubDate
            self.author = author
            self.tags = tags
            self.image = image
        }
    }
    
    public struct Frontmatter: Codable {
        public let title: String?
        public let description: String?
        public let pubDate: String?
        public let author: String?
        public let tags: [String]?
        public let image: ImageInfo?
        
        public init(title: String? = nil, description: String? = nil, pubDate: String? = nil, author: String? = nil, tags: [String]? = nil, image: ImageInfo? = nil) {
            self.title = title
            self.description = description
            self.pubDate = pubDate
            self.author = author
            self.tags = tags
            self.image = image
        }
    }
    
    public struct ImageInfo: Codable {
        public let url: String
        public let alt: String
        
        public init(url: String, alt: String) {
            self.url = url
            self.alt = alt
        }
    }
}