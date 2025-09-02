// === File: ThemeManager.swift
// Version: 1.3
// Date: 2025-08-30 04:15:00 UTC
// Description: Observable theme manager with live updates, persistence (UserDefaults) and rollback.
// Author: K-Cim

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {
    @Published private(set) var themeID: ThemeID
    @Published private(set) var theme: Theme

    // Keeps previous theme to allow rollback/reset to "before changes"
    private var rollbackTheme: Theme?

    init(default id: ThemeID = .aetherionDark) {
        self.themeID = id
        if let saved = ThemeManager.loadTheme(for: id) {
            self.theme = saved
        } else {
            self.theme = ThemeManager.theme(for: id)
        }
    }

    func setTheme(_ id: ThemeID) {
        self.themeID = id
        if let saved = ThemeManager.loadTheme(for: id) {
            self.theme = saved
        } else {
            self.theme = ThemeManager.theme(for: id)
        }
        // New theme selected → reset rollback
        rollbackTheme = nil
    }

    func toggle() {
        setTheme(themeID == .aetherionDark ? .aetherionLight : .aetherionDark)
    }

    private static func theme(for id: ThemeID) -> Theme {
        switch id {
        case .aetherionDark: return .aetherionDark
        case .aetherionLight: return .aetherionLight
        }
    }

    // MARK: - Live update (not persisted)
    func liveUpdateCardGradient(startOpacity: Double, endOpacity: Double) {
        if rollbackTheme == nil { rollbackTheme = theme } // store "before" state once
        self.theme = Theme(
            background: theme.background,
            foreground: theme.foreground,
            secondary: theme.secondary,
            cardStartOpacity: startOpacity,
            cardEndOpacity: endOpacity,
            cornerRadius: theme.cornerRadius
        )
    }

    // MARK: - Apply (persist to cache)
    func applyCardGradient(startOpacity: Double, endOpacity: Double) {
        self.theme = Theme(
            background: theme.background,
            foreground: theme.foreground,
            secondary: theme.secondary,
            cardStartOpacity: startOpacity,
            cardEndOpacity: endOpacity,
            cornerRadius: theme.cornerRadius
        )
        rollbackTheme = nil
        ThemeManager.saveTheme(theme, for: themeID)
    }

    // MARK: - Reset (rollback to previous, or preset if none)
    func resetCardGradient() {
        if let rollback = rollbackTheme {
            self.theme = rollback
            rollbackTheme = nil
        } else {
            let preset = ThemeManager.theme(for: themeID)
            self.theme = preset
            ThemeManager.saveTheme(preset, for: themeID)
        }
    }

    // MARK: - Persistence
    private static func saveTheme(_ theme: Theme, for id: ThemeID) {
        let dict: [String: Any] = [
            "cardStartOpacity": theme.cardStartOpacity,
            "cardEndOpacity": theme.cardEndOpacity
        ]
        UserDefaults.standard.set(dict, forKey: "theme_\(id.rawValue)")
    }

    private static func loadTheme(for id: ThemeID) -> Theme? {
        guard let dict = UserDefaults.standard.dictionary(forKey: "theme_\(id.rawValue)") else {
            return nil
        }
        let base = theme(for: id)
        let start = dict["cardStartOpacity"] as? Double ?? base.cardStartOpacity
        let end   = dict["cardEndOpacity"] as? Double ?? base.cardEndOpacity
        return Theme(
            background: base.background,
            foreground: base.foreground,
            secondary: base.secondary,
            cardStartOpacity: start,
            cardEndOpacity: end,
            cornerRadius: base.cornerRadius
        )
    }
}
