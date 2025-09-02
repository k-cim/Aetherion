// === File: Theme.swift
// Version: 1.0
// Date: 2025-08-30
// Description: ThemeID and Theme model with presets.
// Author: K-Cim

import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable {
    case aetherionDark
    case aetherionLight

    var id: String { rawValue }
}

struct Theme {
    var id: ThemeID
    var background: Color
    var foreground: Color
    var secondary: Color
    var cardStartOpacity: Double
    var cardEndOpacity: Double
    var cornerRadius: CGFloat

    static func preset(_ id: ThemeID) -> Theme {
        switch id {
        case .aetherionDark:
            return Theme(
                id: id,
                background: .black,
                foreground: .white,
                secondary: .white.opacity(0.7),
                cardStartOpacity: 0.30,
                cardEndOpacity: 0.10,
                cornerRadius: 16
            )
        case .aetherionLight:
            return Theme(
                id: id,
                background: .white,
                foreground: .black,
                secondary: .black.opacity(0.7),
                cardStartOpacity: 0.08,
                cardEndOpacity: 0.02,
                cornerRadius: 16
            )
        }
    }
}
