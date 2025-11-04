import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var suggestions: [String]
    var onSelectSuggestion: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                TextField("Search news...", text: $text)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .submitLabel(.search)
                    // Optional: handle "return" key pressed
                    .onSubmit {
                        onSelectSuggestion(text)
                    }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .cornerRadius(10)

            if !suggestions.isEmpty && !text.isEmpty {
                VStack(alignment: .leading, spacing: 0) {
                    // Limit suggestions count to max 4
                    ForEach(suggestions.prefix(4), id: \.self) { suggestion in
                        Button(action: {
                            onSelectSuggestion(suggestion)
                        }) {
                            Text(suggestion)
                                .foregroundColor(.primary)
                                .padding(.vertical, 8)
                                .padding(.horizontal)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                        }
                        .buttonStyle(PlainButtonStyle())
                        Divider()
                    }
                }
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 4)
                .padding(.top, 4)
            }
        }
        .padding(.horizontal)
    }
}
