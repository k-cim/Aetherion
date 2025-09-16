// === File: Core/Services/ThemeOverrideDiskStore.swift
// Rôle: Sauvegarde/lecture d’un thème custom dans ~/Library/Application Support/Aetherion/theme.json
// Notes (patch):
// - Plus de `try!` pour construire l’URL : fallback robuste (Documents → /tmp).
// - Création de dossier tolérante aux erreurs.
// - Conversion Color → RGBA plus sûre (fallback si getRed échoue).

import SwiftUI
import Foundation

enum ThemeOverrideDiskStore {

    private static let mirrorKey = "ae.override.mirror"
    // ~/Library/Application Support/Aetherion/theme.json
    private static var url: URL = {
        let fm = FileManager.default
        // 1) Base: Application Support (fallback Documents → /tmp)
        let base: URL = (try? fm.url(for: .applicationSupportDirectory,
                                     in: .userDomainMask,
                                     appropriateFor: nil,
                                     create: true))
        ?? fm.urls(for: .documentDirectory, in: .userDomainMask).first
        ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)

        // 2) Dossier app
        let dir = base.appendingPathComponent("Aetherion", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) {
            // si la création échoue, on retombe sur /tmp/Aetherion
            do {
                try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            } catch {
                let tmp = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                    .appendingPathComponent("Aetherion", isDirectory: true)
                try? fm.createDirectory(at: tmp, withIntermediateDirectories: true)
                return tmp.appendingPathComponent("theme.json")
            }
        }
        return dir.appendingPathComponent("theme.json")
    }()

    // DTO JSON
    struct RGBA: Codable { var r: Double; var g: Double; var b: Double; var a: Double }

    struct OverrideDTO: Codable {
        var id: String
        var background: RGBA
        var foreground: RGBA
        var secondary: RGBA
        var accent: RGBA
        var controlTint: RGBA
        var cardStartOpacity: Double
        var cardEndOpacity: Double
        var cardStartColor: RGBA
        var cardEndColor: RGBA
        var cornerRadius: Double
        var headerFontSize: Double
        var headerFontWeight: String
        var headerFontDesign: String
        var headerColor: RGBA
    }

    // MARK: - API
    static func save(theme t: Theme) throws {
        let dto = OverrideDTO(
            id: t.id.rawValue,
            background: t.background.rgba(),
            foreground: t.foreground.rgba(),
            secondary: t.secondary.rgba(),
            accent: t.accent.rgba(),
            controlTint: t.controlTint.rgba(),
            cardStartOpacity: t.cardStartOpacity,
            cardEndOpacity: t.cardEndOpacity,
            cardStartColor: t.cardStartColor.rgba(),
            cardEndColor: t.cardEndColor.rgba(),
            cornerRadius: Double(t.cornerRadius),
            headerFontSize: Double(t.headerFontSize),
            headerFontWeight: t.headerFontWeight.name,
            headerFontDesign: t.headerFontDesign.name,
            headerColor: t.headerColor.rgba()
        )
        // --- dans save(theme:) après avoir créé le dto ---
        let data = try JSONEncoder().encode(dto)
        try data.write(to: url, options: .atomic)

        // 🔁 miroir UserDefaults pour survivre aux réinstallations accidentelles du container
        UserDefaults.standard.set(data, forKey: mirrorKey)
    }

    // --- ajoute cette fonction helper ---
    static func loadOrMirror() -> Theme? {
        // 1) fichier
        if let t = load() { return t }
        // 2) miroir UserDefaults
        guard
            let data = UserDefaults.standard.data(forKey: mirrorKey),
            let dto  = try? JSONDecoder().decode(OverrideDTO.self, from: data),
            let id   = ThemeID(rawValue: dto.id)
        else { return nil }

        var t = Theme.preset(id)
        t.background       = Color.rgba(dto.background)
        t.foreground       = Color.rgba(dto.foreground)
        t.secondary        = Color.rgba(dto.secondary)
        t.accent           = Color.rgba(dto.accent)
        t.controlTint      = Color.rgba(dto.controlTint)
        t.cardStartOpacity = dto.cardStartOpacity
        t.cardEndOpacity   = dto.cardEndOpacity
        t.cardStartColor   = Color.rgba(dto.cardStartColor)
        t.cardEndColor     = Color.rgba(dto.cardEndColor)
        t.cornerRadius     = CGFloat(dto.cornerRadius)
        t.headerFontSize   = CGFloat(dto.headerFontSize)
        t.headerFontWeight = Font.Weight.from(dto.headerFontWeight) ?? t.headerFontWeight
        t.headerFontDesign = Font.Design.from(dto.headerFontDesign) ?? t.headerFontDesign
        t.headerColor      = Color.rgba(dto.headerColor)
        return t
    }
    
    static func load() -> Theme? {
        guard let data = try? Data(contentsOf: url),
              let dto  = try? JSONDecoder().decode(OverrideDTO.self, from: data),
              let id   = ThemeID(rawValue: dto.id) else { return nil }

        var t = Theme.preset(id)
        t.background       = Color.rgba(dto.background)
        t.foreground       = Color.rgba(dto.foreground)
        t.secondary        = Color.rgba(dto.secondary)
        t.accent           = Color.rgba(dto.accent)
        t.controlTint      = Color.rgba(dto.controlTint)
        t.cardStartOpacity = dto.cardStartOpacity
        t.cardEndOpacity   = dto.cardEndOpacity
        t.cardStartColor   = Color.rgba(dto.cardStartColor)
        t.cardEndColor     = Color.rgba(dto.cardEndColor)
        t.cornerRadius     = CGFloat(dto.cornerRadius)
        t.headerFontSize   = CGFloat(dto.headerFontSize)
        t.headerFontWeight = Font.Weight.from(dto.headerFontWeight) ?? t.headerFontWeight
        t.headerFontDesign = Font.Design.from(dto.headerFontDesign) ?? t.headerFontDesign
        t.headerColor      = Color.rgba(dto.headerColor)
        return t
    }

    static func clear() throws {
        let fm = FileManager.default
        if fm.fileExists(atPath: url.path) {
            try fm.removeItem(at: url)
        }
    }

    // Pour debug (retourne l’URL actuelle)
    static func fileURL() -> URL { url }
}

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - Helpers

private extension Color {
    func rgba() -> ThemeOverrideDiskStore.RGBA {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 1, g: CGFloat = 1, b: CGFloat = 1, a: CGFloat = 1
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return .init(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
        } else {
            // Fallback blanc si non convertible (patterns, etc.)
            return .init(r: 1, g: 1, b: 1, a: 1)
        }
        #elseif canImport(AppKit)
        guard let ns = NSColor(self).usingColorSpace(.deviceRGB) else {
            return .init(r: 1, g: 1, b: 1, a: 1)
        }
        return .init(r: Double(ns.redComponent),
                     g: Double(ns.greenComponent),
                     b: Double(ns.blueComponent),
                     a: Double(ns.alphaComponent))
        #else
        return .init(r: 1, g: 1, b: 1, a: 1)
        #endif
    }

    static func rgba(_ c: ThemeOverrideDiskStore.RGBA) -> Color {
        Color(.sRGB, red: c.r, green: c.g, blue: c.b, opacity: c.a)
    }
}

// MARK: - Font extensions (UNE SEULE FOIS)

extension Font.Weight {
    var name: String {
        switch self {
        case .ultraLight: return "ultraLight"
        case .thin:       return "thin"
        case .light:      return "light"
        case .regular:    return "regular"
        case .medium:     return "medium"
        case .semibold:   return "semibold"
        case .bold:       return "bold"
        case .heavy:      return "heavy"
        case .black:      return "black"
        default:          return "regular"
        }
    }

    static func from(_ string: String) -> Font.Weight? {
        switch string.lowercased() {
        case "ultralight": return .ultraLight
        case "thin":       return .thin
        case "light":      return .light
        case "regular":    return .regular
        case "medium":     return .medium
        case "semibold":   return .semibold
        case "bold":       return .bold
        case "heavy":      return .heavy
        case "black":      return .black
        default:           return nil
        }
    }
}

extension Font.Design {
    var name: String {
        switch self {
        case .default:    return "default"
        case .serif:      return "serif"
        case .rounded:    return "rounded"
        case .monospaced: return "monospaced"
        @unknown default: return "default"
        }
    }

    static func from(_ string: String) -> Font.Design? {
        switch string.lowercased() {
        case "default":    return .default
        case "serif":      return .serif
        case "rounded":    return .rounded
        case "monospaced": return .monospaced
        default:           return nil
        }
    }
}
// DEBUG: petit self-test d’E/S pour valider le répertoire + écriture JSON
#if DEBUG
extension ThemeOverrideDiskStore {
    static func _debugSelfTest() {
        let url = fileURL()
        print("🧪 ThemeOverrideDiskStore.selfTest → fileURL =", url.path)

        // Vérifie existence dossier parent
        let parent = url.deletingLastPathComponent()
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: parent.path, isDirectory: &isDir)
        print("   parent exists =", exists, "isDir =", isDir.boolValue)

        // Essaye une écriture “inoffensive”
        let payload = Data("{\"ping\":\"ok\"}".utf8)
        do {
            try payload.write(to: url, options: .atomic)
            print("   write OK →", url.lastPathComponent)
            // Nettoyage (optionnel)
            try? FileManager.default.removeItem(at: url)
            print("   cleanup OK")
        } catch {
            print("   ❌ write FAILED:", error.localizedDescription)
        }
    }
}
#endif
