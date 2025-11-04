import SwiftUI

struct USStockMarketSummaryView: View {
    @StateObject private var vm = USStockMarketSummaryViewModel()

    var body: some View {
        VStack {
            if vm.isLoading {
                ProgressView("Loading Market Summary...")
                    .padding()
            } else if let error = vm.errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .padding()
            } else {
                List(vm.indices) { quote in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(symbolDisplayName(for: quote.symbol))
                            .font(.headline)

                        HStack {
                            Text("Price:")
                            Spacer()
                            Text("$\(quote.price)")
                        }

                        HStack {
                            Text("Change:")
                            Spacer()
                            Text("\(quote.change) (\(quote.changePercent))")
                                .foregroundColor(quote.change.hasPrefix("-") ? .red : .green)
                        }

                        HStack {
                            Text("Open:")
                            Spacer()
                            Text("$\(quote.open)")
                        }

                        HStack {
                            Text("High:")
                            Spacer()
                            Text("$\(quote.high)")
                        }

                        HStack {
                            Text("Low:")
                            Spacer()
                            Text("$\(quote.low)")
                        }

                        HStack {
                            Text("Volume:")
                            Spacer()
                            Text(quote.volume.formattedWithSeparator())
                        }

                        HStack {
                            Text("Last Updated:")
                            Spacer()
                            Text(quote.latestTradingDay)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
        .navigationTitle("US Stock Market Summary")
        .onAppear {
            vm.fetchIndices()
        }
    }

    private func symbolDisplayName(for symbol: String) -> String {
        switch symbol {
        case "SPY": return "S&P 500 (SPY)"
        case "DIA": return "Dow Jones Industrial (DIA)"
        case "QQQ": return "Nasdaq Composite (QQQ)"
        default: return symbol
        }
    }
}

// Helper to format volume with commas
extension String {
    func formattedWithSeparator() -> String {
        guard let number = Int(self) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? self
    }
}
