// === File: Core/Services/StorageService.swift
// Rôle: persistance des thèmes (ID de thème + override JSON)
//       + utilitaires fichiers/Documents


import Foundation

enum StorageService {
    // MARK: - Thème (ID via UserDefaults)
    private static let ud = UserDefaults.standard
    private static let selectedKey = "ae.selectedThemeID"

    static func saveSelectedThemeID(_ id: ThemeID) {
        ud.set(id.rawValue, forKey: selectedKey)
    }

    static func loadSelectedThemeID(default id: ThemeID = .aetherionDark) -> ThemeID {
        ud.string(forKey: selectedKey).flatMap(ThemeID.init(rawValue:)) ?? id
    }

    // MARK: - Override JSON (fichier via ThemeOverrideDiskStore)
    static func saveOverride(_ theme: Theme) throws {
        try ThemeOverrideDiskStore.save(theme: theme)
    }

    static func loadOverride() -> Theme? {
        ThemeOverrideDiskStore.load()
    }

    static func clearOverride() throws {
        try ThemeOverrideDiskStore.clear()
    }

    // MARK: - Dossier Documents (une seule API)
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}

// ⛔️ IMPORTANT:
// - NE PAS redéclarer ici des extensions sur URL (modifiedAt, fileSize).
//   Ces helpers doivent rester dans Core/Extensions/URL+FileAttributes.swift
