// === File: DashboardView.swift
// Version: 1.6
// Date: 2025-09-14 06:52:30 UTC
// Description: Dashboard screen showing recent Assets (coherent visuals with Vault/Contacts). Omega: durable UI, full theme propagation, refreshable, cancellation-safe.
// Author: K-Cim

import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = DashboardViewModel()   // ✅ création côté View (MainActor)

    private var fg: some ShapeStyle { themeManager.theme.foreground }
    private var fgSecondary: some ShapeStyle { themeManager.theme.secondary }
    private var accent: some ShapeStyle { themeManager.theme.accent }
    private var bg: some ShapeStyle { themeManager.theme.background }

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ThemedHeaderTitle(text: "Tableau de bord")
                    .foregroundStyle(fg)

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
                                HStack(spacing: 12) {
                                    Image(systemName: "doc.text")
                                        .font(.title3)
                                        .foregroundStyle(accent)

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(item.name)
                                            .font(.headline)
                                            .foregroundStyle(fg)

                                        HStack(spacing: 8) {
                                            if let dt = item.modifiedAt {
                                                Text(dt.formatted(date: .abbreviated, time: .shortened))
                                                    .font(.caption)
                                                    .foregroundStyle(fgSecondary)
                                            }
                                            if let size = item.size {
                                                Text(ByteCountFormatter.string(fromByteCount: size, countStyle: .file))
                                                    .font(.caption)
                                                    .foregroundStyle(fgSecondary)
                                            }
                                        }
                                    }

                                    Spacer(minLength: 0)
                                }
                                .padding(.vertical, 6)
                            }
                        }

                        if vm.recent.isEmpty {
                            ThemedCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Aucun fichier récent")
                                        .font(.headline)
                                        .foregroundStyle(fg)
                                    Text("Ajoute un exemple pour tester.")
                                        .font(.caption)
                                        .foregroundStyle(fgSecondary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
                .scrollContentBackground(.hidden)
                .background(bg)
                .refreshable { vm.reload() } // Pull-to-refresh
            }
        }
        .tint(Color.fromShapeStyle(accent)) // teinte globale
        .background(bg)
        .onAppear { vm.reload() }
        .onDisappear { vm.cancel() }        // coupe les tâches en cours
        .animation(.default, value: vm.recent.count)
    }
}

// MARK: - Helpers
private extension Color {
    static func fromShapeStyle(_ style: some ShapeStyle) -> Color {
        if let color = style as? Color { return color }
        return Color.accentColor
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(ThemeManager(default: .aetherionDark)) // indispensable en Preview
    }
}
