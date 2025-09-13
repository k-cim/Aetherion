// === File: SettingsOptionRow.swift
// Date: 2025-09-04
// Description: Option row with fixed height for consistency across screens.

// Aetherion/UI/Components/SettingsOptionRow.swift (extrait)
import SwiftUI

struct SettingsOptionRow: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ThemedCard(fixedHeight: 56) {          // ✅ nouvelle API
            HStack(spacing: 12) {
                // ... ton contenu ...
            }
        }
        .buttonStyle(.plain)
    }
}
