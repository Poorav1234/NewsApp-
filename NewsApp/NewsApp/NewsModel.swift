import Foundation

struct NewsResponse: Codable {
    let articles: [Article]
}

struct Article: Codable, Identifiable {
    var id: String { url }
    let title: String
    let description: String?
    let url: String
    let urlToImage: String?
    let publishedAt: Date  // <-- Date type

    var simplifiedTitle: String?
    var simplifiedDescription: String?
    var isBookmarked: Bool = false

    private enum CodingKeys: String, CodingKey {
        case title, description, url, urlToImage, publishedAt
    }
}
