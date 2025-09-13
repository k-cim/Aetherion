// === File: PrimaryButton.swift
// Version: 1.1
// Date: 2025-08-30 04:45:00 UTC
// Description: Reusable primary button styled according to the active theme.
// Author: K-Cim

// === File: UI/Components/PrimaryButton.swift
import SwiftUI

struct PrimaryButton: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(themeManager.theme.foreground)   // 👈 texte suit le thème
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    // si tu as un style de carte/gradient pour les boutons, garde-le
                    RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.theme.cardStartColor.opacity(themeManager.theme.cardStartOpacity),
                                    themeManager.theme.cardEndColor.opacity(themeManager.theme.cardEndOpacity)
                                ],
                                startPoint: .leading, endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08))
                        )
                )
        }
        .buttonStyle(.plain)
    }
}
