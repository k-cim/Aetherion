// === File: AeTheme.swift
// Date: 2025-08-30
// Description: Minimal theme types (neutral names to avoid conflicts)

import SwiftUI

/// Neutral ID to avoid name collisions with existing code.
enum AeThemeID: String, Codable {
    case dark
    case light
}

/// Minimal, conflict-free theme struct (does not depend on other files).
struct AeThemeStyle: Equatable {
    var id: AeThemeID
    var background: Color
    var foreground: Color
    var cardStartOpacity: Double
    var cardEndOpacity: Double
    var cornerRadius: CGFloat

    static func preset(_ id: AeThemeID) -> AeThemeStyle {
        switch id {
        case .dark:
            return AeThemeStyle(id: .dark,
                                background: .black,
                                foreground: .white,
                                cardStartOpacity: 0.30,
                                cardEndOpacity: 0.10,
                                cornerRadius: 12)
        case .light:
            return AeThemeStyle(id: .light,
                                background: .white,
                                foreground: .black,
                                cardStartOpacity: 0.20,
                                cardEndOpacity: 0.05,
                                cornerRadius: 12)
        }
    }

    func withCardGradient(startOpacity: Double, endOpacity: Double) -> AeThemeStyle {
        var copy = self
        copy.cardStartOpacity = startOpacity
        copy.cardEndOpacity   = endOpacity
        return copy
    }
}
