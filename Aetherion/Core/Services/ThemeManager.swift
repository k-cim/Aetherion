ThemeManager.swift
// === File: ThemeManager.swift
// Date: 2025-08-30
// Description: ObservableObject managing current theme + live updates.
// Author: K-Cim

import SwiftUI

final class ThemeManager: ObservableObject {
    @Published private(set) var theme: ThemeStyle
    @Published var themeID: ThemeID
    @Published var accentColor: Color = .blue   // used by UI previews

    init(default id: ThemeID) {
        self.themeID = id
        self.theme   = ThemeStyle.from(id: id)
    }

    func setTheme(_ id: ThemeID) {
        themeID = id
        theme   = ThemeStyle.from(id: id)
    }

    func liveUpdateCardGradient(startOpacity: Double, endOpacity: Double) {
        theme = theme.withCardGradient(startOpacity: startOpacity, endOpacity: endOpacity)
    }

    func applyCardGradient(startOpacity: Double, endOpacity: Double) {
        theme = theme.withCardGradient(startOpacity: startOpacity, endOpacity: endOpacity)
        // TODO: persist if needed (UserDefaults)
    }

    func resetCardGradient() {
        theme = ThemeStyle.from(id: themeID)
    }

    func setAccentColor(_ c: Color) {
        accentColor = c
        // TODO: persist if needed (UserDefaults)
    }
}
