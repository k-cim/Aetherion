// === File: SettingsOptionRow.swift
// Date: 2025-09-04
// Description: Option row with fixed height for consistency across screens.

import SwiftUI

struct SettingsOptionRow: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let systemIcon: String
    let title: String
    let subtitle: String?
    let showChevron: Bool

    var body: some View {
        ThemedCard(fixedHeight: 64, contentPadding: 14) {   // ← hauteur fixée à 64
            HStack(spacing: 12) {
                Image(systemName: systemIcon)
                    .font(.title3.weight(.semibold))
                    .themedSecondary(themeManager.theme)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline.bold())
                        .themedForeground(themeManager.theme)

                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .themedSecondary(themeManager.theme)
                    }
                }

                Spacer()

                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .themedSecondary(themeManager.theme)
                        .opacity(0.6)
                }
            }
        }
    }
}
