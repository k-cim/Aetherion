// === File: Features/Settings/SettingsView.swift
// Description: Paramètres — section Apparence (Thème / Couleurs).
// Dépendances: ThemeManager (env), ThemedScreen, ThemedCard, ThemedHeaderTitle,
//              ThemeDefaultView, ThemeConfigView.

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                // Titre d'écran
                ThemedHeaderTitle(text: "Paramètres")

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // === Section: Apparence ===
                        Text("Apparence")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(themeManager.theme.foreground)
                            .padding(.horizontal, 2)

                        // Carte: Thème (présélections via la roue)
                        NavigationLink {
                            ThemeDefaultView() // ✅ corrige la typo
                        } label: {
                            ThemedCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(themeManager.theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Thème (présélections)")
                                            .font(.headline.bold())
                                            .foregroundStyle(themeManager.theme.foreground)
                                        Text("Choix via la roue et application globale")
                                            .font(.caption)
                                            .foregroundStyle(themeManager.theme.secondary)
                                    }

                                    Spacer()

                                    // Badge "non enregistré" si des modifs locales existent
                                    if themeManager.colorModified {
                                        Text("non enregistré")
                                            .font(.caption2.weight(.bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(themeManager.theme.accent.opacity(0.18))
                                            .foregroundStyle(themeManager.theme.accent)
                                            .clipShape(Capsule())
                                    }

                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(themeManager.theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)

                        // Carte: Couleurs personnalisées (ThemeConfigView)
                        NavigationLink {
                            ThemeConfigView()
                        } label: {
                            ThemedCard {
                                HStack(spacing: 12) {
                                    Image(systemName: "slider.horizontal.3")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(themeManager.theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Couleurs personnalisées")
                                            .font(.headline.bold())
                                            .foregroundStyle(themeManager.theme.foreground)
                                        Text("Fond, textes, dégradés, contrôles…")
                                            .font(.caption)
                                            .foregroundStyle(themeManager.theme.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(themeManager.theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120) // espace pour la bottom bar globale
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environmentObject(ThemeManager(default: .aetherionDark))
    }
}
