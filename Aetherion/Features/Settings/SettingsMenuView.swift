// === File: SettingsMenuView.swift
// Version: 1.3
// Date: 2025-08-30 20:45:00 UTC
// Description: Settings hub; includes Theme + Background color entries.
// Author: K-Cim

import SwiftUI

struct SettingsMenuView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ThemedScreen {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Paramètres")
                            .font(.largeTitle.bold())
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)

                        // Theme card
                        NavigationLink {
                            ThemeConfigView()
                        } label: {
                            ThemedCard {
                                HStack {
                                    Image(systemName: "paintpalette")
                                    Text("Thème")
                                        .font(.headline.bold())
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // Background color card
                        NavigationLink {
                            BackgroundColorConfigView()
                        } label: {
                            ThemedCard {
                                HStack {
                                    Image(systemName: "drop.fill")
                                    Text("Couleur du fond")
                                        .font(.headline.bold())
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }
                ThemedBottomBar(current: .settings)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ShareView()
            .environmentObject(ThemeManager(default: .aetherionDark))
            .environmentObject(AppRouter())
    }
}
