// === File: PrimaryButton.swift
// Version: 1.1
// Date: 2025-08-30 04:45:00 UTC
// Description: Reusable primary button styled according to the active theme.
// Author: K-Cim

import SwiftUI

struct PrimaryButton: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline.bold())
                .foregroundStyle(themeManager.theme.background) // text takes bg color (contrast)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                        .fill(ThemeStyle.primaryButtonBackground(themeManager.theme))
                )
        }
        .buttonStyle(.plain)
    }
}
