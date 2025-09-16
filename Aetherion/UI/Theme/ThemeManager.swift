// === File: UI/Theme/ThemeManager.swift
// Version: 3.1 (clean, with aliases)
// Date: 2025-09-15
// Rôle : Source unique du thème pour toute l’app + persistance minimale (ID) +
//         autosave d’un brouillon (theme.json) pour survivre aux crashs.
//         Fournit une API d’édition : livePreview / commitTheme / restore.
//         ⚠️ Aucun type imbriqué/dupliqué. Conserve les alias bg/fg/sec/acc/hdr/ctl.

import SwiftUI

// UI/Theme/ThemeManager.swift

@MainActor
final class ThemeManager: ObservableObject {
    @Published var theme: Theme
    @Published var colorModified: Bool = false

    private let ud = UserDefaults.standard
    private let selectedKey = "ae.selectedThemeID"      // ThemeID (enum)
    private let lastRawKey  = "ae.lastSelectedRawID"    // rawID d’un JSON (bundle/Documents)

    // MARK: - Init (dernier thème utilisé)
    init(default id: ThemeID) {
        // 1) Override disque PRIORITAIRE (ou son miroir UserDefaults)
        if let override = ThemeOverrideDiskStore.loadOrMirror() {
            self.theme = override
            return
        }

        // 2) Dernier JSON “hors enum” (bundle/Documents)
        if let raw = UserDefaults.standard.string(forKey: "ae.lastSelectedRawID"),
           let item = ThemeCatalog.shared.listThemes().first(where: { $0.id == raw }) {
            self.theme = ThemeCatalog.shared.loadTheme(from: item)
            return
        }

        // 3) ID enum persisté
        let savedID = UserDefaults.standard.string(forKey: "ae.selectedThemeID").flatMap(ThemeID.init) ?? id
        self.theme = UserThemeStore.loadTheme(for: savedID)
    }

    // MARK: - Helpers pour mémoriser “dernier thème”
    func rememberLastBundle(rawID: String?) {
        if let rawID { ud.set(rawID, forKey: lastRawKey) }
        else { ud.removeObject(forKey: lastRawKey) }
    }

    // MARK: - API de changement rapide

    /// Applique un thème arbitraire (prévisualisation, test, etc. — LIVE).
    func applyTheme(_ t: Theme) {
        self.theme = t
    }

    /// Applique un thème par ID (prend en compte JSON bundle/override) et persiste l’ID si demandé.
    func applyID(_ id: ThemeID, persistID: Bool = true) {
        let t = UserThemeStore.loadTheme(for: id) // Override > bundle JSON > preset
        self.theme = t
        if persistID { ud.set(id.rawValue, forKey: selectedKey) }
        self.colorModified = false
    }

    /// 🔧 Back-compat : accepte encore `persist:` si des appels traînent
    @available(*, deprecated, message: "Use persistID: à la place.")
    func applyID(_ id: ThemeID, persist: Bool) {
        applyID(id, persistID: persist)
    }

    /// Persiste seulement l’ID sélectionné (sans recharger le thème courant).
    func persistSelectedID(_ id: ThemeID) {
        ud.set(id.rawValue, forKey: selectedKey)
    }

    /// Persiste le thème courant dans le JSON override (écrase/écrit le fichier).
    func persistCurrentThemeToDisk() {
        try? ThemeOverrideDiskStore.save(theme: theme)
    }

    // MARK: - Setters “live” (si on pousse propriété par propriété)

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

    // MARK: - Flags d’édition (utilisés par ThemeConfigView / ThemeDefaultView)

    /// Indique qu’une édition de couleurs est en cours (UI peut afficher “non enregistré”)
    func beginColorEditing() { colorModified = true }

    /// Alias historique si tu l’appelles déjà ailleurs
    func markModified() { colorModified = true }

    /// Indique qu’on a appliqué/annulé (plus “non enregistré”)
    func endColorEditing() { colorModified = false }

    // MARK: - Édition robuste (live preview, commit, restore)

    /// Applique un thème en **live** pendant l’édition (sans changer l’ID persistant).
    /// Si `autosave == true`, sauvegarde le brouillon dans theme.json pour survivre aux crashs.
    func livePreview(_ t: Theme, autosave: Bool = true) {
        self.theme = t
        self.colorModified = true
        if autosave {
            try? ThemeOverrideDiskStore.save(theme: t)
        }
    }

    /// Commit final : fixe le thème et, si `id` est fourni, persiste l’ID choisi.
    /// Sauvegarde également la palette actuelle dans theme.json.
    func commitTheme(_ t: Theme, id: ThemeID? = nil) {
        self.theme = t
        if let id {
            ud.set(id.rawValue, forKey: selectedKey)
        }
        try? ThemeOverrideDiskStore.save(theme: t)
        self.colorModified = false
    }

    /// Rollback complet à un snapshot (utilisé par Annuler/Retour).
    /// Écrit aussi le snapshot comme état courant (brouillon) pour cohérence.
    func restore(_ snapshot: Theme) {
        self.theme = snapshot
        self.colorModified = false
        try? ThemeOverrideDiskStore.save(theme: snapshot)
    }
}

// MARK: - Compat aliases (pour ne pas retoucher toutes les vues)
// ⚠️ Ce sont des alias en lecture. Continue d’utiliser `theme` pour modifier.

extension ThemeManager {
    // Couleurs “shorthand”
    var bg: Color { theme.background }
    var fg: Color { theme.foreground }
    var sec: Color { theme.secondary }
    var acc: Color { theme.accent }
    var hdr: Color { theme.headerColor }
    var ctl: Color { theme.controlTint }

    // Rayons
    var corner: CGFloat { theme.cornerRadius }

    // Gradients (ex: cartes)
    var cardGradient: LinearGradient {
        LinearGradient(
            colors: [
                theme.cardStartColor.opacity(theme.cardStartOpacity),
                theme.cardEndColor.opacity(theme.cardEndOpacity)
            ],
            startPoint: .leading, endPoint: .trailing
        )
    }

    // Background d’écran pratique (optionnel)
    @ViewBuilder
    var screenBackground: some View {
        theme.background.ignoresSafeArea()
    }
}
