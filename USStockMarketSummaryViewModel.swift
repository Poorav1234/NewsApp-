import Foundation
import Combine

class USStockMarketSummaryViewModel: ObservableObject {
    @Published var indices: [GlobalQuote] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiKey = "ZOAM493MV2ZNC56F" // Replace with your actual API key
    private let symbols = ["SPY", "DIA", "QQQ"]  // ETFs for S&P 500, Dow Jones, Nasdaq

    func fetchIndices() {
        isLoading = true
        errorMessage = nil
        indices = []

        let group = DispatchGroup()

        for symbol in symbols {
            group.enter()
            fetchGlobalQuote(for: symbol) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let quote):
                        self?.indices.append(quote)
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) { [weak self] in
            self?.isLoading = false
        }
    }

    private func fetchGlobalQuote(for symbol: String, completion: @escaping (Result<GlobalQuote, Error>) -> Void) {
        let urlString = "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=\(symbol)&apikey=\(apiKey)"

        guard let url = URL(string: urlString) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            do {
                let decoded = try JSONDecoder().decode(GlobalQuoteResponse.self, from: data)
                completion(.success(decoded.globalQuote))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
