//
//  ReportEntry.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 8.5.2025.
//


import Foundation

struct ReportEntry: Identifiable, Decodable {
    let id = UUID()
    let timestamp: String
    let category: String
    let description: String
    let location: String
}
