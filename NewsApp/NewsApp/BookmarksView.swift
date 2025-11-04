import SwiftUI

struct BookmarksView: View {
    let bookmarkedArticles: [Article]
    let onBookmarkToggle: (Article) -> Void
    
    var body: some View {
        List {
            if bookmarkedArticles.isEmpty {
                Text("No bookmarks yet.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ForEach(bookmarkedArticles) { article in
                    NavigationLink(destination: NewsDetailView(article: article, onBookmarkToggle: onBookmarkToggle)) {
                        NewsCardView(article: article, onBookmarkToggle: onBookmarkToggle)
                    }
                }
            }
        }
        .navigationTitle("Bookmarks")
    }
}
