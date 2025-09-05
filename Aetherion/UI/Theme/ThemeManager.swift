// === File: ThemeManager.swift
import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {

    @Published var theme: Theme
    @Published var backgroundColor: Color

    private let persistence = ThemePersistence.shared

    init(default id: ThemeID) {
        let t = Theme.preset(id)
        self.theme = t

        // Background
        let fallbackBG: Color = (id == .aetherionDark) ? .black : .white
        self.backgroundColor = persistence.loadBackgroundColor(default: fallbackBG)

        // Opacités du dégradé (déjà persistées)
        let (startOpacity, endOpacity) = persistence.loadCardGradient(
            defaultStart: t.cardStartOpacity,
            defaultEnd:   t.cardEndOpacity
        )
        self.theme.cardStartOpacity = startOpacity
        self.theme.cardEndOpacity   = endOpacity

        // Couleurs du dégradé (nouveau)
        let (startColor, endColor) = persistence.loadCardGradientColors(
            defaultStart: t.cardStartColor,
            defaultEnd:   t.cardEndColor
        )
        self.theme.cardStartColor = startColor
        self.theme.cardEndColor   = endColor

        // Textes (nouveau)
        self.theme.headerColor = persistence.loadHeaderColor(default: t.headerColor)
        self.theme.foreground  = persistence.loadPrimaryTextColor(default: t.foreground)
        self.theme.secondary   = persistence.loadSecondaryTextColor(default: t.secondary)

        // Icônes & contrôles (nouveau)
        self.theme.accent      = persistence.loadIconColor(default: t.accent)
        self.theme.controlTint = persistence.loadControlTint(default: t.controlTint)
    }

    func applyTheme(_ id: ThemeID) {
        // On repart d’un preset propre…
        let base = Theme.preset(id)
        self.theme = base

        // …mais on garde ce qui est déjà persistant côté utilisateur
        self.backgroundColor = persistence.loadBackgroundColor(default: (id == .aetherionDark ? .black : .white))

        let (s, e) = persistence.loadCardGradient(defaultStart: base.cardStartOpacity, defaultEnd: base.cardEndOpacity)
        theme.cardStartOpacity = s; theme.cardEndOpacity = e

        let (sc, ec) = persistence.loadCardGradientColors(defaultStart: base.cardStartColor, defaultEnd: base.cardEndColor)
        theme.cardStartColor = sc; theme.cardEndColor = ec

        theme.headerColor = persistence.loadHeaderColor(default: base.headerColor)
        theme.foreground  = persistence.loadPrimaryTextColor(default: base.foreground)
        theme.secondary   = persistence.loadSecondaryTextColor(default: base.secondary)

        theme.accent      = persistence.loadIconColor(default: base.accent)
        theme.controlTint = persistence.loadControlTint(default: base.controlTint)
    }

    // MARK: - Updates + persistence

    func updateBackgroundColor(_ color: Color) {
        backgroundColor = color
        persistence.saveBackgroundColor(color)
    }

    func updateCardGradient(start: Double, end: Double) {
        theme.cardStartOpacity = start
        theme.cardEndOpacity   = end
        persistence.saveCardGradient(start: start, end: end)
    }

    func updateGradientColors(start: Color, end: Color) {
        theme.cardStartColor = start
        theme.cardEndColor   = end
        persistence.saveCardGradientColors(start: start, end: end) // NEW
    }

    func updateHeaderColor(_ color: Color) {
        theme.headerColor = color
        persistence.saveHeaderColor(color) // NEW
    }

    func updatePrimaryTextColor(_ color: Color) {
        theme.foreground = color
        persistence.savePrimaryTextColor(color) // NEW
    }

    func updateSecondaryTextColor(_ color: Color) {
        theme.secondary = color
        persistence.saveSecondaryTextColor(color) // NEW
    }

    func updateIconColor(_ color: Color) {
        theme.accent = color
        persistence.saveIconColor(color) // NEW
    }

    func updateControlTint(_ color: Color) {
        theme.controlTint = color
        persistence.saveControlTint(color) // NEW
    }
}
