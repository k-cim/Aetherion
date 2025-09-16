// === File: Core/Services/ThemeBundleStore.swift
// Rôle :
// - lister les thèmes JSON packagés (id, nom, url)
// - charger un Theme depuis un ThemeID (priorité au JSON si présent)
// - charger un Theme depuis une URL de JSON (avec fallbackID optionnel)
// Mapping minimal: background, cards (couleurs/opacités/radius), text (header/body/secondary),
// icons.color -> accent, controls.tint -> controlTint.

import Foundation
import SwiftUI

enum ThemeBundleStore {

    // --- Public: info minimale pour la roue ---
    struct ThemeInfo: Identifiable, Equatable {
        var id: String { rawID }            // pour ForEach
        let themeID: ThemeID?               // si convertible depuis rawID
        let rawID: String                   // "aetherionBlue", "neo", ...
        let name: String                    // affichage
        let url: URL                        // emplacement dans le bundle
    }

    // --- Schémas JSON ---
    private struct HeaderSchema: Decodable {
        struct Meta: Decodable { let name: String? }
        let id: String
        let name: String?
        let meta: Meta?
    }
    private struct FullSchema: Decodable {
        let id: String
        let name: String?
        struct BG: Decodable {
            let style: String?
            let color: String?
            struct Grad: Decodable {
                let startColor: String?
                let endColor:   String?
                let startOpacity: Double?
                let endOpacity:   Double?
            }
            let gradient: Grad?
        }
        struct Cards: Decodable {
            let startColor: String?
            let endColor:   String?
            let startOpacity: Double?
            let endOpacity:   Double?
            let cornerRadius: Double?
        }
        struct TextBlock: Decodable {
            struct Item: Decodable { let color: String?; let size: Double?; let weight: String?; let design: String? }
            let header:   Item?
            let body:     Item?
            let secondary: Item?
        }
        struct Icons: Decodable { let color: String? }
        struct Controls: Decodable { let tint: String? }

        let background: BG?
        let cards: Cards?
        let text: TextBlock?
        let icons: Icons?
        let controls: Controls?
    }

    // MARK: - Public API

    /// Liste toutes les defs JSON des thèmes dans le bundle (cherche dans plusieurs sous-dossiers courants).
    static func list() -> [ThemeInfo] {
        var urls: [URL] = []
        let candidates = [
            "Resource/Theme/BuiltIn", // ton chemin
            "Resources/Themes",
            "Themes",
            nil
        ]
        for sub in candidates {
            if let found = Bundle.main.urls(forResourcesWithExtension: "json", subdirectory: sub) {
                urls.append(contentsOf: found)
            }
        }
        // Fallback: parcours récursif si rien trouvé
        if urls.isEmpty, let root = Bundle.main.resourceURL {
            if let en = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil) {
                for case let u as URL in en where u.pathExtension.lowercased() == "json" {
                    urls.append(u)
                }
            }
        }

        let unique = Array(Set(urls))
        var out: [ThemeInfo] = []
        let dec = JSONDecoder()

        for url in unique {
            guard let data = try? Data(contentsOf: url),
                  let head = try? dec.decode(HeaderSchema.self, from: data)
            else { continue }
            let rawID = head.id
            let name  = head.name ?? head.meta?.name ?? rawID
            let tid   = ThemeID(rawValue: rawID)
            out.append(.init(themeID: tid, rawID: rawID, name: name, url: url))
        }

        out.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return out
    }

    /// Charge un Theme pour un ThemeID : JSON du bundle s’il existe, sinon preset code.
    static func loadTheme(id: ThemeID) -> Theme {
        if let info = list().first(where: { $0.themeID == id }) {
            return loadTheme(from: info.url, fallbackID: id) ?? Theme.preset(id)
        }
        return Theme.preset(id)
    }

    /// Charge un Theme depuis un fichier JSON du bundle.
    /// - Parameters:
    ///   - url: URL du .json
    ///   - fallbackID: utiliser ce preset comme base si possible (sinon .aetherionDark)
    static func loadTheme(from url: URL, fallbackID: ThemeID?) -> Theme? {
        guard let data = try? Data(contentsOf: url),
              let schema = try? JSONDecoder().decode(FullSchema.self, from: data)
        else { return nil }

        // Base: si l’id du JSON mappe ThemeID, on part de ce preset, sinon fallback (ou dark)
        let baseID = ThemeID(rawValue: schema.id) ?? fallbackID ?? .aetherionDark
        var t = Theme.preset(baseID)

        // Background (couleur unie + dégradé des cartes dans "background.gradient")
        if let bg = schema.background {
            if let c = bg.color, let col = color(from: c) { t.background = col }
            if let g = bg.gradient {
                if let sc = g.startColor, let col = color(from: sc) { t.cardStartColor = col }
                if let ec = g.endColor,   let col = color(from: ec) { t.cardEndColor   = col }
                if let so = g.startOpacity { t.cardStartOpacity = so }
                if let eo = g.endOpacity   { t.cardEndOpacity   = eo }
            }
        }

        // Cards
        if let c = schema.cards {
            if let sc = c.startColor, let col = color(from: sc) { t.cardStartColor = col }
            if let ec = c.endColor,   let col = color(from: ec) { t.cardEndColor   = col }
            if let so = c.startOpacity { t.cardStartOpacity = so }
            if let eo = c.endOpacity   { t.cardEndOpacity   = eo }
            if let cr = c.cornerRadius { t.cornerRadius = CGFloat(cr) }
        }

        // Text
        if let text = schema.text {
            if let h = text.header?.color, let col = color(from: h) { t.headerColor = col }
            if let b = text.body?.color,   let col = color(from: b) { t.foreground  = col }
            if let s = text.secondary?.color, let col = color(from: s) { t.secondary = col }
        }

        // Icons -> accent
        if let ic = schema.icons?.color, let col = color(from: ic) {
            t.accent = col
        }

        // Controls -> controlTint
        if let ct = schema.controls?.tint, let col = color(from: ct) {
            t.controlTint = col
        }

        return t
    }

    // MARK: - Helpers

    /// "#RRGGBB", "#RRGGBBAA" ou "rgba(r,g,b,a)" -> Color (sRGB)
    private static func color(from s: String) -> Color? {
        let str = s.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        if str.hasPrefix("rgba") {
            let nums = str
                .replacingOccurrences(of: "rgba", with: "")
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            guard nums.count == 4,
                  let r = Double(nums[0]),
                  let g = Double(nums[1]),
                  let b = Double(nums[2]),
                  let a = Double(nums[3]) else { return nil }
            return Color(.sRGB, red: r/255.0, green: g/255.0, blue: b/255.0, opacity: a)
        }

        var hex = str
        if hex.hasPrefix("#") { hex.removeFirst() }
        guard hex.count == 6 || hex.count == 8 else { return nil }

        var value: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&value) else { return nil }

        let r, g, b, a: Double
        if hex.count == 8 {
            r = Double((value & 0xFF00_0000) >> 24) / 255.0
            g = Double((value & 0x00FF_0000) >> 16) / 255.0
            b = Double((value & 0x0000_FF00) >> 8)  / 255.0
            a = Double( value & 0x0000_00FF)        / 255.0
        } else {
            r = Double((value & 0xFF0000) >> 16) / 255.0
            g = Double((value & 0x00FF00) >> 8)  / 255.0
            b = Double( value & 0x0000FF)       / 255.0
            a = 1.0
        }
        return Color(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
}
