// === File: RootSwitch.swift
// Date: 2025-09-04
// Description: Switches root content based on AppRouter tab.
/*
 
import SwiftUI

struct RootSwitch: View {
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var nav: NavigationCoordinator
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        VStack(spacing: 0) {

            // Contenu principal selon l’onglet actif — SANS NavigationStack ici
            Group {
                switch router.tab {
                case .home:     HomeView()
                case .vault:    VaultView()
                case .contacts: ContactsView()
                case .settings: SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Barre en bas UNIQUEMENT à la racine (pile globale vide)
            if nav.path.isEmpty {
                ThemedBottomBar(current: router.tab)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(themeManager.backgroundColor.ignoresSafeArea())
    }
}
*/
