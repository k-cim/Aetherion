// === File : Aetherion/App/AppContainerView.swift
// Date: 2025-09-04

import SwiftUI

struct AppContainerView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var nav: NavigationCoordinator

    var body: some View {
        ZStack {
            // 👇 fond global (toujours)
            themeManager.theme.background.ignoresSafeArea()
            
            // ton contenu (qui peut lui-même utiliser ThemedScreen)
            ThemedScreen {
                // ⬇️ plus de RootSwitch ici
                contentView(for: router.tab)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .safeAreaInset(edge: .bottom) {
                ThemedBottomBar(current: router.tab)
            }
            .background(themeManager.theme.background.ignoresSafeArea())
            .ignoresSafeArea(.keyboard, edges: .bottom)
        }
    }
    
    // MARK: - Tab -> Content
    @ViewBuilder
    private func contentView(for tab: AppRouter.Tab) -> some View {
        switch tab {
        case .home:
            HomeView()
        case .vault:
            VaultView()
        case .contacts:
            ContactsView()
        case .settings:
            SettingsView()
        }
    }
}
