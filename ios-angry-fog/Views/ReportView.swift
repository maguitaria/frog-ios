import SwiftUI
import CoreLocation

struct ReportView: View {
    @StateObject private var locationHelper = LocationHelper()
    @State private var reportText = ""
    @State private var category = "Protest"
    @State private var status = ""

    let categories = ["Protest", "Police Block", "Medical Aid Needed", "Other"]

    var body: some View {
        Form {
            Section(header: Text("Category")) {
                Picker("Type", selection: $category) {
                    ForEach(categories, id: \.self) {
                        Text($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }

            Section(header: Text("Description")) {
                TextField("What is happening?", text: $reportText)
            }

            Button("Send Report") {
                sendReport()
            }

            if !status.isEmpty {
                Text(status).foregroundColor(.green)
            }
        }
    }

    func sendReport() {
        let location = locationHelper.lastKnownLocation
        let locString = location.map { "\($0.coordinate.latitude),\($0.coordinate.longitude)" } ?? "unknown"

        let payload: [String: Any] = [
            "category": category,
            "description": reportText,
            "location": locString
        ]

        NetworkManager.postJSON(to: "incidents", payload: payload)
        status = "✅ Report submitted"
        reportText = ""
    }
}
