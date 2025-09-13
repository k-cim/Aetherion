// === File: Core/Services/ThemeOverrideDiskStore.swift
// Sauvegarde/lecture d'un thème custom dans ~/Library/Application Support/Aetherion/theme.json

import SwiftUI

enum ThemeOverrideDiskStore {
    // ~/Library/Application Support/Aetherion/theme.json
    private static var url: URL = {
        let fm = FileManager.default
        let base = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let dir  = base.appendingPathComponent("Aetherion", isDirectory: true)
        if !fm.fileExists(atPath: dir.path) { try? fm.createDirectory(at: dir, withIntermediateDirectories: true) }
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
        try data.write(to: url, options: Data.WritingOptions.atomic)
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
        if fm.fileExists(atPath: url.path) { try fm.removeItem(at: url) }
    }
}

#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

private extension Color {
    // ✅ Version confirmée (ta correction Xcode) — ne plus toucher
    func rgba() -> ThemeOverrideDiskStore.RGBA {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return .init(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
        #elseif canImport(AppKit)
        let ns = NSColor(self).usingColorSpace(.deviceRGB)
            ?? NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 1)
        return .init(r: Double(ns.redComponent), g: Double(ns.greenComponent), b: Double(ns.blueComponent), a: Double(ns.alphaComponent))
        #else
        return .init(r: 1, g: 1, b: 1, a: 1)
        #endif
    }

    static func rgba(_ c: ThemeOverrideDiskStore.RGBA) -> Color {
        Color(.sRGB, red: c.r, green: c.g, blue: c.b, opacity: c.a)
    }
}

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
        case .default: return "default"
        case .serif: return "serif"
        case .rounded: return "rounded"
        case .monospaced: return "monospaced"
        @unknown default: return "default"
        }
    }
    static func from(_ name: String) -> Font.Design? {
        switch name.lowercased() {
        case "default": return .default
        case "serif": return .serif
        case "rounded": return .rounded
        case "monospaced": return .monospaced
        default: return nil
        }
    }
}
