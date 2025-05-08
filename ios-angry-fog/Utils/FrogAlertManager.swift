//
//  FrogAlertManager.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 7.5.2025.
//


import SwiftUI
import Combine

class FrogAlertManager: ObservableObject {
    static let shared = FrogAlertManager()

    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""

    private init() {}

    func trigger(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        showAlert = true
        print("🐸 Alert: \(title) - \(message)")
    }
}
