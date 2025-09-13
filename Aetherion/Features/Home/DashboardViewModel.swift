// === File: DashboardViewModel.swift
// Date: 2025-08-30
// Description: View model for Dashboard. Loads recent Assets from StorageService and can add a sample file.

import Foundation

final class DashboardViewModel: ObservableObject {

    @Published var recent: [FileAsset] = []

    /// Recharge les fichiers du dossier Documents, triés par date de modif (desc).
    func reload() {
        let dir = StorageService.documentsURL
        let fm = FileManager.default

        let urls = (try? fm.contentsOfDirectory(
            at: dir,
            includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
            options: [.skipsHiddenFiles]
        )) ?? []

        self.recent = urls
            .filter { $0.isFileURL }
            .map { FileAsset(url: $0) }
            .sorted { ($0.modifiedAt ?? .distantPast) > ($1.modifiedAt ?? .distantPast) }
    }

    /// Ajoute un fichier d’exemple pour tester le flux, puis recharge.
    func addSample() {
        let dir = StorageService.documentsURL
        let ts  = Int(Date().timeIntervalSince1970)
        let url = dir.appendingPathComponent("Dashboard-\(ts).txt")
        let data = Data("Hello from Dashboard".utf8)
        do {
            try data.write(to: url, options: .atomic)
            reload()
        } catch {
            print("Dashboard addSample error:", error)
        }
    }
}
