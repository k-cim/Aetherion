// === File: RootSwitch.swift
// Date: 2025-09-04
// Description: Switches root content based on AppRouter tab.

import SwiftUI

struct RootSwitch: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        switch router.tab {
        case .home:      HomeView()
        case .vault:     VaultView()
        case .contacts:  ContactsView()
        case .settings:  SettingsView()
        }
    }
}
