// === File: SettingsView.swift
// Version: 1.2
// Date: 2025-08-30 02:20:00 UTC
// Description: Settings with theme picker and themed Form appearance.
// Author: K-Cim

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = SettingsViewModel()

    var body: some View {
        ThemedScreen {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { themeManager.themeID },
                        set: { themeManager.setTheme($0) }
                    )) {
                        ForEach(ThemeID.allCases) { id in
                            Text(id.displayName).tag(id)
                        }
                    }
                    NavigationLink("Configure Theme") { ThemeConfigView() }
                }

                Section("App") {
                    Toggle("Dark mode (example only)", isOn: $vm.darkMode)
                }
            }
            .themedListAppearance() // ← retire le fond blanc de la Form
            .tint(ThemeStyle.foreground(themeManager.theme)) // accent teinte selon thème
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack { SettingsView() }
        .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
}
