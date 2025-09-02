// === File: ThemedBottomBar.swift
// Version: 1.3
// Date: 2025-08-30
// Description: Bottom bar with Home, Vault, Contacts, Settings; disables current tab and dims its color.
// Author: K-Cim

import SwiftUI

enum BottomTab: Hashable {
    case home, vault, contacts, settings
}

struct ThemedBottomBar: View {
    @EnvironmentObject private var themeManager: ThemeManager
    let current: BottomTab

    var body: some View {
        HStack {
            Spacer(minLength: 0)
            tabLabel(.home, system: "house", titleKey: "home") { HomeView() }
            Spacer(minLength: 0)
            tabLabel(.vault, system: "lock", titleKey: "vault") { VaultView() }
            Spacer(minLength: 0)
            tabLabel(.contacts, system: "person.2", titleKey: "contacts") { ContactsView() }
            Spacer(minLength: 0)
            tabLabel(.settings, system: "gearshape", titleKey: "settings") { SettingsMenuView() }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                .fill(LinearGradient(
                    colors: [
                        Color.white.opacity(themeManager.theme.cardStartOpacity),
                        Color.white.opacity(themeManager.theme.cardEndOpacity)
                    ],
                    startPoint: .leading, endPoint: .trailing
                ))
                .padding(.horizontal, 16)
        )
        .padding(.bottom, 16)
        .padding(.top, 4)
    }

    @ViewBuilder
    private func tabLabel<Destination: View>(
        _ tab: BottomTab,
        system: String,
        titleKey: String,
        @ViewBuilder destination: @escaping () -> Destination
    ) -> some View {
        let isCurrent = (tab == current)
        let fg = themeManager.theme.foreground
        let dim = themeManager.theme.secondary.opacity(0.85)

        if isCurrent {
            VStack(spacing: 4) {
                Image(systemName: system).font(.title2).foregroundStyle(dim)
                Text(NSLocalizedString(titleKey, comment: "")).font(.caption.bold()).foregroundStyle(dim)
            }
            .contentShape(Rectangle())
        } else {
            NavigationLink {
                destination()
            } label: {
                VStack(spacing: 4) {
                    Image(systemName: system).font(.title2).foregroundStyle(fg)
                    Text(NSLocalizedString(titleKey, comment: "")).font(.caption.bold()).foregroundStyle(fg)
                }
            }
        }
    }
}
