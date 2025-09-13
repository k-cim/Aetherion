// === File: SettingsRow.swift
// Version: 1.0
// Date: 2025-08-30 05:15:00 UTC
// Description: Reusable settings row with icon, title, subtitle, and optional disabled style.
// Author: K-Cim

import SwiftUI

struct SettingsRow: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let icon: String
    let title: String
    let subtitle: String
    var disabled: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(themeManager.theme.secondary)
                .opacity(disabled ? 0.4 : 1.0)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline.weight(.bold))   // plus gros + bold
                    .foregroundStyle(themeManager.theme.foreground)
                    .opacity(disabled ? 0.5 : 1.0)
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(themeManager.theme.secondary)
                    .opacity(disabled ? 0.5 : 0.8)
            }

            Spacer()

            if !disabled {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(themeManager.theme.secondary)
                    .opacity(0.5)
            }
        }
        .contentShape(Rectangle())
    }
}
