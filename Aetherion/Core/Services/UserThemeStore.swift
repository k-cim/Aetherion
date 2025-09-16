// === File: Core/Services/UserThemeStore.swift
// Version: 2.0
// Date: 2025-09-14
// Rôle : façade simple pour consommer les thèmes découverts (bundle + Documents)
//        + l’override disque. Utilise ThemeCatalog + ThemeOverrideDiskStore uniquement.

import Foundation
import SwiftUI

enum UserThemeStore {

    // MARK: - Listing

    /// Liste les thèmes disponibles (bundle/Themes, bundle root, Documents/Themes),
    /// via ThemeCatalog (items = nom affiché + fileURL).
    static func availableThemes() -> [ThemeListItem] {
        ThemeCatalog.shared.listThemes()
    }

    // MARK: - Display name

    /// Nom convivial pour un ThemeID, priorisant le nom issu des JSON présents.
    static func displayName(for id: ThemeID) -> String {
        if let item = availableThemes().first(where: { $0.id == id.rawValue }) {
            return item.displayName
        }
        // Fallback : formate le rawValue (ex: aetherionDark -> Aetherion Dark)
        return prettify(raw: id.rawValue)
    }

    // MARK: - Loading

    /// Charge un Theme pour un ID en suivant l’ordre :
    /// 1) override disque (si même ID)
    /// 2) fichier JSON correspondant dans le catalogue
    /// 3) preset code
    static func loadTheme(for id: ThemeID) -> Theme {
        if let override = ThemeOverrideDiskStore.load(), override.id == id {
            return override
        }
        if let item = availableThemes().first(where: { $0.id == id.rawValue }) {
            return ThemeCatalog.shared.loadTheme(from: item)
        }
        return Theme.preset(id)
    }

    // MARK: - Utils

    private static func prettify(raw: String) -> String {
        // Remplace "_" par espaces, insère un espace après "Aetherion" si besoin, capitalise.
        raw.replacingOccurrences(of: "_", with: " ")
           .replacingOccurrences(of: "aetherion", with: "Aetherion ")
           .trimmingCharacters(in: .whitespaces)
           .capitalized
    }
}
