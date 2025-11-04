import Foundation
import Combine

// MARK: - API Response Models

struct AlphaVantageResponse: Codable {
    let metaData: MetaData
    let timeSeriesDaily: [String: TimeSeriesEntry]

    enum CodingKeys: String, CodingKey {
        case metaData = "Meta Data"
        case timeSeriesDaily = "Time Series (Daily)"
    }
}

struct MetaData: Codable {
    let information: String
    let symbol: String
    let lastRefreshed: String

    enum CodingKeys: String, CodingKey {
        case information = "1. Information"
        case symbol = "2. Symbol"
        case lastRefreshed = "3. Last Refreshed"
    }
}

struct TimeSeriesEntry: Codable {
    let open: String
    let high: String
    let low: String
    let close: String
    let volume: String

    enum CodingKeys: String, CodingKey {
        case open = "1. open"
        case high = "2. high"
        case low = "3. low"
        case close = "4. close"
        case volume = "5. volume"
    }
}

// MARK: - ViewModel

class StockMarketViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Closing prices array with date and close value for charting
    @Published var closingPrices: [(date: String, close: Double)] = []
    
    // Metadata
    @Published var lastRefreshed: String = ""
    @Published var symbol: String = ""
    
    // Basic market details
    @Published var latestOpen: Double?
    @Published var latestHigh: Double?
    @Published var latestLow: Double?
    @Published var latestClose: Double?
    @Published var latestVolume: Int?

    private let apiKey = "ZOAM493MV2ZNC56F"  // Replace with your Alpha Vantage API key
    private let symbolForSPY = "SPY"          // Popular US market ETF symbol

    func fetchMarketData() {
        isLoading = true
        errorMessage = nil

        let urlString = "https://www.alphavantage.co/query?function=TIME_SERIES_DAILY&symbol=\(symbolForSPY)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {
                self?.isLoading = false
            }

            if let error = error {
                DispatchQueue.main.async {
                    self?.errorMessage = "Network error: \(error.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self?.errorMessage = "No data received"
                }
                return
            }

            // Uncomment this line to debug actual JSON response:
            // print(String(data: data, encoding: .utf8) ?? "No response")

            do {
                let decoded = try JSONDecoder().decode(AlphaVantageResponse.self, from: data)

                DispatchQueue.main.async {
                    self?.symbol = decoded.metaData.symbol
                    self?.lastRefreshed = decoded.metaData.lastRefreshed

                    // Sort the daily data by date descending (newest first)
                    let sortedData = decoded.timeSeriesDaily.sorted(by: { $0.key > $1.key })

                    // Map to array of date and close price
                    self?.closingPrices = sortedData.compactMap { key, value in
                        if let closeDouble = Double(value.close) {
                            return (date: key, close: closeDouble)
                        }
                        return nil
                    }
                    
                    // Extract the latest day's data for detailed info
                    if let latestEntry = sortedData.first?.value {
                        self?.latestOpen = Double(latestEntry.open)
                        self?.latestHigh = Double(latestEntry.high)
                        self?.latestLow = Double(latestEntry.low)
                        self?.latestClose = Double(latestEntry.close)
                        self?.latestVolume = Int(latestEntry.volume)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self?.errorMessage = "Decoding error: \(error.localizedDescription)"
                }
            }
        }.resume()
    }
}
