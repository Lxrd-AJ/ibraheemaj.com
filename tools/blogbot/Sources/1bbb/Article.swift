import Foundation
import Subprocess

enum ArticleError: Error {
    case failedToClone(url: String)
}


struct Article {
    let url: String
    let name: String

    init(urlString: String) {
        self.url = urlString
        self.name = String(self.url.split(separator: "/").last!)
    }

    var description: String {
        return url
    }

    func cloned(to directory: String) async throws {
        let gitCloneResult = try await Subprocess.run(
            .name("git"), 
            arguments: ["clone", self.url, directory],
            output: .string(limit: 4096)
        )

        guard gitCloneResult.terminationStatus == .exited(0) else {
            throw ArticleError.failedToClone(url: self.url)
        }
    }
}