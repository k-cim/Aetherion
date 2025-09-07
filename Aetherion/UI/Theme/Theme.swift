// === File: Theme.swift
// Description: Theme model + presets (colors + typography + gradient colors + controlTint)
import SwiftUI

enum ThemeID: String, CaseIterable, Identifiable {
    case aetherionDark
    case aetherionLight
    // ⬇️ nouveaux
    case aetherionBlue
    case aetherionSepia
    case aetherionEmerald

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

        // ⬇️ NOUVEAUX PRÉSETS
        case .aetherionBlue:
            // Bleu profond (texte clair)
            return Theme(
                id: id,
                background: Color(red: 0.06, green: 0.10, blue: 0.20),   // #0F1A33 approx
                foreground: .white,
                secondary: .white.opacity(0.75),
                accent: Color(red: 0.55, green: 0.80, blue: 1.00),       // bleu clair accent
                controlTint: Color(red: 0.55, green: 0.80, blue: 1.00),
                cardStartOpacity: 0.28, cardEndOpacity: 0.10,
                cardStartColor: .white, cardEndColor: .white,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: .white
            )

        case .aetherionSepia:
            // Tons papier / sepia (texte sombre)
            return Theme(
                id: id,
                background: Color(red: 0.96, green: 0.93, blue: 0.86),   // crème
                foreground: Color(red: 0.18, green: 0.15, blue: 0.12),   // brun foncé
                secondary: Color(red: 0.18, green: 0.15, blue: 0.12).opacity(0.7),
                accent: Color(red: 0.60, green: 0.42, blue: 0.24),       // sépia accent
                controlTint: Color(red: 0.60, green: 0.42, blue: 0.24),
                cardStartOpacity: 0.10, cardEndOpacity: 0.03,
                cardStartColor: .black, cardEndColor: .black,
                cornerRadius: 16,
                headerFontSize: 28, headerFontWeight: .bold, headerFontDesign: .rounded,
                headerColor: Color(red: 0.18, green: 0.15, blue: 0.12)
            )

        case .aetherionEmerald:
            // Vert émeraude sombre (texte clair)
            return Theme(
                id: id,
                background: Color(red: 0.02, green: 0.16, blue: 0.12),   // vert très sombre
                foreground: .white,
                secondary: .white.opacity(0.75),
                accent: Color(red: 0.40, green: 0.95, blue: 0.70),       // émeraude vive
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
