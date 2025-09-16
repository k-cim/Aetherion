// === File: UI/Components/PrimaryButton.swift
// Version: 2.1
// Date: 2025-09-14
// Description: Themed primary button — ButtonStyle + wrapper for title/action.
// Author: K-Cim

import SwiftUI

// MARK: - Style réutilisable
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        StyleView(configuration: configuration)
    }

    private struct StyleView: View {
        @EnvironmentObject private var themeManager: ThemeManager
        let configuration: Configuration

        var body: some View {
            let t = themeManager.theme
            configuration.label
                .font(.headline.weight(.semibold))
                .foregroundStyle(t.foreground)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    t.cardStartColor.opacity(t.cardStartOpacity),
                                    t.cardEndColor.opacity(t.cardEndOpacity)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.08))
                        )
                )
                .opacity(configuration.isPressed ? 0.85 : 1.0)
                .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
                .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
        }
    }
}

// MARK: - Wrapper pratique (compat)
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(title, action: action)
            .buttonStyle(PrimaryButtonStyle())   // ✅ pas d'environnement sur le style
    }
}
