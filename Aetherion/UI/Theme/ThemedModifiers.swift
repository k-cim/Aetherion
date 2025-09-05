// === File: ThemedModifiers.swift
// Version: 1.4
import SwiftUI

struct ThemedScreen<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        ZStack {
            themeManager.backgroundColor.ignoresSafeArea()
            content()
        }
        .tint(themeManager.theme.controlTint)    // 👈 applique la teinte à tous les contrôles enfants
        .accentColor(themeManager.theme.controlTint) // (fallback anciennes versions)
    }
}

struct ThemedCard<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let fixedHeight: CGFloat?
    let contentPadding: CGFloat
    let content: () -> Content

    init(fixedHeight: CGFloat? = nil,
         contentPadding: CGFloat = 16,
         @ViewBuilder content: @escaping () -> Content) {
        self.fixedHeight = fixedHeight
        self.contentPadding = contentPadding
        self.content = content
    }

    var body: some View {
        let radius = themeManager.theme.cornerRadius
        let start = themeManager.theme.cardStartColor.opacity(themeManager.theme.cardStartOpacity)
        let end   = themeManager.theme.cardEndColor.opacity(themeManager.theme.cardEndOpacity)

        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing))
                .overlay(
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
                )

            VStack(alignment: .leading, spacing: 8) {
                content()
            }
            .padding(contentPadding)
        }
        .frame(height: fixedHeight, alignment: .center)
        .contentShape(Rectangle())
    }
}

// Helpers
extension View {
    func themedForeground(_ theme: Theme) -> some View { foregroundStyle(theme.foreground) }
    func themedSecondary(_ theme: Theme) -> some View { foregroundStyle(theme.secondary) }
    func themedListAppearance() -> some View { scrollContentBackground(.hidden).background(Color.clear) }
}
