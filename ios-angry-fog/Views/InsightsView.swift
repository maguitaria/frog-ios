import SwiftUI



struct InsightsView: View {
    @State private var insights: InsightsResponse?
    @State private var errorText: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("📈 Activity Insights")
                    .font(.largeTitle)
                    .padding(.top)

                if let insights = insights {
                    Section(header: Text("🧾 Recent Reports").bold()) {
                        ForEach(insights.recent_reports) { report in
                            VStack(alignment: .leading) {
                                Text("📍 \(report.category)")
                                    .bold()
                                Text(report.description)
                                Text(report.timestamp)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.bottom, 6)
                        }
                    }

                    Divider()

                    Section(header: Text("🧪 Simulated Data Access").bold()) {
                        ForEach(insights.simulated_activity) { entry in
                            VStack(alignment: .leading) {
                                Text("📱 \(entry.device)")
                                Text("📋 \(entry.clipboard)")
                                Text(entry.timestamp)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(.bottom, 6)
                        }
                    }
                } else if let errorText = errorText {
                    Text("❌ \(errorText)").foregroundColor(.red)
                } else {
                    ProgressView("Loading insights...")
                }
            }
            .padding()
        }
        .onAppear(perform: loadInsights)
    }

    func loadInsights() {
        let base = NetworkManager.baseURL

        let group = DispatchGroup()
        var reports: [ReportEntry] = []
        var simulated: [SimulatedEntry] = []

        group.enter()
        NetworkManager.getJSON(from: "reports") { data in
            if let data = data {
                reports = (try? JSONDecoder().decode([ReportEntry].self, from: data)) ?? []
            }
            group.leave()
        }

        group.enter()
        NetworkManager.getJSON(from: "simulated") { data in
            if let data = data {
                simulated = (try? JSONDecoder().decode([SimulatedEntry].self, from: data)) ?? []
            }
            group.leave()
        }

        group.notify(queue: .main) {
            self.insights = InsightsResponse(recent_reports: reports, simulated_activity: simulated)
        }
    }
}
