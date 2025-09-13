// === File: Features/Vault/VaultView.swift
import SwiftUI

struct VaultView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = VaultViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ThemedHeaderTitle(text: "Coffre")

                // Bandeau actions
                HStack(spacing: 12) {
                    PrimaryButton(title: "Recharger") { vm.reload() }
                    PrimaryButton(title: "Ajouter un exemple") { vm.addSample() }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

                // Liste des items
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(vm.items) { item in
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

                        if vm.items.isEmpty {
                            ThemedCard {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Aucun fichier")
                                        .font(.headline)
                                        .foregroundStyle(themeManager.theme.foreground)
                                    Text("Appuie sur “Ajouter un exemple” pour créer un fichier.")
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
    VaultView()
        // // // .environmentObject(ThemeManager(default: .aetherionDark))
}
