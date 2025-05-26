//
//  Secrets.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 9.5.2025.
//

import Foundation


struct Secrets {
    static func value(forKey key: String) -> String {
        guard let file = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
              let data = try? Data(contentsOf: file),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] else {
            fatalError("❌ Secrets.plist missing or unreadable")
        }

        guard let value = plist[key] as? String else {
            fatalError("❌ Key \(key) not found in Secrets.plist")
        }

        return value
    }
}
