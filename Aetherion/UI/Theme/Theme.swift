// === File: UI/Theme/Theme.swift
// Description: Theme model + presets (colors + typography + gradient colors + controlTint)

import SwiftUI

// Source unique des IDs de thèmes
enum ThemeID: String, CaseIterable, Identifiable, Hashable {
    case aetherionDark
    case aetherionLight
    case aetherionBlue
    case aetherionSepia
    case aetherionEmerald

    var id: String { rawValue }
}

struct Theme: Identifiable {
    // Couleurs globales
    var id: ThemeID
    var background: Color
    var foreground: Color         // texte principal
    var secondary: Color          // texte secondaire
    var accent: Color             // accent / icônes actives
    var controlTint: Color        // contrôles (toggle, slider, progress, radio)

    // Cartes (dégradé)
    var cardStartOpacity: Double
    var cardEndOpacity: Double
    var cardStartColor: Color
    var cardEndColor: Color
    var cornerRadius: CGFloat

    // Titres d’écran
    var headerFontSize: CGFloat
    var headerFontWeight: Font.Weight
    var headerFontDesign: Font.Design
    var headerColor: Color

    var headerFont: Font {
        .system(size: headerFontSize, weight: headerFontWeight, design: headerFontDesign)
    }

    static func preset(_ id: ThemeID) -> Theme {
        switch id {
        case .aetherionDark:
            return Theme(
                id: id,
                background: .black,
                foreground: .white,
                secondary: .white.opacity(0.7),
                accent: .white.opacity(0.85),
                controlTint: .white.opacity(0.85),
                cardStartOpacity: 0.30, cardEndOpacity: 0.10,
                cardStartColor: .white, cardEndColor: .white,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: .white
            )

        case .aetherionLight:
            return Theme(
                id: id,
                background: .white,
                foreground: .black,
                secondary: .black.opacity(0.7),
                accent: .black.opacity(0.85),
                controlTint: .black.opacity(0.85),
                cardStartOpacity: 0.08, cardEndOpacity: 0.02,
                cardStartColor: .black, cardEndColor: .black,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: .black
            )

        case .aetherionBlue:
            return Theme(
                id: id,
                background: Color(red: 0.06, green: 0.10, blue: 0.20),
                foreground: .white,
                secondary: .white.opacity(0.75),
                accent: Color(red: 0.55, green: 0.80, blue: 1.00),
                controlTint: Color(red: 0.55, green: 0.80, blue: 1.00),
                cardStartOpacity: 0.28, cardEndOpacity: 0.10,
                cardStartColor: .white, cardEndColor: .white,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: .white
            )

        case .aetherionSepia:
            return Theme(
                id: id,
                background: Color(red: 0.96, green: 0.93, blue: 0.86),
                foreground: Color(red: 0.18, green: 0.15, blue: 0.12),
                secondary: Color(red: 0.18, green: 0.15, blue: 0.12).opacity(0.7),
                accent: Color(red: 0.60, green: 0.42, blue: 0.24),
                controlTint: Color(red: 0.60, green: 0.42, blue: 0.24),
                cardStartOpacity: 0.10, cardEndOpacity: 0.03,
                cardStartColor: .black, cardEndColor: .black,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: Color(red: 0.18, green: 0.15, blue: 0.12)
            )

        case .aetherionEmerald:
            return Theme(
                id: id,
                background: Color(red: 0.02, green: 0.16, blue: 0.12),
                foreground: .white,
                secondary: .white.opacity(0.75),
                accent: Color(red: 0.40, green: 0.95, blue: 0.70),
                controlTint: Color(red: 0.40, green: 0.95, blue: 0.70),
                cardStartOpacity: 0.26, cardEndOpacity: 0.10,
                cardStartColor: .white, cardEndColor: .white,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: .white
            )
        }
    }
}

// Equatable manuel : thèmes égaux si même ID
extension Theme: Equatable {
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id
    }
}

