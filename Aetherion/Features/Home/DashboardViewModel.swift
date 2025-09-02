// === File: DashboardViewModel.swift
// Version: 1.1
// Date: 2025-08-30 05:45:00 UTC
// Description: ViewModel for Dashboard, uses Core/Models/Asset.
// Author: K-Cim

import SwiftUI

@MainActor
final class DashboardViewModel: ObservableObject {
    @Published var assets: [Asset] = []   // ← Asset vient de Core/Models/Asset.swift

    /// Load existing assets (placeholder for real storage)
    func load() {
        assets = []
    }

    /// Add a demo asset
    func addSample() {
        let sample = Asset(name: "Document-\(Int.random(in: 1...999))",
                           size: Int.random(in: 1000...9999))
        assets.append(sample)
    }

    /// Delete an asset
    func delete(_ asset: Asset) {
        assets.removeAll { $0.id == asset.id }
    }
}
