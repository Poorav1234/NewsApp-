import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NewsViewModel()
    @State private var showStockMarket = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar with autocomplete suggestions
                SearchBar(
                    text: $viewModel.searchText,
                    suggestions: viewModel.suggestions.filter {
                        $0.lowercased().hasPrefix(viewModel.searchText.lowercased())
                    },
                    onSelectSuggestion: { suggestion in
                        viewModel.selectSuggestion(suggestion)
                    }
                )
                .padding(.top)
                .padding(.horizontal)

                // News list
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.filteredArticles) { article in
                            NavigationLink(
                                destination: NewsDetailView(article: article, onBookmarkToggle: { article in
                                    viewModel.toggleBookmark(for: article)
                                })
                            ) {
                                NewsCardView(article: article, onBookmarkToggle: { article in
                                    viewModel.toggleBookmark(for: article)
                                })
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("💸 FinForm")
            .toolbar {
                // Bookmarks Button
                NavigationLink(destination: BookmarksView(bookmarkedArticles: viewModel.bookmarkedArticles, onBookmarkToggle: { article in
                    viewModel.toggleBookmark(for: article)
                })) {
                    Image(systemName: "bookmark.fill")
                        .font(.title2)
                }

                // Stock Market Button — shows modal sheet
                Button {
                    showStockMarket = true
                } label: {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                }
                .accessibilityLabel("Show US Stock Market Summary")
            }
            .sheet(isPresented: $showStockMarket) {
                NavigationView {
                    StockMarketView()
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Close") {
                                    showStockMarket = false
                                }
                            }
                        }
                }
            }
            .onAppear {
                viewModel.fetchNews()
            }
        }
    }
}
