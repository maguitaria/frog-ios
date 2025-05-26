import SwiftUI
import CoreLocation

struct TravelModeView: View {
    @State private var countryCode: String = "US"
    @State private var emergencyData: EmergencyAPIResponse?
    @State private var countryDetails: CountryDetailsResponse?
    @State private var selectedCountry: Country?
    @State private var allCountries: [Country] = []
    @State private var showCountrySelector = false
    @State private var searchText = ""

    private let locationManager = CLLocationManager()

    let languageByISO = [
        "US": "English", "FR": "French", "DE": "German", "FI": "Finnish / Swedish",
        "JP": "Japanese", "BR": "Portuguese", "IN": "Hindi / English"
    ]

    let tipsByISO = [
        "US": "Call 911 for emergencies.",
        "FI": "Dial 112 in Finland – works from any phone.",
        "DE": "112 = fire/ambulance, 110 = police in Germany.",
        "default": "Dial the numbers shown above. 112 works in many countries."
    ]

    let tapWaterSafety: [String: String] = [
        "FI": "Safe to drink from tap",
        "US": "Tap water is generally safe",
        "IN": "Avoid tap water; use bottled",
        "EG": "Not safe from tap; use bottled",
        "BR": "Avoid tap water",
        "JP": "Safe to drink from tap"
    ]

    let vaccinationAdvice: [String: String] = [
        "FI": "No special vaccinations needed",
        "US": "No travel vaccines required",
        "IN": "Recommended: Hepatitis A, Typhoid",
        "EG": "Recommended: Hep A, Typhoid, Rabies",
        "BR": "Recommended: Yellow Fever, Hep A",
        "JP": "Routine vaccines recommended"
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Country picker
                    Button(action: {
                        showCountrySelector = true
                    }) {
                        HStack {
                            Text(selectedCountry?.name ?? "Select Country")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                    .sheet(isPresented: $showCountrySelector) {
                        NavigationView {
                            List {
                                ForEach(allCountries.filter {
                                    searchText.isEmpty || $0.name.localizedCaseInsensitiveContains(searchText)
                                }) { country in
                                    Button(country.name) {
                                        selectedCountry = country
                                        countryCode = country.code
                                        fetchEmergencyInfo(for: country.code)
                                        fetchCountryDetails(for: country.code)
                                        showCountrySelector = false
                                    }
                                }
                            }
                            .navigationTitle("Select Country")
                            .searchable(text: $searchText)
                        }
                    }


                    if let name = countryDetails?.name.common {
                        Text("Travel Info: \(name)")
                            .font(.title3)
                            .bold()
                            .padding(.horizontal)
                    }

                    Group {
                        if let capital = countryDetails?.capital?.first {
                            travelRow("building.columns", "Capital", capital)
                        }
                        if let currency = countryDetails?.currencies?.first?.value.name {
                            travelRow("dollarsign.circle", "Currency", currency)
                        }
                        if let tz = countryDetails?.timezones.first {
                            travelRow("clock", "Timezone", tz)
                        }
                        if let side = countryDetails?.car?.side {
                            travelRow("car.fill", "Drives on", side.capitalized)
                        }
                        if let lang = languageByISO[countryCode] {
                            travelRow("character.book.closed", "Language", lang)
                        }
                    }

                    if let tip = tipsByISO[countryCode] ?? tipsByISO["default"] {
                        travelRow("lightbulb", "Safety Tip", tip)
                    }

                    if let water = tapWaterSafety[countryCode] {
                        travelRow("drop.fill", "Tap Water", water)
                    }

                    if let vax = vaccinationAdvice[countryCode] {
                        travelRow("cross.case.fill", "Vaccinations", vax)
                    }

                    Divider().padding(.vertical)

                    if let data = emergencyData {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Emergency Numbers").font(.headline)
                                .padding(.horizontal)

                            emergencyCard("Police", data.police.all.first)
                            emergencyCard("Fire", data.fire.all.first)
                            emergencyCard("Ambulance", data.ambulance.all.first)
                            emergencyCard("Dispatch", data.dispatch.all.first)
                        }
                        .padding(.horizontal)
                    }

                    Button("Find Embassy Nearby") {
                        let nationality = Locale.current.localizedString(forRegionCode: Locale.current.region?.identifier ?? "US") ?? "your country"
                        let query = "\(nationality) embassy near me".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                        if let url = URL(string: "https://www.google.com/maps/search/\(query)") {
                            UIApplication.shared.open(url)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.top)
            }
            .navigationTitle("Travel Mode")
        }
        .onAppear {
            detectCountry()
            loadAllCountries()
        }
        .onChange(of: selectedCountry) { newValue in
            if let code = newValue?.code {
                fetchEmergencyInfo(for: code)
                fetchCountryDetails(for: code)
                countryCode = code
            }
        }
    }

    func travelRow(_ icon: String, _ label: String, _ value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text("\(label):")
                .fontWeight(.medium)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal)
    }

    func emergencyCard(_ label: String, _ number: String?) -> some View {
        VStack(alignment: .leading) {
            if let number = number, !number.isEmpty {
                HStack {
                    Text("\(label):")
                    Spacer()
                    Button(action: {
                        if let url = URL(string: "tel://\(number)") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        Text(number)
                    }
                }
            } else {
                Text("\(label): Not Available")
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
                    self.selectedCountry = Country(name: iso, code: iso)
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

    func loadAllCountries() {
        self.allCountries = Locale.isoRegionCodes.compactMap {
            guard let name = Locale.current.localizedString(forRegionCode: $0) else { return nil }
            return Country(name: name, code: $0)
        }
    }
}

struct Country: Identifiable, Codable, Hashable {
    var id: String { code }
    let name: String
    let code: String
}
