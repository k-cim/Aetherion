# File: Features/Settings/ThemeDefautlView.swift
- View publique : sélection/preview de thèmes (noms lus depuis JSON bundle), ajout "Thème non enregistré" si `ThemeManager.colorModified == true`.

## État (local)
- preview: Theme — local, copie de `themeManager.theme` pour prévisualiser sans impacter le global.
- choices: [WheelChoice] — local, options de la roue construites depuis JSON.
- selectedChoiceID: String — local, identifiant sélectionné dans la roue.
- selectedChoice: WheelChoice? — local, déduit de `choices` et `selectedChoiceID`.
- showVisualisation: Bool — local, démo UI.

## Dépendances (globales / externes)
- `@EnvironmentObject themeManager: ThemeManager` — global (source de vérité du thème + flag `colorModified`).
- Bundle JSON: `Resources/Themes/*.json` — source des libellés de thèmes.

## Types internes (privés)
- BundleThemeMeta (Decodable) — lecture minimale JSON: `{ id, name?, meta.name? }`.
- BundleThemeItem (Identifiable) — (id: ThemeID, name: String).
- PreviewCard<Content: View> — carte stylée pour la preview locale (prend un `Theme`).
- WheelChoice (Identifiable, Equatable)
  - enum Kind { preset(ThemeID), userUnsaved }
  - id: String ("preset.<id>" | "user.unsaved"), name: String (libellé), kind: Kind.

## Fonctions (privées)
- loadBundleThemes() -> [BundleThemeItem]
  - Entrée: aucune (lit le bundle).
  - Sortie: liste (id + name) pour alimenter la roue.
  - Side effects: aucun.
- rebuildFromGlobal()
  - Entrée: lit `themeManager.theme` et `themeManager.colorModified`.
  - Effets: met à jour `preview`, reconstruit `choices`, positionne `selectedChoiceID`.
  - Règles: si `colorModified == true` → ajoute "Thème non enregistré" et sélectionne cet item; sinon sélectionne le preset courant.
- canApply() -> Bool
  - true si un preset différent de l’ID courant est sélectionné (inutile pour `userUnsaved`).

## Body (comportement)
- Fond = `preview.background`.
- Sections:
  - Info (affiche nom + "Thème non enregistré" si besoin).
  - Visualisation (démo).
  - Picker (roue) : liste `choices` (noms depuis JSON) ; onChange:
    - preset(id) → `preview = Theme.preset(id)`
    - userUnsaved → `preview = themeManager.theme`
  - Actions:
    - "Réinitialiser" → `rebuildFromGlobal()`
    - "Appliquer" :
      - preset(id) → `themeManager.applyID(id, persistID: true)` (met à jour le global + persiste l’ID)
      - userUnsaved → no-op (état déjà appliqué via ThemeConfigView)

## Publishers (réactions)
- .onAppear → `rebuildFromGlobal()`
- .onReceive(themeManager.$theme) → `rebuildFromGlobal()` (si le global change ailleurs)
- .onReceive(themeManager.$colorModified) → `rebuildFromGlobal()` (si édition couleurs en cours ou annulée)

## Entrées / Sorties
- Entrées utilisateur: sélection roue, boutons.
- Sorties (effets globaux):
  - Appliquer preset → modifie `ThemeManager.theme` + persiste l’ID (UserDefaults).
  - Aucune écriture de JSON ici (enregistrement du thème custom géré ailleurs).

## Hypothèses
- Les JSON `Themes/*.json` contiennent au moins `id` et un `name` ou `meta.name`.
- `ThemeID` couvre les IDs référencés dans les JSON (sinon l’item est ignoré).

