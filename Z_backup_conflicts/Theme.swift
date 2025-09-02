// === File: Theme.swift
// Version: 1.1
// Date: 2025-08-30 01:55:00 UTC
// Description: Theme identifiers and concrete theme values (no helpers here).
// Author: K-Cim

import SwiftUI

/// Identifiers for available themes.
enum ThemeID: String, CaseIterable, Identifiable {
    case aetherionDark
    case aetherionLight

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .aetherionDark: return "Aetherion Dark"
        case .aetherionLight: return "Aetherion Light"
        }
    }
}

/// Concrete theme values used by ThemeStyle helpers.
struct Theme {
    let background: Color
    let foreground: Color
    let secondary: Color

    // Card gradient (left → right)
    let cardStartOpacity: Double
    let cardEndOpacity: Double

    // UI metrics
    let cornerRadius: CGFloat

    // Presets
    static let aetherionDark = Theme(
        background: .black,
        foreground: .white,
        secondary: .white.opacity(0.7),
        cardStartOpacity: 0.30,
        cardEndOpacity: 0.10,
        cornerRadius: 12
    )

    static let aetherionLight = Theme(
        background: Color(white: 0.97),
        foreground: .black,
        secondary: .gray,
        cardStartOpacity: 0.30,
        cardEndOpacity: 0.10,
        cornerRadius: 12
    )
}
