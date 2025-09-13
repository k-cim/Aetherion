// === File: Core/Services/FileStorageService.swift
// Rôle: accès simple aux fichiers/ressources utilisateur (Documents)

import Foundation

enum FileStorageService {

    /// URL du dossier Documents de l’app (sandbox utilisateur)
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    /// Liste le contenu de Documents (fichiers et dossiers de 1er niveau)
    static func listAssets() -> [URL] {
        let fm = FileManager.default
        let url = documentsURL
        return (try? fm.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)) ?? []
    }

    /// Vérifie l’existence d’un fichier/dossier relatif à Documents
    static func exists(relative path: String) -> Bool {
        FileManager.default.fileExists(atPath: documentsURL.appendingPathComponent(path).path)
    }

    /// Crée un dossier relatif à Documents
    static func makeDirectory(relative path: String) throws {
        let fm = FileManager.default
        let dir = documentsURL.appendingPathComponent(path, isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
    }
}
