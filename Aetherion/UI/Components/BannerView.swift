// === File: BannerView.swift
// Version: 1.0
// Date: 2025-08-30
// Description: Reusable top banner (logo left + title right) with same style as Home screen.
// Author: K-Cim

import SwiftUI

struct BannerView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let logoName: String    // ex: "AppLogo" depuis Assets
    let title: String       // ex: "Aetherion"

    var body: some View {
        ThemedCard {
            HStack(spacing: 12) {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(themeManager.theme.foreground)

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
