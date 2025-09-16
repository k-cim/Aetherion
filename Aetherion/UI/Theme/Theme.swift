// === File: UI/Theme/Theme.swift
// Version: 1.5
// Date: 2025-09-14 07:18:30 UTC
// Description: Theme model + presets, full Equatable (by value), Codable via RGBA bridge, helpers (equalsPreset, headerFont).
// Author: K-Cim

import SwiftUI

// MARK: - Platform shims
#if canImport(UIKit)
import UIKit
private typealias KCColor = UIColor
#elseif canImport(AppKit)
import AppKit
private typealias KCColor = NSColor
#endif

// MARK: - IDs

/// Source unique des IDs de thèmes
enum ThemeID: String, CaseIterable, Identifiable, Hashable, Codable {
    case aetherionDark
    var id: String { rawValue }
}

// MARK: - Theme

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
}

// MARK: - Presets

extension Theme {
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
                headerFontSize: 28,
                headerFontWeight: .bold,
                headerFontDesign: .rounded,
                headerColor: .white
            )
        }
    }

    /// Tous les presets (utile pour un picker)
    static var allPresets: [Theme] { ThemeID.allCases.map(Self.preset) }
}

// MARK: - Derived

extension Theme {
    var headerFont: Font {
        .system(size: headerFontSize, weight: headerFontWeight, design: headerFontDesign)
    }
}

// MARK: - Equatable (par valeur)

extension Theme: Equatable {
    static func == (lhs: Theme, rhs: Theme) -> Bool {
        lhs.id == rhs.id &&
        lhs.background == rhs.background &&
        lhs.foreground == rhs.foreground &&
        lhs.secondary == rhs.secondary &&
        lhs.accent == rhs.accent &&
        lhs.controlTint == rhs.controlTint &&
        lhs.cardStartOpacity == rhs.cardStartOpacity &&
        lhs.cardEndOpacity == rhs.cardEndOpacity &&
        lhs.cardStartColor == rhs.cardStartColor &&
        lhs.cardEndColor == rhs.cardEndColor &&
        lhs.cornerRadius == rhs.cornerRadius &&
        lhs.headerFontSize == rhs.headerFontSize &&
        lhs.headerFontWeight == rhs.headerFontWeight &&
        lhs.headerFontDesign == rhs.headerFontDesign &&
        lhs.headerColor == rhs.headerColor
    }
}

/// Comparaison au preset d’origine (pour `isCustomized`)
extension Theme {
    var equalsPreset: Bool { self == Theme.preset(self.id) }
}


// MARK: - Codable (via pont RGBA + DTO poids/design)

// SwiftUI.Color n’est pas Codable → on encode en RGBA sRGB.
// Font.Weight / Font.Design ne sont pas Codable → on encode via petits DTO.

extension Theme: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case background, foreground, secondary, accent, controlTint
        case cardStartOpacity, cardEndOpacity, cardStartColor, cardEndColor, cornerRadius
        case headerFontSize, headerFontWeight, headerFontDesign, headerColor
    }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(ThemeID.self, forKey: .id)
        background   = try c.decode(RGBA.self, forKey: .background).color
        foreground   = try c.decode(RGBA.self, forKey: .foreground).color
        secondary    = try c.decode(RGBA.self, forKey: .secondary).color
        accent       = try c.decode(RGBA.self, forKey: .accent).color
        controlTint  = try c.decode(RGBA.self, forKey: .controlTint).color

        cardStartOpacity = try c.decode(Double.self, forKey: .cardStartOpacity)
        cardEndOpacity   = try c.decode(Double.self, forKey: .cardEndOpacity)
        cardStartColor   = try c.decode(RGBA.self, forKey: .cardStartColor).color
        cardEndColor     = try c.decode(RGBA.self, forKey: .cardEndColor).color
        cornerRadius     = try c.decode(CGFloat.self, forKey: .cornerRadius)

        headerFontSize   = try c.decode(CGFloat.self, forKey: .headerFontSize)
        headerFontWeight = try c.decode(FontWeightDTO.self, forKey: .headerFontWeight).weight
        headerFontDesign = try c.decode(FontDesignDTO.self, forKey: .headerFontDesign).design
        headerColor      = try c.decode(RGBA.self, forKey: .headerColor).color
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id, forKey: .id)
        try c.encode(RGBA(background), forKey: .background)
        try c.encode(RGBA(foreground), forKey: .foreground)
        try c.encode(RGBA(secondary),  forKey: .secondary)
        try c.encode(RGBA(accent),     forKey: .accent)
        try c.encode(RGBA(controlTint),forKey: .controlTint)

        try c.encode(cardStartOpacity, forKey: .cardStartOpacity)
        try c.encode(cardEndOpacity,   forKey: .cardEndOpacity)
        try c.encode(RGBA(cardStartColor), forKey: .cardStartColor)
        try c.encode(RGBA(cardEndColor),   forKey: .cardEndColor)
        try c.encode(cornerRadius,     forKey: .cornerRadius)

        try c.encode(headerFontSize,   forKey: .headerFontSize)
        try c.encode(FontWeightDTO(headerFontWeight), forKey: .headerFontWeight)
        try c.encode(FontDesignDTO(headerFontDesign), forKey: .headerFontDesign)
        try c.encode(RGBA(headerColor), forKey: .headerColor)
    }
}

// MARK: - RGBA <-> Color bridge (sRGB)

private struct RGBA: Codable, Equatable {
    var r: CGFloat
    var g: CGFloat
    var b: CGFloat
    var a: CGFloat

    init(_ color: Color) {
        #if canImport(UIKit)
        let ui = KCColor(color)
        var rr: CGFloat = 0, gg: CGFloat = 0, bb: CGFloat = 0, aa: CGFloat = 0
        ui.getRed(&rr, green: &gg, blue: &bb, alpha: &aa)
        self.r = rr; self.g = gg; self.b = bb; self.a = aa
        #elseif canImport(AppKit)
        let ns = KCColor(color)
        let rgb = ns.usingColorSpace(.sRGB) ?? ns
        self.r = rgb.redComponent
        self.g = rgb.greenComponent
        self.b = rgb.blueComponent
        self.a = rgb.alphaComponent
        #else
        self.r = 0; self.g = 0; self.b = 0; self.a = 1
        #endif
    }

    var color: Color { Color(red: r, green: g, blue: b).opacity(a) }
}

// MARK: - Font DTOs

private struct FontWeightDTO: Codable, Equatable {
    let raw: String
    init(_ w: Font.Weight) {
        switch w {
        case .ultraLight: raw = "ultraLight"
        case .thin:       raw = "thin"
        case .light:      raw = "light"
        case .regular:    raw = "regular"
        case .medium:     raw = "medium"
        case .semibold:   raw = "semibold"
        case .bold:       raw = "bold"
        case .heavy:      raw = "heavy"
        case .black:      raw = "black"
        default:          raw = "regular"
        }
    }
    var weight: Font.Weight {
        switch raw {
        case "ultraLight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "regular":    return .regular
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        case "black":      return .black
        default:           return .regular
        }
    }
}

private struct FontDesignDTO: Codable, Equatable {
    let raw: String
    init(_ d: Font.Design) {
        switch d {
        case .default: raw = "default"
        case .serif:   raw = "serif"
        case .rounded: raw = "rounded"
        case .monospaced: raw = "monospaced"
        @unknown default: raw = "default"
        }
    }
    var design: Font.Design {
        switch raw {
        case "serif":      return .serif
        case "rounded":    return .rounded
        case "monospaced": return .monospaced
        default:           return .default
        }
    }
}
