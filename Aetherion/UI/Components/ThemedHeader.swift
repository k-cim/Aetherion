// === File: UI/Components/ThemedHeader.swift
// Description: Contient 2 variantes de header.
// - ThemedHeaderTitle : simple texte aligné à gauche (utilisé pour titres d’écran).
// - ThemedHeader      : bannière complète (icône + titre + fond gradient/plain).
// Author: K-Cim

import SwiftUI

// MARK: - Simple Title Header
// Utilisation : pour un titre d’écran basique ("Paramètres", "Accueil", etc.)
struct ThemedHeaderTitle: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.theme.headerColor)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}

// MARK: - Full Banner Header
// Utilisation : pour un header plus graphique (Onboarding, Share, etc.)
// Style contrôlé par enum `Style` (gradient ou plain)
struct ThemedHeader: View {
    @EnvironmentObject private var themeManager: ThemeManager

    enum Style {
        case gradient
        case plain
    }

    let title: String
    var systemIcon: String? = nil
    var style: Style = .gradient

    var body: some View {
        HStack(spacing: 12) {
            if let systemIcon {
                Image(systemName: systemIcon)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(themeManager.theme.foreground)
            }

            Text(title)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.theme.foreground)

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
        .background(backgroundView)
        .cornerRadius(themeManager.theme.cornerRadius)
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }

    @ViewBuilder
    private var backgroundView: some View {
        switch style {
        case .plain:
            themeManager.theme.background
        case .gradient:
            LinearGradient(
                colors: [
                    themeManager.theme.cardStartColor.opacity(themeManager.theme.cardStartOpacity),
                    themeManager.theme.cardEndColor.opacity(themeManager.theme.cardEndOpacity)
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }
}
