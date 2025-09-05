// === File: ThemedHeaderTitle.swift
// Date: 2025-09-04
// Description: Top-left page title using theme.headerFont & theme.headerColor (no card).
import SwiftUI

struct ThemedHeaderTitle: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let text: String

    var body: some View {
        Text(text)
            .font(themeManager.theme.headerFont)
            .foregroundStyle(themeManager.theme.headerColor)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 4)
    }
}
