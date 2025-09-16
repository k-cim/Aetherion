# File: Features/Settings/ThemeDefautlView.swift  (format court)

Role
- Vue de sélection/preview de thèmes.
- Libellés lus depuis JSON bundle (Resources/Themes/*.json).
- Ajoute “Thème non enregistré” si ThemeManager.colorModified == true.
- N’applique le thème global que sur bouton “Appliquer”.

Depends on
- @EnvironmentObject ThemeManager (global: theme + colorModified).
- ThemeID, Theme.preset(_).
- Bundle JSON: id + name/meta.name.

Local state
- preview: Theme            // copie locale pour recoloriser l’écran
- choices: [WheelChoice]    // options alimentées par JSON
- selectedChoiceID: String  // id sélectionné dans la roue
- selectedChoice: WheelChoice? // déduit de choices + selectedChoiceID
- showVisualisation: Bool   // démo UI

Internal types
- BundleThemeMeta (Decodable): { id, name?, meta{name?} }  // lecture minimale JSON
- BundleThemeItem: { id: ThemeID, name: String }
- PreviewCard<Content: View>(theme,fixedHeight?,content)   // carte stylée
- WheelChoice(id:String, name:String, kind)
  - kind: preset(ThemeID) | userUnsaved

Key funcs
- loadBundleThemes() -> [BundleThemeItem]
  > Scan bundle “Themes/*.json”, parse id + name.
- rebuildFromGlobal()
  > preview = themeManager.theme
  > choices = presets (JSON) (+ “user.unsaved” si colorModified)
  > selectedChoiceID = “user.unsaved” ou “preset.<id>”
- canApply() -> Bool
  > true si preset différent de themeManager.theme.id

UI flow
- Picker (wheel) liste `choices` (noms JSON).
  - onChange:
    - preset(id)    → preview = Theme.preset(id)
    - userUnsaved   → preview = themeManager.theme
- Buttons:
  - “Réinitialiser” → rebuildFromGlobal()
  - “Appliquer”
    - preset(id)    → themeManager.applyID(id, persistID: true)
    - userUnsaved   → no-op (déjà appliqué via ThemeConfigView)

Reactivity
- onAppear → rebuildFromGlobal()
- onReceive(themeManager.$theme) → rebuildFromGlobal()
- onReceive(themeManager.$colorModified) → rebuildFromGlobal()

Side effects
- “Appliquer” (preset): écrit ID dans UserDefaults via ThemeManager, met à jour le thème global.
- Aucun write JSON ici.
