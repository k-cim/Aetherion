// === File: ThemedModifiers.swift
// Version: 1.0
// Date: 2025-08-30 04:35:00 UTC
// Description: Reusable view modifiers to apply theme consistently (background, color scheme, lists, toolbars).
// Author: K-Cim

import SwiftUI

/// A container that applies the current theme background and color scheme to its content.
struct ThemedScreen<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        ZStack {
            ThemeStyle.screenBackground(themeManager.theme)
            content()
        }
        // Keep UI consistently dark/light depending on theme choice
        .preferredColorScheme(themeManager.themeID == .aetherionDark ? .dark : .light)
        // Make nav bars adopt screen background
        .toolbarBackground(themeManager.theme.background, for: .navigationBar)
        .toolbarColorScheme(themeManager.themeID == .aetherionDark ? .dark : .light, for: .navigationBar)
    }
}

/// Helpers to strip default List/Form backgrounds so the theme shows through.
extension View {
    /// Hide default scroll backgrounds (List, Form) and use insetGrouped style by default.
    func themedListAppearance() -> some View {
        self
            .scrollContentBackground(.hidden)
            .listStyle(.insetGrouped)
    }

    /// Apply themed foreground color to typical text.
    func themedForeground(_ theme: Theme) -> some View {
        self.foregroundStyle(ThemeStyle.foreground(theme))
    }

    /// Apply themed secondary color to secondary text/icons.
    func themedSecondary(_ theme: Theme) -> some View {
        self.foregroundStyle(ThemeStyle.secondary(theme))
    }
}
