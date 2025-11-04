import SwiftUI

struct NewsDetailView: View {
    let article: Article
    let onBookmarkToggle: (Article) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()
                            .cornerRadius(10)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 220)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                }

                Text(article.title)
                    .font(.title2)
                    .bold()

                if let description = article.description {
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                }

                Link("🔗 Read Full Article", destination: URL(string: article.url)!)
                    .padding(.top)
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 40)  // adds 20 points padding on left and right
            .padding(.top, 16)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                onBookmarkToggle(article)
            } label: {
                Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                    .foregroundColor(article.isBookmarked ? .blue : .gray)
            }
        }
    }
}
