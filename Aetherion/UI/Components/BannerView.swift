// === File: UI/Components/BannerView.swift
// Version: 1.1 (fix fg/bg access & ShapeStyle types)
// Date: 2025-09-15
// Description: Reusable top banner (logo left + title right) coherent with theme.
// Author: K-Cim

import SwiftUI

struct BannerView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let logoName: String    // ex: "AppMark" depuis Assets
    let title: String       // ex: "Aetherion"

    // alias locaux pratiques (évite de répéter themeManager.theme partout)
    private var t: Theme { themeManager.theme }

    var body: some View {
        ThemedCard {
            HStack(spacing: 12) {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)

                Text(title)
                    .font(.title.bold())
                    .foregroundStyle(t.foreground)   // ✅ Color, pas un Binding

                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
    }
}
