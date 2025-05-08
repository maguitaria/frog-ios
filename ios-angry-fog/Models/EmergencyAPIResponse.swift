struct EmergencyAPIWrapper: Decodable {
    let data: EmergencyAPIResponse
}

struct EmergencyAPIResponse: Decodable {
    struct Country: Decodable {
        let name: String
        let ISOCode: String
    }

    struct Service: Decodable {
        let all: [String]
    }

    let country: Country
    let ambulance: Service
    let fire: Service
    let police: Service
    let dispatch: Service
}
