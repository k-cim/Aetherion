// === File: ThemeManager.swift
// Version: 1.4
// Date: 2025-08-30
// Description: Central theme store: manages selected Theme, background color live/persistent, card gradient.
// Author: K-Cim

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    // Selected base theme
    @Published var theme: Theme

    // Live background color (affects ThemedScreen)
    @Published var backgroundColor: Color

    // Keep defaults for reset
    private let defaultTheme: Theme
    private let defaultBackground: Color

    // Init
    init(default id: ThemeID) {
        // Base theme from presets
        var t = Theme.preset(id)

        // Load persisted card gradient (if any)
        let (start, end) = ThemePersistence.shared.loadCardGradient(
            defaultStart: t.cardStartOpacity,
            defaultEnd: t.cardEndOpacity
        )
        t.cardStartOpacity = start
        t.cardEndOpacity   = end

        self.theme = t
        self.defaultTheme = t

        // Background color: persisted or preset background
        let persistedBG = ThemePersistence.shared.loadBackgroundColor(default: t.background)
        self.backgroundColor = persistedBG
        self.defaultBackground = t.background
    }

    // MARK: - Background color controls

    func updateBackgroundColor(_ color: Color) {
        // Live update only (no persistence yet)
        self.backgroundColor = color
    }

    func applyBackgroundColor(_ color: Color) {
        self.backgroundColor = color
        ThemePersistence.shared.saveBackgroundColor(color)
    }

    func resetBackgroundColor() {
        self.backgroundColor = defaultBackground
        ThemePersistence.shared.saveBackgroundColor(defaultBackground)
    }

    // MARK: - Card gradient controls (ThemeConfigView)

    func liveUpdateCardGradient(startOpacity: Double, endOpacity: Double) {
        theme.cardStartOpacity = startOpacity
        theme.cardEndOpacity   = endOpacity
    }

    func applyCardGradient(startOpacity: Double, endOpacity: Double) {
        theme.cardStartOpacity = startOpacity
        theme.cardEndOpacity   = endOpacity
        ThemePersistence.shared.saveCardGradient(start: startOpacity, end: endOpacity)
    }

    func resetCardGradient() {
        theme.cardStartOpacity = defaultTheme.cardStartOpacity
        theme.cardEndOpacity   = defaultTheme.cardEndOpacity
        ThemePersistence.shared.saveCardGradient(start: theme.cardStartOpacity, end: theme.cardEndOpacity)
    }
}
