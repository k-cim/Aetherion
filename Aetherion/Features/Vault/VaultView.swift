// === File: Features/Vault/Vault.swift
// Version: 2.0
// Date: 2025-09-14
// Description: Coffre (Vue + ViewModel) — liste de fichiers locaux avec actions basiques.
// Author: K-Cim

import SwiftUI

// MARK: - ViewModel
@MainActor
final class VaultViewModel: ObservableObject {

    // Item local au Vault pour éviter tout conflit de nom avec d’autres "Asset"
    struct Item: Identifiable, Hashable {
        let id: URL
        let url: URL
        let name: String
        let modifiedAt: Date?
        let size: Int64?

        init(url: URL) {
            self.url = url
            self.id = url
            self.name = url.lastPathComponent
            self.modifiedAt = url.modifiedAt
            self.size = url.fileSize
        }
    }

    @Published var items: [Item] = []

    /// Recharge la liste des fichiers du dossier Documents (triés par date modif desc)
    func reload() {
        let dir = FileStorageService.documentsURL
        let fm = FileManager.default
        let urls = (try? fm.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        self.items = urls
            .filter { $0.isFileURL }
            .map { Item(url: $0) }
            .sorted { ($0.modifiedAt ?? .distantPast) > ($1.modifiedAt ?? .distantPast) }
    }

    /// Ajoute un petit fichier d’exemple, puis recharge.
    func addSample() {
        let dir = FileStorageService.documentsURL
        let ts  = Int(Date().timeIntervalSince1970)
        let url = dir.appendingPathComponent("Sample-\(ts).txt")
        let data = Data("Hello Aetherion!".utf8)
        do {
            try data.write(to: url, options: .atomic)
            reload()
        } catch {
            print("Vault addSample error:", error.localizedDescription)
        }
    }
}

// MARK: - View
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
        .environmentObject(ThemeManager(default: .aetherionDark))
}
