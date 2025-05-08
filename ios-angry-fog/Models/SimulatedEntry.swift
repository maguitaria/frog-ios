//
//  SimulatedEntry.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 8.5.2025.
//


import Foundation

struct SimulatedEntry: Identifiable, Decodable {
    let id = UUID()
    let timestamp: String
    let device: String
    let clipboard: String
}
