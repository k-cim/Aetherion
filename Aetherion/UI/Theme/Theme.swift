// === File: Theme.swift
// Description: Theme model + presets (colors + typography + gradient colors + controlTint)
import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable {
    case aetherionDark
    case aetherionLight
    var id: String { rawValue }
}

struct Theme {
    // Couleurs globales
    var id: ThemeID
    var background: Color
    var foreground: Color         // texte principal
    var secondary: Color          // texte secondaire (sous-titres, infos)
    var accent: Color             // accent / icônes actives
    var controlTint: Color        // NEW: contrôles (toggle, slider, progress, radio)

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
                controlTint: .white.opacity(0.85),   // NEW
                cardStartOpacity: 0.30,
                cardEndOpacity: 0.10,
                cardStartColor: .white,
                cardEndColor: .white,
                cornerRadius: 16,
                headerFontSize: 28,
                headerFontWeight: .bold,
                headerFontDesign: .rounded,
                headerColor: .white
            )
        case .aetherionLight:
            return Theme(
                id: id,
                background: .white,
                foreground: .black,
                secondary: .black.opacity(0.7),
                accent: .black.opacity(0.85),
                controlTint: .black.opacity(0.85),   // NEW
                cardStartOpacity: 0.08,
                cardEndOpacity: 0.02,
                cardStartColor: .black,
                cardEndColor: .black,
                cornerRadius: 16,
                headerFontSize: 28,
                headerFontWeight: .bold,
                headerFontDesign: .rounded,
                headerColor: .black
            )
        }
    }
}
