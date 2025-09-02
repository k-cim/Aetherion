// === File: DashboardViewModel.swift
// Version: 1.0
// Date: 2025-08-30 05:20:00 UTC
// Description: ViewModel for Dashboard, manages asset list (sample/demo data).
// Author: K-Cim

import SwiftUI

/// A minimal model for demo purposes
struct Asset: Identifiable {
    let id = UUID()
    let name: String
    let size: Int
}

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var assets: [Asset] = []

    /// Load existing assets (for now: clear or mock data)
    func load() {
        // In a real app: load from StorageService
        assets = []
    }

    /// Add a demo asset
    func addSample() {
        let sample = Asset(name: "Document-\(Int.random(in: 1...999))", size: Int.random(in: 1000...9999))
        assets.append(sample)
    }

    /// Delete an asset
    func delete(_ asset: Asset) {
        assets.removeAll { $0.id == asset.id }
    }
}
