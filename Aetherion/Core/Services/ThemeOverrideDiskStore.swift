// === File: Core/Services/ThemeDiskStore.swift
// JSON override pour un thème complet (couleurs RGBA 0...1)

import SwiftUI

// DTO codable pour le JSON
private struct ThemeOverrideFile: Codable {
    var id: String
    struct RGBA: Codable { var r: Double; var g: Double; var b: Double; var a: Double }
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
    var headerFontWeight: String   // "regular", "bold", ...
    var headerFontDesign: String   // "default", "rounded", ...
    var headerColor: RGBA
}

enum ThemeDiskStore {
    // ~/Library/Application Support/Aetherion/theme.json
    private static var url: URL = {
        let fm = FileManager.default
        let base = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir = base.appendingPathComponent("Aetherion", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) { try? fm.createDirectory(at: dir, withIntermediateDirectories: true) }
        return dir.appendingPathComponent("theme.json")
    }()

    // MARK: - Public API

    static func save(theme t: Theme) throws {
        let dto = ThemeOverrideFile(
            id: t.id.rawValue,
            background: t.background.rgba(),
            foreground: t.foreground.rgba(),
            secondary:  t.secondary.rgba(),
            accent:     t.accent.rgba(),
            controlTint: t.controlTint.rgba(),
            cardStartOpacity: t.cardStartOpacity,
            cardEndOpacity:   t.cardEndOpacity,
            cardStartColor:   t.cardStartColor.rgba(),
            cardEndColor:     t.cardEndColor.rgba(),
            cornerRadius: Double(t.cornerRadius),
            headerFontSize: Double(t.headerFontSize),
            headerFontWeight: t.headerFontWeight.name,
            headerFontDesign: t.headerFontDesign.name,
            headerColor: t.headerColor.rgba()
        )
        let data = try JSONEncoder().encode(dto)
        try data.write(to: url, options: .atomic)
    }

    static func load() -> Theme? {
        guard let data = try? Data(contentsOf: url),
              let dto  = try? JSONDecoder().decode(ThemeOverrideFile.self, from: data),
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

    static func clear() {
        try? FileManager.default.removeItem(at: url)
    }
}

// MARK: - Color <-> RGBA helpers (fiables iOS/macOS)
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

private extension Color {
    /// Décompose une Color en RGBA (0...1) de façon cross-platform (OK Xcode : labels nommés)
    func rgba() -> ThemeOverrideFile.RGBA {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return ThemeOverrideFile.RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
        #elseif canImport(AppKit)
        let ns = NSColor(self).usingColorSpace(.deviceRGB)
            ?? NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
        return ThemeOverrideFile.RGBA(
            r: Double(ns.redComponent),
            g: Double(ns.greenComponent),
            b: Double(ns.blueComponent),
            a: Double(ns.alphaComponent)
        )
        #else
        return ThemeOverrideFile.RGBA(r: 1, g: 1, b: 1, a: 1)
        #endif
    }

    /// Reconstruit une Color à partir d’un RGBA (espace sRGB explicite)
    static func rgba(_ c: ThemeOverrideFile.RGBA) -> Color {
        Color(.sRGB, red: c.r, green: c.g, blue: c.b, opacity: c.a)
    }
}

// MARK: - Font helpers (nom <-> valeur)
private extension Font.Weight {
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
    static func from(_ name: String) -> Font.Weight? {
        switch name.lowercased() {
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

private extension Font.Design {
    var name: String {
        switch self {
        case .default:    return "default"
        case .serif:      return "serif"
        case .rounded:    return "rounded"
        case .monospaced: return "monospaced"
        @unknown default: return "default"
        }
    }
    static func from(_ name: String) -> Font.Design? {
        switch name.lowercased() {
        case "default":    return .default
        case "serif":      return .serif
        case "rounded":    return .rounded
        case "monospaced": return .monospaced
        default:           return nil
        }
    }
}
