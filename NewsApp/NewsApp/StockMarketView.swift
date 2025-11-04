import SwiftUI

struct StockMarketView: View {
    @StateObject private var stockVM = StockMarketViewModel()
    @StateObject private var summaryVM = USStockMarketSummaryViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // MARK: Sensex Chart Section
                VStack(spacing: 8) {
                    if stockVM.isLoading {
                        ProgressView("Loading market data...")
                            .padding()
                    } else if let error = stockVM.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        Text("S&P 500 ETF (\(stockVM.symbol))")
                            .font(.title2)
                            .bold()

                        Text("Last refreshed: \(stockVM.lastRefreshed)")
                            .font(.caption)
                            .foregroundColor(.gray)

                        if !stockVM.closingPrices.isEmpty {
                            LineChartView(dataPoints: stockVM.closingPrices)
                                .frame(height: 200)
                                .padding()
                        } else {
                            Text("No price data available")
                        }
                    }
                }
                .padding()

                Divider()

                // MARK: US Stock Market Summary Section
                VStack(alignment: .leading) {
                    Text("US Market Summary")
                        .font(.title3)
                        .bold()
                        .padding(.horizontal)

                    if summaryVM.isLoading {
                        ProgressView("Loading Market Summary...")
                            .padding()
                    } else if let error = summaryVM.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        ForEach(summaryVM.indices) { quote in
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
                            .padding()
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .navigationTitle("Stock Market")
        .onAppear {
            stockVM.fetchMarketData()
            summaryVM.fetchIndices()
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

struct LineChartView: View {
    let dataPoints: [(date: String, close: Double)]

    private var maxPrice: Double {
        dataPoints.map { $0.close }.max() ?? 1
    }

    private var minPrice: Double {
        dataPoints.map { $0.close }.min() ?? 0
    }

    var body: some View {
        GeometryReader { geo in
            let height = geo.size.height
            let width = geo.size.width
            let pointsCount = dataPoints.count
            let stepX = width / CGFloat(pointsCount - 1)

            Path { path in
                for index in dataPoints.indices {
                    let x = CGFloat(index) * stepX
                    let normalizedY = CGFloat((dataPoints[index].close - minPrice) / (maxPrice - minPrice))
                    let y = height - (normalizedY * height)

                    if index == 0 {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }
            .stroke(Color.blue, lineWidth: 2)

            ForEach(dataPoints.indices, id: \.self) { index in
                let x = CGFloat(index) * stepX
                let normalizedY = CGFloat((dataPoints[index].close - minPrice) / (maxPrice - minPrice))
                let y = height - (normalizedY * height)

                Circle()
                    .fill(Color.blue)
                    .frame(width: 6, height: 6)
                    .position(x: x, y: y)
            }
        }
    }
}

// Helper to format volume numbers
extension String {
    func formattedWithCommaSeparator() -> String {
        guard let number = Int(self) else { return self }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: number)) ?? self
    }
}

