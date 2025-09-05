// === File: ThemedHeader.swift
// Version: 1.0
// Date: 2025-08-30
// Description: Reusable top banner (logo + title) with gradient background, consistent across screens.
// Author: K-Cim

import SwiftUI

struct ThemedHeader: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let systemIcon: String?
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            if let systemIcon {
                Image(systemName: systemIcon)
                    .font(.title2.weight(.semibold))
                    .themedForeground(themeManager.theme)
            }

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .themedForeground(themeManager.theme)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 64) // hauteur cohérente avec Accueil
        .background(
            LinearGradient(
                colors: [
                    Color.white.opacity(themeManager.theme.cardStartOpacity),
                    Color.white.opacity(themeManager.theme.cardEndOpacity)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(themeManager.theme.cornerRadius)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
