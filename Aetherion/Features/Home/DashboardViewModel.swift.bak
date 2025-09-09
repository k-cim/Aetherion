// === File: DashboardViewModel.swift
// Date: 2025-08-30
// Description: View model for Dashboard. Loads recent Assets from StorageService and can add a sample file.

import Foundation

@MainActor
final class DashboardViewModel: ObservableObject {
    /// Derniers fichiers (récents) à afficher sur le dashboard
    @Published var recentAssets: [Asset] = []

    /// Alias pour compatibilité avec d’éventuels anciens usages `vm.assets`
    var assets: [Asset] { recentAssets }

    /// Charge la liste des fichiers et prend les N plus récents (ici 5 par simplicité)
    func load() {
        let all = StorageService.listAssets()
        // Tri par date modif décroissante si dispo, sinon par nom
        let sorted = all.sorted {
            switch ($0.modifiedAt, $1.modifiedAt) {
            case let (d1?, d2?): return d1 > d2
            case (_?, nil): return true
            case (nil, _?): return false
            default:
                return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        }
        // Garde 5 max
        self.recentAssets = Array(sorted.prefix(5))
    }

    /// Crée un petit fichier d’exemple dans Documents pour tests rapides
    func addSample() {
        let docs = StorageService.documentsURL()
        let filename = "Sample_\(Int(Date().timeIntervalSince1970)).txt"
        let url = docs.appendingPathComponent(filename)

        let content = "Aetherion sample file created at \(Date())\n"
        do {
            try content.data(using: .utf8)?.write(to: url, options: .atomic)
        } catch {
            // Pas critique pour la démo
        }

        // Recharge la liste des fichiers
        load()
    }
}
