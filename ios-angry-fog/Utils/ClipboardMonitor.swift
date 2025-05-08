//
//  ClipboardMonitor.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.4.2025.
//


import UIKit
class ClipboardMonitor {
    static func checkClipboardAndSend() {
        let clipboard = UIPasteboard.general.string ?? "Nothing"
        let timestamp = ISO8601DateFormatter().string(from: Date())

        let payload: [String: Any] = [
            "type": "clipboard",
            "content": clipboard,
            "timestamp": timestamp
        ]

        // To send report
        NetworkManager.postJSON(to: "report", payload: [
            "category": "Protest",
            "description": "Loud crowd",
            "location": "60.17, 24.94"
        ])

        // To send location
        NetworkManager.postJSON(to: "location", payload: [
            "latitude": 60.17,
            "longitude": 24.94
        ])

        // To load dashboard (GET with lat/lon manually appended)
        NetworkManager.getJSON(from: "dashboard?lat=60.17&lon=24.94") { data in
            if let data = data {
                print("📊 Dashboard: \(String(data: data, encoding: .utf8) ?? "")")
            }
        }

    }
}
