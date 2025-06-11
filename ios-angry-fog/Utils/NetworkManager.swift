import Foundation

class NetworkManager {
    static let baseURL = "https://frog-ios.onrender.com"

    static func postJSON(to endpoint: String, payload: [String: Any]) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            print("❌ Invalid URL: \(endpoint)")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        } catch {
            print("❌ JSON encoding error: \(error.localizedDescription)")
            return
        }

        print("📤 POST to \(endpoint): \(payload)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Status Code: \(httpResponse.statusCode)")
            }

            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                print("📩 Response: \(responseString)")
            }
        }.resume()
    }

    static func getJSON(from endpoint: String, completion: @escaping (Data?) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            print("❌ Invalid GET URL")
            completion(nil)
            return
        }

        print("🔎 GET from: \(url.absoluteString)")

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("❌ GET error: \(error.localizedDescription)")
                completion(nil)
            } else {
                completion(data)
            }
        }.resume()
    }
}
