// === File: Core/Services/UserThemeStore.swift
// Liste et charge les thèmes JSON enregistrés par l’utilisateur dans
// ~/Library/Application Support/Aetherion/UserThemes/*.json

import SwiftUI

enum UserThemeStore {
    /// Dossier des thèmes utilisateur
    static var directoryURL: URL = {
        let fm = FileManager.default
        let base = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir  = base.appendingPathComponent("Aetherion/UserThemes", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }()

    struct Entry: Identifiable {
        var id: String        // schema.id ou nom de fichier
        var name: String      // schema.name ou nom de fichier
        var url: URL
    }

    /// Retourne la liste des fichiers .json valides (id + name)
    static func list() -> [Entry] {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil)
        else { return [] }

        return files.compactMap { url in
            guard url.pathExtension.lowercased() == "json",
                  let data = try? Data(contentsOf: url),
                  let schema = try? JSONDecoder().decode(ThemeBundleSchema.self, from: data)
            else {
                // JSON illisible → ignorer
                return nil
            }
            let id    = schema.id
            let name  = schema.name ?? url.deletingPathExtension().lastPathComponent
            return Entry(id: id, name: name, url: url)
        }
    }

    /// Charge un Theme à partir d’un fichier JSON
    static func loadTheme(url: URL) -> Theme? {
        guard let data = try? Data(contentsOf: url),
              let schema = try? JSONDecoder().decode(ThemeBundleSchema.self, from: data),
              let id = ThemeID(rawValue: schema.id) ?? ThemeID(rawValue: schema.id) // accepte aussi des IDs inconnus (on tombera sur un preset proche)
        else { return nil }

        // Décode via la même logique que pour le bundle
        // On réutilise le décodeur de ThemeBundleStore pour éviter la duplication.
        return ThemeBundleStore.loadThemeFromSchema(schema, fallbackID: id)
    }
}
