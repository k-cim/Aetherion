// === File: VaultViewModel.swift
// Version: 1.0
// Date: 2025-08-30 06:30:00 UTC
// Description: Minimal ViewModel for Vault, placeholder logic.
// Author: K-Cim

import SwiftUI

@MainActor
final class VaultViewModel: ObservableObject {
    @Published var assets: [Asset] = []

    /// Placeholder load (no real logic yet)
    func load() {
        assets = []
    }
}
