// === File: ThemePersistence.swift
// Version: 1.0
// Date: 2025-08-30
// Description: Save & load theme values (background color & card gradient) from UserDefaults.
// Author: K-Cim

import SwiftUI

final class ThemePersistence {
    static let shared = ThemePersistence()
    private init() {}

    private let bgR = "aetherion_bg_r"
    private let bgG = "aetherion_bg_g"
    private let bgB = "aetherion_bg_b"
    private let bgA = "aetherion_bg_a"

    private let cardStartKey = "aetherion_card_start_opacity"
    private let cardEndKey   = "aetherion_card_end_opacity"

    func saveBackgroundColor(_ color: Color) {
        let ui = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, &g, &b, &a) {
            UserDefaults.standard.set(r, forKey: bgR)
            UserDefaults.standard.set(g, forKey: bgG)
            UserDefaults.standard.set(b, forKey: bgB)
            UserDefaults.standard.set(a, forKey: bgA)
        }
    }

    func loadBackgroundColor(default fallback: Color = .black) -> Color {
        let ud = UserDefaults.standard
        guard ud.object(forKey: bgR) != nil,
              ud.object(forKey: bgG) != nil,
              ud.object(forKey: bgB) != nil else {
            return fallback
        }
        let r = ud.double(forKey: bgR)
        let g = ud.double(forKey: bgG)
        let b = ud.double(forKey: bgB)
        let a = ud.object(forKey: bgA) != nil ? ud.double(forKey: bgA) : 1.0
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }

    func saveCardGradient(start: Double, end: Double) {
        UserDefaults.standard.set(start, forKey: cardStartKey)
        UserDefaults.standard.set(end,   forKey: cardEndKey)
    }

    func loadCardGradient(defaultStart: Double, defaultEnd: Double) -> (Double, Double) {
        let ud = UserDefaults.standard
        let start = ud.object(forKey: cardStartKey) != nil ? ud.double(forKey: cardStartKey) : defaultStart
        let end   = ud.object(forKey: cardEndKey)   != nil ? ud.double(forKey: cardEndKey)   : defaultEnd
        return (start, end)
    }
}
