// === File: Features/Settings/SettingsMenuView.swift
// Version: 2.0
// Date: 2025-09-14
// Description: Settings hub; routes updated (ThemeDefaultView / ThemeConfigView) without changing UI style.
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
                            .foregroundStyle(themeManager.theme.foreground)
                            .padding(.horizontal, 16)

                        // Theme card (presets / wheel)
                        NavigationLink {
                            ThemeDefaultView()   // ⬅️ destination mise à jour
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

                        // Background color card (goes to full color config)
                        NavigationLink {
                            ThemeConfigView()    // ⬅️ destination mise à jour (fond inclus)
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
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsMenuView()
            .environmentObject(ThemeManager(default: .aetherionDark))
            .environmentObject(AppRouter())
    }
}
