// === File: ThemedBottomBar.swift
// Version: 1.1
// Date: 2025-08-30 04:40:00 UTC
// Description: Reusable bottom bar with Home/Vault/Settings; disables current tab and dims its color.
// Author: K-Cim

import SwiftUI

enum BottomTab: Hashable {
    case home, vault, settings
}

struct ThemedBottomBar: View {
    @EnvironmentObject private var themeManager: ThemeManager

    let current: BottomTab

    var body: some View {
        HStack(spacing: 60) {
            // HOME
            tabLabel(.home, system: "house", titleKey: "home") {
                HomeView()
            }

            // VAULT
            tabLabel(.vault, system: "lock", titleKey: "vault") {
                VaultView()
            }

            // SETTINGS
            tabLabel(.settings, system: "gearshape", titleKey: "settings") {
                SettingsMenuView()
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                .fill(ThemeStyle.cardBackground(themeManager.theme))
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

        if isCurrent {
            // Disabled/Dimmed: no navigation on current tab
            VStack {
                Image(systemName: system)
                    .font(.title2)
                    .foregroundStyle(dimmedColor())
                Text(NSLocalizedString(titleKey, comment: ""))
                    .font(.caption.bold())
                    .foregroundStyle(dimmedColor())
            }
            .contentShape(Rectangle())
        } else {
            NavigationLink {
                destination()
            } label: {
                VStack {
                    Image(systemName: system)
                        .font(.title2)
                        .foregroundStyle(ThemeStyle.foreground(themeManager.theme))
                    Text(NSLocalizedString(titleKey, comment: ""))
                        .font(.caption.bold())
                        .foregroundStyle(ThemeStyle.foreground(themeManager.theme))
                }
            }
        }
    }

    private func dimmedColor() -> Color {
        // “Two tones lower” effect: use secondary color and reduce opacity slightly
        ThemeStyle.secondary(themeManager.theme).opacity(0.85)
    }
}
