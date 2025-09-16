// === File: HomeView.swift
// Version: 1.3
// Date: 2025-09-14 06:36:00 UTC
// Description: Dashboard screen showing recent Assets (coherent visuals with Vault/Contacts). Full theme propagation.
// Author: K-Cim

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    private var fg: some ShapeStyle { themeManager.theme.foreground }
    private var bg: some ShapeStyle { themeManager.theme.background }
    private var accent: some ShapeStyle { themeManager.theme.accent }

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {

                // Titre en haut (unis avec le thème)
                ThemedHeaderTitle(text: "Accueil")
                    .foregroundStyle(fg)

                ScrollView {
                    VStack(spacing: 12) {

                        // Bandeau Aetherion avec logo si dispo
                        ThemedCard(fixedHeight: 64) {
                            HStack(spacing: 12) {
                                // ✅ Affiche le logo si présent, sinon SF Symbol teinté par le thème
                                if let ui = UIImage(named: "AppMark") {
                                    Image(uiImage: ui)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                        .accessibilityLabel("Logo Aetherion")
                                } else {
                                    Image(systemName: "seal.fill")
                                        .font(.title2.weight(.semibold))
                                        .foregroundStyle(fg)           // icône suit le thème
                                        .frame(width: 40, height: 40, alignment: .center)
                                        .accessibilityLabel("Emblème Aetherion")
                                }

                                Text("Aetherion")
                                    .font(.title.bold())
                                    .foregroundStyle(fg)

                                Spacer(minLength: 0)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        // Carte "Entrer" -> Dashboard, NavigationLink DANS la carte
                        ThemedCard(fixedHeight: 80) {
                            // Important: .tint + .foregroundStyle pour neutraliser les styles par défaut
                            NavigationLink {
                                DashboardView()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Entrer")
                                        .font(.title2.bold())
                                        .foregroundStyle(fg)           // texte suit le thème
                                        .padding(.vertical, 8)
                                    Spacer()
                                }
                                .contentShape(Rectangle())             // ✅ toute la zone cliquable
                            }
                            .buttonStyle(.plain)                       // ✅ pas de style bouton qui écrase le fond
                            .tint(Color.fromShapeStyle(accent))        // ✅ teinte des contrôles vient du thème
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
                .scrollContentBackground(.hidden)                      // fond ScrollView neutre
                .background(bg)                                        // 👉 fond themed partout
            }
        }
        // Sécurité: assurer la teinte globale si des sous-vues en ont besoin
        .tint(Color.fromShapeStyle(accent))
        .background(bg)
    }
}

// MARK: - Helpers
private extension Color {
    /// Convertit un `some ShapeStyle` (typiquement Color/Material) vers Color si possible.
    /// Ici on traite le cas courant où `accent`/`foreground`/`background` sont des Color.
    static func fromShapeStyle(_ style: some ShapeStyle) -> Color {
        // Si ton Theme expose déjà des `Color`, préfère les utiliser directement et supprime ce helper.
        // Placeholder simple : si tu utilises toujours Color dessous, cast léger :
        if let color = style as? Color { return color }
        // Fallback neutre (devrait être rare si ton Theme est cohérent)
        return Color.accentColor
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ThemeManager(default: .aetherionDark))  // ✅ injection Preview indispensable
    }
}
