// === File: DashboardView.swift
// Date: 2025-08-30
// Description: Dashboard screen showing recent Assets (coherent visuals with Vault/Contacts).

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = DashboardViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ThemedHeaderTitle(text: "Tableau de bord")

                // Actions
                HStack(spacing: 12) {
                    PrimaryButton(title: "Recharger") { vm.reload() }
                    PrimaryButton(title: "Ajouter un exemple") { vm.addSample() }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Fichiers récents
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.recent) { item in
                            ThemedCard {
                                HStack {
                                    Image(systemName: "doc.text")
                                        .font(.title3)
                                        .foregroundStyle(themeManager.theme.accent)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundStyle(themeManager.theme.foreground)
                                        HStack(spacing: 8) {
                                            if let dt = item.modifiedAt {
                                                Text(dt.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.caption)
                                                    .foregroundStyle(themeManager.theme.secondary)
                                            }
                                            if let size = item.size {
                                                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                                    .font(.caption)
                                                    .foregroundStyle(themeManager.theme.secondary)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(.vertical, 6)
                            }
                        }

                        if vm.recent.isEmpty {
                            ThemedCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Aucun fichier récent")
                                        .font(.headline)
                                        .foregroundStyle(themeManager.theme.foreground)
                                    Text("Ajoute un exemple pour tester.")
                                        .font(.caption)
                                        .foregroundStyle(themeManager.theme.secondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear { vm.reload() }
    }
}

#Preview {
    DashboardView()
        // // // .environmentObject(ThemeManager(default: .aetherionDark))
}
