import Foundation
import Combine

class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var searchText: String = ""
    @Published var suggestions: [String] = []

    private let bookmarksKey = "bookmarkedArticles"

    var filteredArticles: [Article] {
        if searchText.isEmpty {
            return articles
        } else {
            return articles.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                ($0.description?.localizedCaseInsensitiveContains(searchText) ?? false)
            }
        }
    }

    var bookmarkedArticles: [Article] {
        articles.filter { $0.isBookmarked }
    }
    
    var filteredSuggestions: [String] {
        guard !searchText.isEmpty else { return [] }
        return suggestions.filter { $0.hasPrefix(searchText.lowercased()) }
    }

    func fetchNews() {
        let apiKey = "e36e9b7072944a12813bb0bd82303643"
        let urlString = "https://newsapi.org/v2/everything?q=business&language=en&sortBy=publishedAt&pageSize=100&apiKey=\(apiKey)"


        guard let url = URL(string: urlString) else {
            print("❌ Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }

            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("❌ No data received")
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601  // <-- IMPORTANT FIX
                
                let decodedResponse = try decoder.decode(NewsResponse.self, from: data)

                DispatchQueue.main.async {
                    var loadedArticles = decodedResponse.articles

                    // Restore bookmark states
                    let savedURLs = UserDefaults.standard.stringArray(forKey: self.bookmarksKey) ?? []
                    for index in loadedArticles.indices {
                        if savedURLs.contains(loadedArticles[index].url) {
                            loadedArticles[index].isBookmarked = true
                        }
                    }

                    self.articles = loadedArticles
                    self.generateSuggestions(from: loadedArticles)
                }
            } catch {
                print("❌ Decoding error: \(error.localizedDescription)")
            }
        }.resume()
    }

    func generateSuggestions(from articles: [Article]) {
        var wordSet = Set<String>()

        for article in articles {
            let titleWords = article.title
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty }

            let descriptionWords = article.description?
                .components(separatedBy: CharacterSet.alphanumerics.inverted)
                .filter { !$0.isEmpty } ?? []

            wordSet.formUnion(titleWords.map { $0.lowercased() })
            wordSet.formUnion(descriptionWords.map { $0.lowercased() })
        }

        self.suggestions = wordSet.sorted()
    }

    func selectSuggestion(_ suggestion: String) {
        self.searchText = suggestion
    }

    func toggleBookmark(for article: Article) {
        if let index = articles.firstIndex(where: { $0.id == article.id }) {
            articles[index].isBookmarked.toggle()
            saveBookmarks()
        }
    }

    private func saveBookmarks() {
        let bookmarkedURLs = articles.filter { $0.isBookmarked }.map { $0.url }
        UserDefaults.standard.set(bookmarkedURLs, forKey: bookmarksKey)
    }
}
