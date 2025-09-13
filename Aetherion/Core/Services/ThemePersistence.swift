// === File: ThemePersistence.swift
// Minimal shim to keep legacy calls compiling. All loads return provided defaults.
// All saves are no-ops. We now persist only the ThemeID via ThemeStorage.

import SwiftUI

final class ThemePersistence {
    static let shared = ThemePersistence()
    private init() {}

    // MARK: - Loads (pass-through to defaults)

    func loadBackgroundColor(default value: Color) -> Color { value }
    func loadPrimaryTextColor(default value: Color) -> Color { value }
    func loadSecondaryTextColor(default value: Color) -> Color { value }
    func loadIconColor(default value: Color) -> Color { value }
    func loadControlTint(default value: Color) -> Color { value }
    func loadHeaderColor(default value: Color) -> Color { value }

    func loadCardGradient(defaultStart: Double, defaultEnd: Double) -> (Double, Double) {
        (defaultStart, defaultEnd)
    }

    func loadCardGradientColors(defaultStart: Color, defaultEnd: Color) -> (Color, Color) {
        (defaultStart, defaultEnd)
    }

    // MARK: - Saves (deprecated → no-op)

    func saveBackgroundColor(_ color: Color) {}
    func savePrimaryTextColor(_ color: Color) {}
    func saveSecondaryTextColor(_ color: Color) {}
    func saveIconColor(_ color: Color) {}
    func saveControlTint(_ color: Color) {}
    func saveHeaderColor(_ color: Color) {}

    func saveCardGradient(start: Double, end: Double) {}
    func saveCardGradientColors(start: Color, end: Color) {}
}
