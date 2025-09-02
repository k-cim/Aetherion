// === File: ShareViewModel.swift
// Version: 1.0
// Date: 2025-08-29 20:45:00 UTC
// Description: ViewModel for ShareView. Handles link generation for sharing.
// Author: K-Cim

import Foundation

@MainActor
final class ShareViewModel: ObservableObject {
    @Published var link: String?   // Holds the generated share link

    func generateLink() {
        link = "https://example.com/share/\(UUID().uuidString.lowercased())"
    }
}
