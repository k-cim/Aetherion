// === File: UI/Theme/ThemeCatalog+List.swift
// Rôle: découverte des JSON de thèmes + chargement en Theme (sans redéfinitions multiples)

import SwiftUI
import Foundation

// MARK: - Item de liste pour la roue
struct ThemeListItem: Identifiable, Hashable {
    public let id: String            // identifiant (souvent = filename sans extension)
    public let displayName: String   // nom affiché
    public let fileURL: URL          // URL du JSON (ou /dev/null pour presets)
}

// MARK: - DTO souple (tous optionnels) pour tolérer des JSON partiels
private struct ThemeEntryDTO: Decodable {
    var id: String?
    var displayName: String?

    // Couleurs de base
    var background: String?
    var foreground: String?
    var secondary: String?
    var accent: String?
    var controlTint: String?

    // Cartes (dégradés)
    var cardStartOpacity: Double?
    var cardEndOpacity: Double?
    var cardStartColor: String?
    var cardEndColor: String?
    var cornerRadius: Double?

    // Titres
    var headerFontSize: Double?
    var headerFontWeight: String?
    var headerFontDesign: String?
    var headerColor: String?
}

// MARK: - Convertisseurs locaux
private enum TConv {
    static func color(_ raw: String?, default def: Color) -> Color {
        guard let s0 = raw?.trimmingCharacters(in: .whitespacesAndNewlines), !s0.isEmpty else {
            return def
        }
        if s0.hasPrefix("#") { return Color(hex: s0) }
        switch s0.lowercased() {
        case "black": return .black
        case "white": return .white
        case "gray", "grey": return .gray
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        default: return def
        }
    }

    static func weight(_ raw: String?, default def: Font.Weight) -> Font.Weight {
        switch (raw ?? "").lowercased() {
        case "ultralight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "regular":    return .regular
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        case "black":      return .black
        default:           return def
        }
    }

    static func design(_ raw: String?, default def: Font.Design) -> Font.Design {
        switch (raw ?? "").lowercased() {
        case "rounded":     return .rounded
        case "serif":       return .serif
        case "monospaced",
             "mono":        return .monospaced
        default:            return def
        }
    }
}

// MARK: - Une SEULE implémentation Color(hex:)
private extension Color {
    /// Accepte "#RRGGBB" ou "#RRGGBBAA"
    init(hex: String) {
        var s = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }

        var v: UInt64 = 0
        Scanner(string: s).scanHexInt64(&v)

        let r, g, b, a: Double
        switch s.count {
        case 6:
            r = Double((v & 0xFF0000) >> 16) / 255.0
            g = Double((v & 0x00FF00) >> 8)  / 255.0
            b = Double( v & 0x0000FF)        / 255.0
            a = 1.0
        case 8:
            r = Double((v & 0xFF000000) >> 24) / 255.0
            g = Double((v & 0x00FF0000) >> 16) / 255.0
            b = Double((v & 0x0000FF00) >> 8)  / 255.0
            a = Double( v & 0x000000FF)        / 255.0
        default:
            r = 0; g = 0; b = 0; a = 1
        }
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}

// MARK: - Loader JSON strict (schéma complet)
private struct ThemeJSONLoader {
    struct ThemeFile: Decodable {
        let id: String
        let name: String
        let background: String
        let foreground: String
        let secondary: String
        let accent: String
        let controlTint: String
        let cardStartColor: String
        let cardEndColor: String
        let cardStartOpacity: Double
        let cardEndOpacity: Double
        let cornerRadius: Double
        let headerColor: String
        let headerFontSize: Double
        let headerFontWeight: String
        let headerFontDesign: String
    }

    func loadTheme(from url: URL) throws -> Theme {
        let data = try Data(contentsOf: url)
        let decoded = try JSONDecoder().decode(ThemeFile.self, from: data)

        return Theme(
            id: ThemeID(rawValue: decoded.id) ?? .aetherionDark,
            background: Color(hex: decoded.background),
            foreground: Color(hex: decoded.foreground),
            secondary: Color(hex: decoded.secondary),
            accent: Color(hex: decoded.accent),
            controlTint: Color(hex: decoded.controlTint),
            cardStartOpacity: decoded.cardStartOpacity,
            cardEndOpacity: decoded.cardEndOpacity,
            cardStartColor: Color(hex: decoded.cardStartColor),
            cardEndColor: Color(hex: decoded.cardEndColor),
            cornerRadius: decoded.cornerRadius,
            headerFontSize: decoded.headerFontSize,
            headerFontWeight: {
                switch decoded.headerFontWeight.lowercased() {
                case "ultralight": return .ultraLight
                case "thin":       return .thin
                case "light":      return .light
                case "regular":    return .regular
                case "medium":     return .medium
                case "semibold":   return .semibold
                case "bold":       return .bold
                case "heavy":      return .heavy
                case "black":      return .black
                default:           return .bold
                }
            }(),
            headerFontDesign: {
                switch decoded.headerFontDesign.lowercased() {
                case "rounded": return .rounded
                case "serif":   return .serif
                case "mono",
                     "monospaced":
                    return .monospaced
                default:        return .default
                }
            }(),
            headerColor: Color(hex: decoded.headerColor)
        )
    }
}

// MARK: - Singleton de catalogue
final class ThemeCatalog {
    public static let shared = ThemeCatalog()
    private init() {}

    /// Retourne les thèmes découverts dans `Themes.bundle/Contents/Resources/Themes/`,
    /// dans le bundle racine et dans `Documents/Themes`.
    public func listThemes() -> [ThemeListItem] {
        var items: [ThemeListItem] = []
        let fm = FileManager.default

        // 0) Sous-dossier bundle "Themes" (folder reference BLEU)
        if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: "Themes") {
            for url in urls {
                let name = url.deletingPathExtension().lastPathComponent
                items.append(ThemeListItem(id: name, displayName: name, fileURL: url))
            }
        }

        // 1) Bundle racine (si pas dans "Themes")
        if let urls = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: nil) {
            for url in urls {
                let name = url.deletingPathExtension().lastPathComponent
                if !items.contains(where: { $0.id == name }) {
                    items.append(ThemeListItem(id: name, displayName: name, fileURL: url))
                }
            }
        }

        // 2) Documents/Themes (runtime)
        if let docs = fm.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dir = docs.appendingPathComponent("Themes", isDirectory: true)
            if !fm.fileExists(atPath: dir.path) {
                try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
            }
            if let urls = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil) {
                for url in urls where url.pathExtension.lowercased() == "json" {
                    let name = url.deletingPathExtension().lastPathComponent
                    if !items.contains(where: { $0.id == name }) {
                        items.append(ThemeListItem(id: name, displayName: name, fileURL: url))
                    }
                }
            }
        }

        items.sort { $0.displayName.localizedCaseInsensitiveCompare($1.displayName) == .orderedAscending }
        // Debug utile si la roue reste vide
        print("🧩 ThemeCatalog.listThemes() -> \(items.count) item(s)")
        items.forEach { print("   • \($0.displayName) @ \($0.fileURL.lastPathComponent)") }

        // Fallback : si aucun JSON trouvé, on propose les presets intégrés
        if items.isEmpty {
            return builtInPresetsAsListItems()
        }
        return items
    }

    /// Fallback intégrés (aucun JSON trouvé)
    public func builtInPresetsAsListItems() -> [ThemeListItem] {
        let ids: [ThemeID] = [.aetherionDark, .aetherionLight, .aetherionBlue, .aetherionSepia, .aetherionEmerald]
        return ids.map { id in
            ThemeListItem(id: id.rawValue, displayName: id.rawValue, fileURL: URL(fileURLWithPath: "/dev/null"))
        }
    }

    /// Charge un thème depuis un item (JSON strict → JSON souple DTO → preset)
    public func loadTheme(from item: ThemeListItem) -> Theme {
        // Presets intégrés
        if item.fileURL.path == "/dev/null" {
            let id = ThemeID(rawValue: item.id) ?? .aetherionDark
            return Theme.preset(id)
        }

        // 1) Essai schéma strict
        if let loaded = try? ThemeJSONLoader().loadTheme(from: item.fileURL) {
            return loaded
        }

        // 2) Essai schéma "souple" (DTO avec optionnels)
        if let data = try? Data(contentsOf: item.fileURL),
           let dto = try? JSONDecoder().decode(ThemeEntryDTO.self, from: data) {
            return map(dto: dto, fileFallbackID: item.id)
        }

        // 3) Fallback final par nom
        return Theme.preset(ThemeID(rawValue: item.id) ?? .aetherionDark)
    }

    // mapping DTO -> Theme (privé)
    private func map(dto: ThemeEntryDTO, fileFallbackID: String) -> Theme {
        var base = Theme.preset(.aetherionDark)

        // ID
        let rawID = dto.id ?? fileFallbackID
        if let tid = ThemeID(rawValue: rawID) {
            base.id = tid
        } else {
            base.id = .aetherionDark
        }

        // Couleurs de base
        base.background   = TConv.color(dto.background,   default: base.background)
        base.foreground   = TConv.color(dto.foreground,   default: base.foreground)
        base.secondary    = TConv.color(dto.secondary,    default: base.secondary)
        base.accent       = TConv.color(dto.accent,       default: base.accent)
        base.controlTint  = TConv.color(dto.controlTint,  default: base.controlTint)

        // Dégradés cartes
        if let s = dto.cardStartOpacity { base.cardStartOpacity = max(0, min(1, s)) }
        if let e = dto.cardEndOpacity   { base.cardEndOpacity   = max(0, min(1, e)) }
        base.cardStartColor = TConv.color(dto.cardStartColor, default: base.cardStartColor)
        base.cardEndColor   = TConv.color(dto.cardEndColor,   default: base.cardEndColor)
        if let r = dto.cornerRadius { base.cornerRadius = CGFloat(max(0, r)) }

        // Titres
        if let sz = dto.headerFontSize { base.headerFontSize = CGFloat(max(8, sz)) }
        base.headerFontWeight = TConv.weight(dto.headerFontWeight, default: base.headerFontWeight)
        base.headerFontDesign = TConv.design(dto.headerFontDesign, default: base.headerFontDesign)
        base.headerColor      = TConv.color(dto.headerColor, default: base.headerColor)

        return base
    }
}
