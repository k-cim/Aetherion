# === File: UI/Theme/ThemeManager.swift
# Date: 2025-09-13 14:45:00 UTC
# Résumé condensé (référence rapide)

───────────────────────────────────────────────
RÔLE
- Source unique du thème global (SwiftUI).
- Persiste l’ID du preset (UserDefaults).
- Charge/écrit un override JSON (ThemeOverrideDiskStore).
- Flag `colorModified` pour marquer un thème modifié non enregistré.

───────────────────────────────────────────────
ÉTAT GLOBAL
- @Published var theme: Theme
- @Published var colorModified: Bool
- UserDefaults key: "ae.selectedThemeID"

───────────────────────────────────────────────
FONCTIONS PRINCIPALES
- init(default: ThemeID) → charge preset, puis override si dispo.
- applyTheme(_:) → écrit `theme` directement.
- applyID(_:persistID:) → applique preset + persiste ID.
- persistCurrentThemeToDisk() → écrit JSON override.
- updateXXX(...) → setters live (background, texte, icônes, contrôles…).
- beginColorEditing() / markModified() / endColorEditing() → gèrent `colorModified`.

───────────────────────────────────────────────
USAGE
- ThemeConfigView :
  • Appliquer sliders → updateXXX + markModified()
  • Appliquer bouton  → persistCurrentThemeToDisk() + endColorEditing()
  • Annuler/retour    → rollback snapshot + endColorEditing()
- ThemeDefautlView :
  • Lit themeManager.theme pour preview
  • Si colorModified == true → affiche “Thème non enregistré”
  • Appliquer preset → applyID(presetID)

───────────────────────────────────────────────
ÉCRITURES EXTERNES
- UserDefaults["ae.selectedThemeID"] (ID)
- theme.json (override complet)

───────────────────────────────────────────────
INVARIANTS
- theme = Theme valide (preset ou override)
- colorModified = true seulement si édition en cours
