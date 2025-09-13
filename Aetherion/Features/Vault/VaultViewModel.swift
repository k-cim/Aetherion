// === File: Features/Vault/VaultViewModel.swift
import SwiftUI

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
        let dir = StorageService.documentsURL
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
        let dir = StorageService.documentsURL
        let ts  = Int(Date().timeIntervalSince1970)
        let url = dir.appendingPathComponent("Sample-\(ts).txt")
        let data = Data("Hello Aetherion!".utf8)
        do {
            try data.write(to: url, options: .atomic)
            reload()
        } catch {
            print("Vault addSample error:", error)
        }
    }
}
