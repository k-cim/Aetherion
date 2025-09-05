// === File: ThemePersistence.swift
// Description: UserDefaults-based persistence for theme colors & gradient opacities.

import SwiftUI

final class ThemePersistence {
    static let shared = ThemePersistence()
    private init() {}

    private let ud = UserDefaults.standard

    // MARK: - Keys
    private enum Key {
        // Background
        static let backgroundColor = "theme.backgroundColor"

        // Card gradient opacities
        static let cardStartOpacity = "theme.card.startOpacity"
        static let cardEndOpacity   = "theme.card.endOpacity"

        // Card gradient colors
        static let cardStartColor   = "theme.card.startColor"
        static let cardEndColor     = "theme.card.endColor"

        // Text colors
        static let headerColor      = "theme.text.headerColor"
        static let primaryText      = "theme.text.primary"
        static let secondaryText    = "theme.text.secondary"

        // Icons & controls
        static let iconColor        = "theme.icon.color"
        static let controlTint      = "theme.control.tint"
    }

    // MARK: - Generic Color save/load (stores RGBA as dictionary)
    private func saveColor(_ color: Color, forKey key: String) {
        let rgba = color.rgba
        let dict: [String: Double] = ["r": rgba.r, "g": rgba.g, "b": rgba.b, "a": rgba.a]
        ud.set(dict, forKey: key)
    }

    private func loadColor(forKey key: String, default defaultColor: Color) -> Color {
        guard let dict = ud.dictionary(forKey: key) as? [String: Double],
              let r = dict["r"], let g = dict["g"], let b = dict["b"], let a = dict["a"]
        else { return defaultColor }
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    // MARK: - Background
    func saveBackgroundColor(_ color: Color) {
        saveColor(color, forKey: Key.backgroundColor)
    }
    func loadBackgroundColor(default def: Color) -> Color {
        loadColor(forKey: Key.backgroundColor, default: def)
    }

    // MARK: - Card gradient (opacities)
    func saveCardGradient(start: Double, end: Double) {
        ud.set(start, forKey: Key.cardStartOpacity)
        ud.set(end,   forKey: Key.cardEndOpacity)
    }
    func loadCardGradient(defaultStart: Double, defaultEnd: Double) -> (Double, Double) {
        let s = ud.object(forKey: Key.cardStartOpacity) as? Double ?? defaultStart
        let e = ud.object(forKey: Key.cardEndOpacity)   as? Double ?? defaultEnd
        return (s, e)
    }

    // MARK: - Card gradient (colors)
    func saveCardGradientColors(start: Color, end: Color) {
        saveColor(start, forKey: Key.cardStartColor)
        saveColor(end,   forKey: Key.cardEndColor)
    }
    func loadCardGradientColors(defaultStart: Color, defaultEnd: Color) -> (Color, Color) {
        let s = loadColor(forKey: Key.cardStartColor, default: defaultStart)
        let e = loadColor(forKey: Key.cardEndColor,   default: defaultEnd)
        return (s, e)
    }

    // MARK: - Texts
    func saveHeaderColor(_ color: Color) {
        saveColor(color, forKey: Key.headerColor)
    }
    func loadHeaderColor(default def: Color) -> Color {
        loadColor(forKey: Key.headerColor, default: def)
    }

    func savePrimaryTextColor(_ color: Color) {
        saveColor(color, forKey: Key.primaryText)
    }
    func loadPrimaryTextColor(default def: Color) -> Color {
        loadColor(forKey: Key.primaryText, default: def)
    }

    func saveSecondaryTextColor(_ color: Color) {
        saveColor(color, forKey: Key.secondaryText)
    }
    func loadSecondaryTextColor(default def: Color) -> Color {
        loadColor(forKey: Key.secondaryText, default: def)
    }

    // MARK: - Icons & controls
    func saveIconColor(_ color: Color) {
        saveColor(color, forKey: Key.iconColor)
    }
    func loadIconColor(default def: Color) -> Color {
        loadColor(forKey: Key.iconColor, default: def)
    }

    func saveControlTint(_ color: Color) {
        saveColor(color, forKey: Key.controlTint)
    }
    func loadControlTint(default def: Color) -> Color {
        loadColor(forKey: Key.controlTint, default: def)
    }
}

// MARK: - Color → RGBA helper
private extension Color {
    /// Extracts sRGB components; falls back to white if not representable.
    var rgba: (r: Double, g: Double, b: Double, a: Double) {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 1, g: CGFloat = 1, b: CGFloat = 1, a: CGFloat = 1
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (Double(r), Double(g), Double(b), Double(a))
        } else {
            return (1, 1, 1, 1)
        }
        #else
        return (1, 1, 1, 1)
        #endif
    }
}
