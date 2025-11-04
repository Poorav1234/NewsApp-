import Foundation

class Summarizer {
    // Your OpenAI API key (embed carefully; consider security for production)
    let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""

//    private let apiKey = "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"

    /// Simplifies and summarizes given text for 10th-grade level understanding.
    /// - Parameters:
    ///   - text: The input text to simplify.
    ///   - completion: Completion handler with simplified text or nil if failed.
    func simplifyText(_ text: String, completion: @escaping (String?) -> Void) {
        let systemMessage = "You rewrite financial news headlines in simple, clear language for 10th graders."
        let userMessage = """
        Simplify this financial news so a 10th grader can understand:
        \"\"
        \(text)
        \"\"
        """




        let body: [String: Any] = [
            "model": "gpt-4o", // or "gpt-3.5-turbo"
            "messages": [
                ["role": "system", "content": "You rewrite financial news headlines in simple, clear language for 10th graders."],
                ["role": "user", "content": userMessage]
            ],
            "temperature": 0.3
        ]
        
        // API URL
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            print("Invalid OpenAI API URL")
            completion(nil)
            return
        }

        // Setup request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        // Encode JSON body
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        } catch {
            print("Failed to encode JSON body: \(error.localizedDescription)")
            completion(nil)
            return
        }

        // Perform API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("OpenAI request error: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data else {
                print("No data received from OpenAI")
                completion(nil)
                return
            }

            // Parse response JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                print("OpenAI JSON response: \(json)")

                if let jsonDict = json as? [String: Any],
                   let choices = jsonDict["choices"] as? [[String: Any]],
                   let message = choices.first?["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(content.trimmingCharacters(in: .whitespacesAndNewlines))
                } else {
                    print("Unexpected OpenAI response format")
                    completion(nil)
                }

            } catch {
                print("Failed to decode OpenAI response: \(error.localizedDescription)")
                completion(nil)
            }
        }.resume()
    }
}
