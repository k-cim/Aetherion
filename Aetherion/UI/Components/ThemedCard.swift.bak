// === File: ThemedCard.swift
// Version: 1.0
// Date: 2025-08-30 04:50:00 UTC
// Description: Reusable card container with themed gradient background and padding.
// Author: K-Cim

import SwiftUI

struct ThemedCard<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content()
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                .fill(ThemeStyle.cardBackground(themeManager.theme))
        )
    }
}
