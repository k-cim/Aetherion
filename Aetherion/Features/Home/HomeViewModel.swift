// === File: HomeViewModel.swift
// Version: 1.0
// Date: 2025-08-30 05:25:00 UTC
// Description: ViewModel for the Home screen, manages simple state and error messages.
// Author: K-Cim

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    /// Simulate loading some startup data
    func load() {
        isLoading = true
        errorMessage = nil

        Task {
            try? await Task.sleep(nanoseconds: 800_000_000) // simulate work
            if Bool.random() {
                errorMessage = "An error occurred while loading."
            }
            isLoading = false
        }
    }

    /// Reset error
    func clearError() {
        errorMessage = nil
    }
}
