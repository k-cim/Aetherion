# === File: UI/Theme/ThemeManager.swift
# Date: 2025-09-13 14:35:00 UTC
# Description: Source de vérité du thème (SwiftUI). Persiste l’ID du thème via UserDefaults,
#              charge/écrit un override JSON via ThemeOverrideDiskStore, expose un flag d’édition.

───────────────────────────────────────────────────────────────────────────────
SECTION: CONTEXTE & RÔLE
- Ce fichier définit la classe GLOBALE `ThemeManager` (ObservableObject, @MainActor).
- C’est LA source de vérité pour les couleurs dans l’app. Toutes les vues lisent
  `themeManager.theme` via @EnvironmentObject.
- Persistance:
  • ID du thème sélectionné → UserDefaults key "ae.selectedThemeID"
  • Détails (couleurs personnalisées) → fichier JSON géré par ThemeOverrideDiskStore
- Flag `colorModified` indique si un utilisateur édite des couleurs non enregistrées.

───────────────────────────────────────────────────────────────────────────────
SECTION: DÉPENDANCES EXTERNES (LUES/ÉCRITES)
- enum ThemeID (GLOBAL, externe) : identifiant d’un preset (.aetherionDark, …)
- struct Theme  (GLOBAL, externe) : toutes les couleurs/opacités/rayon, etc.
  • Accès: `Theme.preset(_:) -> Theme`
- enum ThemeOverrideDiskStore (GLOBAL, externe) : E/S JSON override utilisateur
  • `static func load() -> Theme?`
  • `static func save(theme: Theme) throws`
- Foundation.UserDefaults : stockage clé/valeur (ID de thème)
- SwiftUI.Color, CGFloat, etc. (types de base pour Theme)

───────────────────────────────────────────────────────────────────────────────
SECTION: CLASSE
CLASS: ThemeManager : ObservableObject  (GLOBAL)
ATTRIBUTS (tous publics au sens SwiftUI car @Published lisibles par l’UI)
- @Published var theme: Theme
  • SCOPE: GLOBAL (instance unique injectée dans l’App via @StateObject)
  • ÉCRIT PAR: ThemeManager (applyTheme, applyID, setters live, init)
  • LU   PAR: Toutes les vues via `@EnvironmentObject private var themeManager: ThemeManager`
  • EFFET: Re-render immédiat des vues SwiftUI
- @Published var colorModified: Bool = false
  • SCOPE: GLOBAL (flag UI)
  • ÉCRIT PAR: beginColorEditing(), markModified(), endColorEditing(), applyID(_:)
  • LU   PAR: ThemeDefautlView (pour afficher "Thème non enregistré", etc.)
- var backgroundColor: Color { theme.background }
  • SCOPE: GLOBAL (computed, lecture seule)
  • BUT: compatibilité avec ancien code qui lisait `backgroundColor`

PERSISTENCE INTERNE
- private let ud = UserDefaults.standard
- private let selectedKey = "ae.selectedThemeID"

───────────────────────────────────────────────────────────────────────────────
SECTION: INITIALISATION
init(default id: ThemeID)
INPUT :
- id : ThemeID (preset par défaut demandé par l’app au premier lancement)
PROCESS :
1) Cherche un ID existant en UserDefaults["ae.selectedThemeID"].
   - si présent et valide → `savedID`
   - sinon → `id` (paramètre)
2) Construit le thème de base via `Theme.preset(savedID)`.
3) Si un JSON override existe *ET* que son `override.id == savedID`, remplace `base`
   par cet override (couleurs utilisateur).
OUTPUT :
- Initialise `self.theme` avec `base`.
SIDE EFFECTS :
- Aucun write externe, seulement initialisation de l’état interne.

───────────────────────────────────────────────────────────────────────────────
SECTION: FONCTIONS (SIGNATURES / EFFETS / I/O)
1) func applyTheme(_ t: Theme)
   INPUT : Theme (arbitraire)
   OUTPUT: void
   SIDE  : Écrit GLOBAL `theme = t`.
           N’écrit PAS UserDefaults. Ne modifie PAS `colorModified`.
   USAGE : Preview live, Apply explicite depuis ThemeConfigView, etc.

2) func applyID(_ id: ThemeID, persistID: Bool = true)
   INPUT : id (preset à activer), persistID (par défaut true)
   OUTPUT: void
   SIDE  :
   - Construit `t = Theme.preset(id)`.
   - Si persistID == true → `ud.set(id.rawValue, forKey: "ae.selectedThemeID")`.
   - Écrit GLOBAL `theme = t`.
   - Réinitialise `colorModified = false` (on considère que l’état est propre).
   NOTES :
   - S’utilise depuis ThemeDefautlView quand l’utilisateur choisit un preset.

3) @available(*, deprecated) func applyID(_ id: ThemeID, persist: Bool)
   INPUT : (id, persist) — alias historique
   OUTPUT: void
   SIDE  : appelle `applyID(id, persistID: persist)`.

4) func persistCurrentThemeToDisk()
   INPUT : none (lit `self.theme`)
   OUTPUT: void
   SIDE  : Essaie `ThemeOverrideDiskStore.save(theme: theme)`.
           (Gestion d’erreur silencieuse → à logger si nécessaire.)
   USAGE : Depuis ThemeConfigView quand l’utilisateur valide.

SETTERS “LIVE” (écrivent PARTIES du `theme` GLOBAL)
5) func updateBackgroundColor(_ color: Color)
   SIDE : `theme.background = color` (re-render live)

6) func updateCardGradient(start: Double, end: Double)
   SIDE : `theme.cardStartOpacity = start`, `theme.cardEndOpacity = end`

7) func updateGradientColors(start: Color, end: Color)
   SIDE : `theme.cardStartColor = start`, `theme.cardEndColor = end`

8) func updateHeaderColor(_ color: Color)
   SIDE : `theme.headerColor = color`

9) func updatePrimaryTextColor(_ color: Color)
   SIDE : `theme.foreground = color`

10) func updateSecondaryTextColor(_ color: Color)
    SIDE : `theme.secondary = color`

11) func updateIconColor(_ color: Color)
    SIDE : `theme.accent = color`

12) func updateControlTint(_ color: Color)
    SIDE : `theme.controlTint = color`

FLAGS D’ÉDITION
13) func beginColorEditing()
    SIDE : `colorModified = true`
    USAGE: ThemeConfigView.onAppear ou au 1er changement de curseur

14) func markModified()
    SIDE : `colorModified = true`
    USAGE: alias si on veut marquer ponctuellement une modif

15) func endColorEditing()
    SIDE : `colorModified = false`
    USAGE: après “Appliquer” ou “Annuler/Retour” (rollback)

───────────────────────────────────────────────────────────────────────────────
SECTION: FLUX DE DONNÉES (VUES TYPES)
A) ThemeConfigView (éditeur couleurs)
   - onAppear:
     • snapshot du `theme` courant
     • beginColorEditing()  → colorModified = true
   - onChange sliders/pickers:
     • soit appelle les setters live (updateXXX) → écrit GLOBAL `theme`
       OU bien recalcul local + applyTheme(preview) async (selon implémentation)
   - "Annuler"/retour sans commit:
     • restaure snapshot via applyTheme(snapshot.theme)
     • endColorEditing()  → colorModified = false
   - "Appliquer":
     • applyTheme(preview)      (ou déjà live)
     • persistCurrentThemeToDisk()
     • endColorEditing()        → colorModified = false
     • (optionnel) ne pas dismiss si l’UX veut rester dans l’éditeur

B) ThemeDefautlView (sélecteur de presets + état non enregistré)
   - lit `themeManager.theme` pour la preview locale du panneau
   - lit `themeManager.colorModified` :
     • si true → afficher “Thème non enregistré” dans la roue
   - “Appliquer preset” (depuis la roue) :
     • applyID(presetID, persistID: true)  → theme set + UserDefaults set
     • colorModified remis à false

───────────────────────────────────────────────────────────────────────────────
SECTION: CONTRATS/INVARIANTS
- `theme` est toujours un Theme cohérent (vient d’un preset ou d’un JSON).
- `colorModified` reflète l’état d’édition transitoire :
  • true pendant une session d’édition non appliquée
  • false après applyID/applyTheme+persist ou après rollback
- `applyID(..., persistID:true)` DOIT mettre à jour UserDefaults.
- `persistCurrentThemeToDisk()` sérialise toutes les propriétés utiles de Theme.

───────────────────────────────────────────────────────────────────────────────
SECTION: ERREURS & THREADING
- @MainActor : toutes écritures de `@Published` se font sur le main thread.
- persistCurrentThemeToDisk(): ignore silencieusement l’erreur (à logger si besoin).
- UserDefaults est synchrone; pas de callback.

───────────────────────────────────────────────────────────────────────────────
SECTION: EXEMPLES D’USAGE (SNIPPETS)
1) Injection globale (App)
   @StateObject private var theme = ThemeManager(default: .aetherionDark)
   var body: some Scene {
     WindowGroup {
       RootView()
         .environmentObject(theme)
     }
   }

2) Appliquer un preset choisi dans ThemeDefautlView
   Button("Bleu") {
     themeManager.applyID(.aetherionBlue, persistID: true)
   }

3) Édition live depuis ThemeConfigView
   .onChange(of: bgColor) {
     themeManager.updateBackgroundColor(bgColor)
     themeManager.markModified()
   }
   Button("Appliquer") {
     themeManager.persistCurrentThemeToDisk()
     themeManager.endColorEditing()
     // rester sur place si souhaité
   }

───────────────────────────────────────────────────────────────────────────────
SECTION: CE QUI ÉCRIT OÙ (RÉSUMÉ)
- ThemeManager.theme          ← écrit par: init, applyTheme, applyID, updateXXX
- ThemeManager.colorModified  ← écrit par: beginColorEditing/markModified/endColorEditing, applyID(reset=false)
- UserDefaults["ae.selectedThemeID"] ← écrit par: applyID(..., persistID:true)
- theme.json (override)       ← écrit par: persistCurrentThemeToDisk()
