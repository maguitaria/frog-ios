//
//  InsightsResponse.swift
//  ios-angry-fog
//
//  Created by Mariia Glushenkova on 8.5.2025.
//


import Foundation

struct InsightsResponse {
    let recent_reports: [ReportEntry]
    let simulated_activity: [SimulatedEntry]
}
