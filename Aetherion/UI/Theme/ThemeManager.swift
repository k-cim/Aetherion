// === File: UI/Theme/ThemeManager.swift
// Rôle: Source unique du thème courant + pont de persistance (UserDefaults + JSON override)

// === File: UI/Theme/ThemeManager.swift

import SwiftUI

@MainActor
final class ThemeManager: ObservableObject {

    // Thème courant (source unique pour toute l’app)
    @Published var theme: Theme

    // Compat legacy (ancien code lit encore backgroundColor)
    var backgroundColor: Color { theme.background }

    // Persistance: ID du preset sélectionné
    private let ud = UserDefaults.standard
    private let selectedKey = "ae.selectedThemeID"

    // Persiste le thème courant sur disque (JSON)
    func persistCurrentThemeToDisk() {
        do {
            try StorageService.saveOverride(theme)
        } catch {
            #if DEBUG
            print("Theme persist error:", error)
            #endif
        }
    }

    // Recharge un override depuis le disque et l’applique (si présent)
    func loadOverrideFromDiskIfAny() {
        if let t = StorageService.loadOverride() {
            self.theme = t
        }
    }
    // MARK: - Override disque (JSON)
    func saveDiskOverride() {
        // Sauvegarde le thème courant dans ~/Library/Application Support/Aetherion/theme.json
        do {
            try ThemeOverrideDiskStore.save(theme: self.theme)
        } catch {
            print("ThemeManager.saveDiskOverride error:", error)
        }
    }

    func clearDiskOverride() {
        // Supprime le fichier d’override
        do {
            try ThemeOverrideDiskStore.clear()
        } catch {
            print("ThemeManager.clearDiskOverride error:", error)
        }
    }

    func reloadDiskOverrideIfPresent() {
        // Recharge l’override s’il existe (sinon ne fait rien)
        if let t = ThemeOverrideDiskStore.load() {
            self.theme = t
        }
    }
    // MARK: - Init
    init(default id: ThemeID) {
        // 🔑 On charge d’abord l’ID sauvegardé (UserDefaults), sinon celui passé en param
        let savedID = StorageService.loadSelectedThemeID(default: id)

        // Base = preset correspondant
        var base = Theme.preset(savedID)

        // S’il existe un override JSON et que son ID correspond → on remplace
        if let override = StorageService.loadOverride(), override.id == savedID {
            base = override
        }

        // On publie le thème de départ
        self.theme = base
    }

    // MARK: - Application / mise à jour

    /// Applique un thème complet arbitraire (ex: depuis ThemeConfigView).
    func applyTheme(_ theme: Theme, persistToJSON: Bool = true) {
        self.theme = theme
        if persistToJSON {
            StorageService.saveSelectedThemeID(theme.id)
            try? StorageService.saveOverride(theme)
        }
    }

    /// Applique un preset par ID (utilisé par ThemeDefautlView).
    func applyID(_ id: ThemeID, persist: Bool = true) {
        let t = Theme.preset(id)
        self.theme = t
        if persist {
            StorageService.saveSelectedThemeID(id)
            try? StorageService.saveOverride(t)
        }
    }

    // MARK: - Setters "live" pour ThemeConfigView

    func updateBackgroundColor(_ color: Color) { theme.background = color }
    func updateCardGradient(start: Double, end: Double) {
        theme.cardStartOpacity = start
        theme.cardEndOpacity   = end
    }
    func updateGradientColors(start: Color, end: Color) {
        theme.cardStartColor = start
        theme.cardEndColor   = end
    }
    func updateHeaderColor(_ color: Color) { theme.headerColor = color }
    func updatePrimaryTextColor(_ color: Color) { theme.foreground = color }
    func updateSecondaryTextColor(_ color: Color) { theme.secondary = color }
    func updateIconColor(_ color: Color) { theme.accent = color }
    func updateControlTint(_ color: Color) { theme.controlTint = color }
}
