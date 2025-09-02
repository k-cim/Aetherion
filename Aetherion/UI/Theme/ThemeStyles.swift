// === File: ThemeStyle.swift
// Version: 1.1
// Date: 2025-08-30 04:30:00 UTC
// Description: Helpers to derive styled colors/gradients from Theme.
// Author: K-Cim

import SwiftUI

enum ThemeStyle {
    /// Global screen background.
    static func screenBackground(_ theme: Theme) -> some View {
        theme.background.ignoresSafeArea()
    }

    /// Card background gradient (left to right).
    static func cardBackground(_ theme: Theme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.white.opacity(theme.cardStartOpacity),
                Color.white.opacity(theme.cardEndOpacity)
            ]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Foreground (primary text/icon color).
    static func foreground(_ theme: Theme) -> Color {
        theme.foreground
    }

    /// Secondary text/icon color.
    static func secondary(_ theme: Theme) -> Color {
        theme.secondary
    }

    /// Primary button background gradient.
    static func primaryButtonBackground(_ theme: Theme) -> LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [
                theme.foreground.opacity(0.9),
                theme.foreground.opacity(0.7)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
