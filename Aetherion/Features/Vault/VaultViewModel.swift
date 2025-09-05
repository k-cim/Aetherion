// === File: VaultViewModel.swift
// Date: 2025-08-30
// Description: View model for Vault screen, loading Assets from StorageService.

import Foundation

@MainActor
final class VaultViewModel: ObservableObject {
    @Published var assets: [Asset] = []

    func load() {
        assets = StorageService.listAssets()
    }
}
