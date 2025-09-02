// === File: VaultView.swift
// Version: 1.1
// Date: 2025-08-30 06:30:00 UTC
// Description: Vault screen (placeholder) with persistent themed bottom bar.
// Author: K-Cim

import SwiftUI

struct VaultView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = VaultViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 12) {
                // Contenu principal (placeholder pour l’instant)
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(NSLocalizedString("vault", comment: "Vault"))
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        ThemedCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Coffre en préparation")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)
                                Text("Ici s’afficheront vos fichiers sécurisés et actions (import, suppression, partage…).")
                                    .font(.subheadline)
                                    .themedSecondary(themeManager.theme)
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                }

                // 🔻 BARRE DU BAS — TOUJOURS EN DEHORS DU SCROLL
                ThemedBottomBar(current: .vault)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.load() }
    }
}

#Preview {
    NavigationStack {
        VaultView()
            .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
    }
}
