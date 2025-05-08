//
//  CountryDetailsResponse.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 8.5.2025.
//


struct CountryDetailsResponse: Decodable {
    struct CurrencyInfo: Decodable {
        let name: String
    }

    let name: Name
    let capital: [String]?
    let currencies: [String: CurrencyInfo]?
    let timezones: [String]
    let car: Car?

    struct Name: Decodable {
        let common: String
    }

    struct Car: Decodable {
        let side: String?
    }
}
