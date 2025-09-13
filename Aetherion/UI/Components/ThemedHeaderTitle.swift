// === File: ThemedHeaderTitle.swift
// Date: 2025-09-04
// Description: Top-left page title using theme.headerFont & theme.headerColor (no card).

// === File: UI/Components/ThemedHeaderTitle.swift
import SwiftUI

struct ThemedHeaderTitle: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let text: String

    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(themeManager.theme.headerColor)   // 👈 live depuis Theme
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
