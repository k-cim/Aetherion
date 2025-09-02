// === File: DashboardView.swift
// Version: 1.4
// Date: 2025-08-30 05:00:00 UTC
// Description: Themed dashboard with gradient card empty state, bold section headers, and persistent bottom bar.
// Author: K-Cim

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 8) {
                List {
                    // Documents section
                    Section {
                        if vm.assets.isEmpty {
                            ThemedCard {
                                HStack(alignment: .firstTextBaseline, spacing: 12) {
                                    Image(systemName: "doc")
                                        .font(.title3.weight(.semibold))
                                        .themedSecondary(themeManager.theme)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(NSLocalizedString("no_files_title", comment: ""))
                                            .font(.headline.weight(.bold))
                                            .themedForeground(themeManager.theme)
                                        Text(NSLocalizedString("no_files_subtitle", comment: ""))
                                            .font(.subheadline)
                                            .themedSecondary(themeManager.theme)
                                    }
                                    Spacer(minLength: 0)
                                }
                            }
                            .listRowBackground(Color.clear)
                        } else {
                            ForEach(vm.assets) { asset in
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .themedSecondary(themeManager.theme)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(asset.name)
                                            .font(.body.weight(.semibold))
                                            .themedForeground(themeManager.theme)
                                        Text("\(asset.size) bytes")
                                            .font(.caption)
                                            .themedSecondary(themeManager.theme)
                                    }

                                    Spacer()

                                    Button(role: .destructive) { vm.delete(asset) } label: {
                                        Image(systemName: "trash")
                                    }
                                    .buttonStyle(.borderless)
                                    .themedSecondary(themeManager.theme)
                                    .accessibilityLabel("Delete")
                                }
                            }
                        }
                    } header: {
                        Text(NSLocalizedString("documents_section", comment: ""))
                            .font(.title3.weight(.bold))
                            .themedForeground(themeManager.theme)
                    }

                    // Navigation section
                    Section {
                        NavigationLink(NSLocalizedString("settings", comment: "")) { SettingsMenuView() }
                        NavigationLink(NSLocalizedString("vault", comment: "")) { VaultView() }
                        NavigationLink(NSLocalizedString("share", comment: "")) { ShareView() }
                        NavigationLink(NSLocalizedString("onboarding", comment: "")) { OnboardingView() }
                    } header: {
                        Text(NSLocalizedString("navigation_section", comment: ""))
                            .font(.title3.weight(.bold))
                            .themedForeground(themeManager.theme)
                    }
                }
                .themedListAppearance()

                // Bottom bar
                ThemedBottomBar(current: .home) // tu peux mettre `.vault` si tu veux associer ce dashboard au coffre
            }
        }
        .navigationTitle(NSLocalizedString("dashboard_title", comment: ""))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { vm.load() } label: {
                    Label(NSLocalizedString("refresh", comment: ""), systemImage: "arrow.clockwise")
                }
                .themedForeground(themeManager.theme)
            }
            ToolbarItem(placement: .primaryAction) {
                Button { vm.addSample() } label: {
                    Label(NSLocalizedString("add", comment: ""), systemImage: "plus")
                }
                .themedForeground(themeManager.theme)
            }
        }
        .onAppear { vm.load() }
    }
}

#Preview("FR themed") {
    NavigationStack { DashboardView() }
        .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
        .environment(\.locale, .init(identifier: "fr"))
}
#Preview("EN themed") {
    NavigationStack { DashboardView() }
        .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
        .environment(\.locale, .init(identifier: "en"))
}
