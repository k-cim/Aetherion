// === File: ThemedModifiers.swift
// Version: 1.4

import SwiftUI

// Écran thémé : applique le fond global du thème
struct ThemedScreen<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }

    var body: some View {
        ZStack {
            themeManager.theme.background.ignoresSafeArea()
            content()
        }
    }
}

// Carte thémée : même API partout dans le projet
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
        let start = t.cardStartColor.opacity(t.cardStartOpacity)
        let end   = t.cardEndColor.opacity(t.cardEndOpacity)

        ZStack {
            RoundedRectangle(cornerRadius: t.cornerRadius, style: .continuous)
                .fill(LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing))
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

// Helpers compatibles (si encore appelés quelque part)
extension View {
    func themedForeground(_ theme: Theme) -> some View { foregroundStyle(theme.foreground) }
    func themedSecondary(_ theme: Theme) -> some View { foregroundStyle(theme.secondary) }
}

