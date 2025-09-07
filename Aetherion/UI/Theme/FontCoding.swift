// === File: UI/Theme/FontCoding.swift
// Description: Helpers pour (dé)coder Font.Weight / Font.Design

import SwiftUI

extension Font.Weight {
    static func from(string: String) -> Font.Weight {
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
        default:           return .regular
        }
    }
    func toString() -> String {
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
}

extension Font.Design {
    static func from(string: String) -> Font.Design {
        switch string.lowercased() {
        case "serif":      return .serif
        case "rounded":    return .rounded
        case "monospaced": return .monospaced
        default:           return .default
        }
    }
    func toString() -> String {
        switch self {
        case .serif:      return "serif"
        case .rounded:    return "rounded"
        case .monospaced: return "monospaced"
        default:          return "default"
        }
    }
}
