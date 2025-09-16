// === File: UI/Theme/ThemeKit.swift
// Version: 1.0
// Date: 2025-09-14 07:40:20 UTC
// Description: Point d'entrée unique des styles et conteneurs thémés.
//              - Styles dérivés (dégradés, couleurs composites) via ThemeKit
//              - Composants de base (ThemedScreen, ThemedCard)
//              - Helpers de compat (themedForeground/Secondary)
//              Remplace ThemeStyle.swift et ThemedModifiers.swift (compat via typealias).
// Author: K-Cim

import SwiftUI

// MARK: - Styles dérivés (ex-ThemeStyle)
enum ThemeKit {
    /// Fond global de l’écran (ignore les safe areas).
    static func screenBackground(_ theme: Theme) -> some View {
        theme.background.ignoresSafeArea()
    }

    /// Dégradé de carte (gauche → droite) basé sur les couleurs/opa du thème.
    static func cardBackground(_ theme: Theme) -> LinearGradient {
        LinearGradient(
            colors: [
                theme.cardStartColor.opacity(theme.cardStartOpacity),
                theme.cardEndColor.opacity(theme.cardEndOpacity)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Dégradé de bouton primaire (contraste élevé recommandé).
    /// Ici basé sur `accent` pour éviter un texte trop pâle si `foreground` est clair.
    static func primaryButtonBackground(_ theme: Theme) -> LinearGradient {
        LinearGradient(
            colors: [
                theme.accent.opacity(0.95),
                theme.accent.opacity(0.75)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    /// Couleur principale (texte/icônes).
    static func foreground(_ theme: Theme) -> Color { theme.foreground }

    /// Couleur secondaire (texte/icônes).
    static func secondary(_ theme: Theme) -> Color { theme.secondary }
}

// MARK: - Composants de base (ex-ThemedModifiers)

/// Contexte d’écran complet : applique automatiquement le fond global du thème.
struct ThemedScreen<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        ZStack {
            themeManager.bg.ignoresSafeArea()
            content()
        }
    }
}

/// Bloc homogène utilisé partout dans l’app pour afficher des sections.
/// Utilise le dégradé du thème, rayon de coin, et bordure discrète.
/// Optionnel: `fixedHeight` pour contraintes simples.
struct ThemedCard<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let fixedHeight: CGFloat?
    let content: () -> Content

    init(fixedHeight: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.fixedHeight = fixedHeight
        self.content = content
    }

    var body: some View {
        let t = themeManager.theme

        ZStack {
            RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous)
                .fill(ThemeKit.cardBackground(t))
                .overlay(
                    RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
                )
            content()
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: fixedHeight)
    }
}

// MARK: - Helpers de style (compat)

extension View {
    /// Applique la couleur principale du thème (compat si du code passe encore Theme en direct).
    func themedForeground(_ theme: Theme) -> some View { foregroundStyle(theme.foreground) }
    /// Applique la couleur secondaire du thème (compat).
    func themedSecondary(_ theme: Theme) -> some View { foregroundStyle(theme.secondary) }
}

// MARK: - Compat ascendante (anciens imports)
@available(*, deprecated, message: "Use ThemeKit à la place.")
typealias ThemeStyle = ThemeKit
