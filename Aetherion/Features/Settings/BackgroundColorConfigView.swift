// === File: BackgroundColorConfigView.swift
// Date: 2025-09-04
// Description: Background + text colors configuration, with right-aligned color pickers.

import SwiftUI

struct BackgroundColorConfigView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // Etats locaux
    @State private var bgColor: Color = .black
    @State private var headerColor: Color = .white
    @State private var textColor: Color = .white

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {

                ThemedHeaderTitle(text: "Couleur du fond")

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Aperçu
                        Text("Aperçu écran")
                            .font(.headline.weight(.bold))
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)

                        ThemedCard(fixedHeight: 80) {
                            HStack {
                                Spacer()
                                Text("Fond actuel")
                                    .font(.title3.bold())
                                    .themedForeground(themeManager.theme)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)

                        // -------- Fond d'écran --------
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Choisir une couleur")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                // Picker à droite de l'intitulé
                                HStack {
                                    Text("Couleur du fond")
                                        .font(.subheadline)
                                        .themedForeground(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $bgColor, supportsOpacity: true)
                                        .labelsHidden()
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // -------- Couleurs des textes --------
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Couleurs des textes")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                // Titres (header)
                                HStack {
                                    Text("Titres")
                                        .font(.subheadline)
                                        .themedForeground(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $headerColor, supportsOpacity: true)
                                        .labelsHidden()
                                }

                                // Texte principal
                                HStack {
                                    Text("Texte principal")
                                        .font(.subheadline)
                                        .themedForeground(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $textColor, supportsOpacity: true)
                                        .labelsHidden()
                                }
                            }
                        }
                        .padding(.horizontal, 16)

                        // -------- Actions --------
                        HStack(spacing: 12) {
                            Button {
                                // Appliquer toutes les couleurs
                                themeManager.updateBackgroundColor(bgColor)
                                themeManager.updateHeaderColor(headerColor)
                                themeManager.updatePrimaryTextColor(textColor)
                            } label: {
                                ThemedCard(fixedHeight: 56) {
                                    HStack { Spacer(); Text("Appliquer").font(.headline.bold()).themedForeground(themeManager.theme); Spacer() }
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                // Réinitialiser : fond selon thème, textes selon preset du thème
                                let fallbackBG: Color = (themeManager.theme.id == .aetherionDark) ? .black : .white
                                bgColor = fallbackBG
                                headerColor = Theme.preset(themeManager.theme.id).headerColor
                                textColor = Theme.preset(themeManager.theme.id).foreground

                                themeManager.updateBackgroundColor(bgColor)
                                themeManager.updateHeaderColor(headerColor)
                                themeManager.updatePrimaryTextColor(textColor)
                            } label: {
                                ThemedCard(fixedHeight: 56) {
                                    HStack { Spacer(); Text("Réinitialiser").font(.headline.bold()).themedForeground(themeManager.theme); Spacer() }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)
                    }
                    .padding(.bottom, 12)
                }
            }
        }
        .onAppear {
            // init depuis l'état courant
            bgColor     = themeManager.backgroundColor
            headerColor = themeManager.theme.headerColor
            textColor   = themeManager.theme.foreground
        }
        // Live update (optionnel mais pratique)
        .onChange(of: bgColor)     { themeManager.updateBackgroundColor($0) }
        .onChange(of: headerColor) { themeManager.updateHeaderColor($0) }
        .onChange(of: textColor)   { themeManager.updatePrimaryTextColor($0) }
    }
}

#Preview {
    NavigationStack {
        BackgroundColorConfigView()
            .environmentObject(ThemeManager(default: .aetherionDark))
            .environmentObject(AppRouter())
    }
}
