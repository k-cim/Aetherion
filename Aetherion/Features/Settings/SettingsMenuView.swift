// === File: SettingsMenuView.swift
// Version: 1.2
// Date: 2025-08-30 06:40:00 UTC
// Description: Settings hub; Theme entry active, others “coming soon”. Bottom bar fixed at bottom.
// Author: K-Cim

import SwiftUI

struct SettingsMenuView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showSoonAlert = false
    @State private var soonMessage = ""

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Large, bold title
                        Text(NSLocalizedString("settings", comment: "Settings"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                        // Appearance section
                        Text(NSLocalizedString("settings_appearance", comment: "Appearance"))
                            .font(.title3.weight(.bold))
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)

                        // Theme card (active)
                        NavigationLink {
                            ThemeConfigView()
                        } label: {
                            ThemedCard {
                                HStack(spacing: 14) {
                                    Image(systemName: "paintpalette")
                                        .font(.title3.weight(.semibold))
                                        .themedSecondary(themeManager.theme)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(NSLocalizedString("settings_theme", comment: "Theme"))
                                            .font(.headline.weight(.bold))
                                            .themedForeground(themeManager.theme)
                                        Text(NSLocalizedString("settings_theme_desc", comment: "Theme configuration"))
                                            .font(.footnote)
                                            .themedSecondary(themeManager.theme)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.footnote.weight(.semibold))
                                        .themedSecondary(themeManager.theme)
                                        .opacity(0.5)
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 16)

                        // Storage section
                        Text(NSLocalizedString("settings_storage_section", comment: "Storage section"))
                            .font(.title3.weight(.bold))
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)

                        ThemedCard {
                            SettingsRow(icon: "externaldrive",
                                        title: NSLocalizedString("settings_storage", comment: ""),
                                        subtitle: NSLocalizedString("settings_storage_desc", comment: ""),
                                        disabled: true)
                        }
                        .padding(.horizontal, 16)
                        .onTapGesture { soon("settings_storage") }

                        ThemedCard {
                            SettingsRow(icon: "arrow.triangle.2.circlepath",
                                        title: NSLocalizedString("settings_backup", comment: ""),
                                        subtitle: NSLocalizedString("settings_backup_desc", comment: ""),
                                        disabled: true)
                        }
                        .padding(.horizontal, 16)
                        .onTapGesture { soon("settings_backup") }

                        // Contacts section
                        Text(NSLocalizedString("settings_contacts_section", comment: "Contacts section"))
                            .font(.title3.weight(.bold))
                            .themedForeground(themeManager.theme)
                            .padding(.horizontal, 16)

                        ThemedCard {
                            SettingsRow(icon: "person.2",
                                        title: NSLocalizedString("settings_contacts", comment: ""),
                                        subtitle: NSLocalizedString("settings_contacts_desc", comment: ""),
                                        disabled: true)
                        }
                        .padding(.horizontal, 16)
                        .onTapGesture { soon("settings_contacts") }

                        Spacer(minLength: 20)
                    }
                }

                // 🔻 BARRE DU BAS — HORS DU SCROLL, TOUJOURS EN PIED
                ThemedBottomBar(current: .settings)
            }
        }
        .alert(NSLocalizedString("soon_title", comment: "Soon"), isPresented: $showSoonAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(
                String(
                    format: NSLocalizedString("soon_message", comment: "Feature coming soon"),
                    NSLocalizedString(soonMessage, comment: "")
                )
            )
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private func soon(_ key: String) {
        soonMessage = key
        showSoonAlert = true
    }
}

#Preview {
    NavigationStack {
        SettingsMenuView()
            .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
    }
}
