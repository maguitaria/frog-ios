import SwiftUI

struct ReportView: View {
    @State private var reportText = ""
    @State private var category = "Protest"
    @State private var status = ""
    @StateObject private var locationHelper = LocationHelper()
    let categories = ["Protest", "Police Block", "Medical Aid Needed", "Other"]

    var body: some View {
        Form {
            Section(header: Text("Category")) {
                Picker("Type", selection: $category) {
                    ForEach(categories, id: \.self) { item in
                        Text(item)
                    }
                }
            }

            Section(header: Text("Description")) {
                TextField("What is happening?", text: $reportText)
            }

            Button("Send Report") {
                sendReport()
            }

            Text(status)
                .foregroundColor(.green)
        }
        .onAppear {
            locationHelper.requestPermission()
            }
    }

    // MARK: - Report Submission Logic
    func sendReport() {
        guard let url = URL(string: "https://frog-ios-xm5a.onrender.com/report") else {
            status = "❌ Invalid URL"
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let latitude = locationHelper.lastKnownLocation?.coordinate.latitude ?? 0.0
        let longitude = locationHelper.lastKnownLocation?.coordinate.longitude ?? 0.0
        let town = locationHelper.lastKnownTown ?? "Unknown"

        let payload: [String: Any] = [
            "category": category,
            "description": reportText,
            "location": "\(latitude), \(longitude)",
            "town": town
        ]
        

        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async {
                status = "✅ Report submitted"
                reportText = ""
            }
        }.resume()
    }
}

