import SwiftUI

struct NewsCardView: View {
    let article: Article
    let onBookmarkToggle: (Article) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            if let imageUrl = article.urlToImage, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(12)
                    case .failure:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }
            
            Text(article.title)
                .font(.headline)
                .lineLimit(3)
                .padding(.top, 8)
            
            if let description = article.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .padding(.top, 2)
            }
            
            HStack {
                Text(formatDate(article.publishedAt))  // <-- Now passing Date directly
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Button(action: {
                    onBookmarkToggle(article)
                }) {
                    Image(systemName: article.isBookmarked ? "bookmark.fill" : "bookmark")
                        .foregroundColor(article.isBookmarked ? .blue : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 180)
            .overlay(
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .foregroundColor(.gray)
            )
            .cornerRadius(12)
    }
    
    // Updated function: input is Date, not String
    func formatDate(_ date: Date) -> String {
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: date)
    }
}
