struct ReportEvent: Identifiable, Decodable {
    let id = UUID()
    let category: String
    let description: String
    let latitude: Double
    let longitude: Double
    let timestamp: String
}