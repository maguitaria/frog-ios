
import SwiftUI
import CoreLocation


struct TravelModeView: View {
    @State private var countryCode: String = "US"
    @State private var emergencyData: EmergencyAPIResponse?
    @State private var countryDetails: CountryDetailsResponse?
    @State private var error: String?
    private let locationManager = CLLocationManager()

    let languageByISO = [
        "US": "English", "FR": "French", "DE": "German", "FI": "Finnish / Swedish",
        "UA": "Ukrainian", "JP": "Japanese", "CN": "Mandarin", "IT": "Italian"
    ]

    let tipsByISO = [
        "US": "Call 911 for emergencies.",
        "FI": "Dial 112 in Finland – works from any phone.",
        "DE": "112 = fire/ambulance, 110 = police in Germany.",
        "default": "Dial the number shown above. 112 works in many countries."
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let name = countryDetails?.name.common {
                    Text("🌍 Travel Mode: \(name) (\(countryCode))")
                        .font(.title2)
                        .bold()
                        .padding(.bottom, 10)
                }

                Group {
                    if let capital = countryDetails?.capital?.first {
                        Label("Capital: \(capital)", systemImage: "building.columns")
                    }
                    if let currency = countryDetails?.currencies?.first?.value.name {
                        Label("Currency: \(currency)", systemImage: "dollarsign.circle")
                    }
                    if let tz = countryDetails?.timezones.first {
                        Label("Timezone: \(tz)", systemImage: "clock")
                    }
                    if let side = countryDetails?.car?.side {
                        Label("Drives on: \(side.capitalized)", systemImage: "car.fill")
                    }
                }

                if let lang = languageByISO[countryCode] {
                    Label("Language: \(lang)", systemImage: "character.book.closed")
                }

                if let tip = tipsByISO[countryCode] ?? tipsByISO["default"] {
                    Text("📝 \(tip)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .padding(.vertical, 8)
                }

                Divider().padding(.vertical, 4)

                if let data = emergencyData {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("☎️ Emergency Contacts").font(.headline)
                        emergencyCard("Police", data.police.all.first)
                        emergencyCard("Fire", data.fire.all.first)
                        emergencyCard("Ambulance", data.ambulance.all.first)
                        emergencyCard("Dispatch", data.dispatch.all.first)
                    }
                }

                Divider()

                Text("💡 Local Tips")
                    .font(.headline)

                Text("🚱 Tap water safety: Unknown – ask locals or avoid unless labeled safe.")
                Text("📶 Roaming tip: Local prepaid SIMs are often cheaper than roaming abroad.")
                    .padding(.bottom, 10)

                Button("🛂 Find Embassy Nearby") {
                    let nationality = Locale.current.localizedString(forRegionCode: Locale.current.region?.identifier ?? "US") ?? "your country"
                    let query = "\(nationality) embassy near me".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                    if let url = URL(string: "https://www.google.com/maps/search/\(query)") {
                        UIApplication.shared.open(url)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("Travel Mode")
        .onAppear {
            detectCountry()
        }
    }

    func emergencyCard(_ label: String, _ number: String?) -> some View {
        VStack(alignment: .leading) {
            if let number = number, !number.isEmpty {
                HStack {
                    Text("• \(label):")
                    Spacer()
                    Button(action: {
                        if let url = URL(string: "tel://\(number)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Label(number, systemImage: "phone.fill")
                            .foregroundColor(.blue)
                    }
                }
            } else {
                Text("• \(label): ❌ Not Available")
                    .foregroundColor(.gray)
            }
        }
    }

    func detectCountry() {
        locationManager.requestWhenInUseAuthorization()
        if let location = locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                if let iso = placemarks?.first?.isoCountryCode {
                    self.countryCode = iso
                    fetchEmergencyInfo(for: iso)
                    fetchCountryDetails(for: iso)
                }
            }
        }
    }

    func fetchEmergencyInfo(for code: String) {
        let urlString = "https://emergencynumberapi.com/api/country/\(code)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                let wrapper = try JSONDecoder().decode(EmergencyAPIWrapper.self, from: data)
                DispatchQueue.main.async {
                    self.emergencyData = wrapper.data
                }
            } catch {
                print("❌ Emergency decode error: \(error)")
            }
        }.resume()
    }

    func fetchCountryDetails(for code: String) {
        let urlString = "https://restcountries.com/v3.1/alpha/\(code)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            do {
                if let decoded = try JSONDecoder().decode([CountryDetailsResponse].self, from: data).first {
                    DispatchQueue.main.async {
                        self.countryDetails = decoded
                    }
                }
            } catch {
                print("❌ Country detail decode error: \(error)")
            }
        }.resume()
    }
}
