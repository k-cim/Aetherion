# File: Features/Settings/ThemeConfigView.swift  (format court)

Role
- Vue d’édition des couleurs.
- Live-preview: pousse les changements dans ThemeManager.theme pour voir l’écran recolorisé.
- “Appliquer” reste sur place et marque themeManager.colorModified = true.
- “Annuler/Retour” restaure le thème d’entrée et remet colorModified = false (rollback).
- Si l’utilisateur quitte sans “Appliquer” ni “Annuler” → rollback automatique.

Depends on
- @EnvironmentObject ThemeManager (global: theme + colorModified).
- ThemeOverrideDiskStore (optionnel si tu veux persister, actuellement commenté).
- ThemedScreen, ThemedCard, ColoredSlider (UI).
- Theme, ThemeID.

Local state
- start,end                : Double — opacités du dégradé des cartes (local → preview/global live)
- startColor,endColor      : Color  — couleurs du dégradé des cartes (local → preview/global live)
- bgColor                  : Color  — fond global (local → preview/global live)
- headerColor              : Color  — couleur titres (local → preview/global live)
- textColor                : Color  — texte principal (local → preview/global live)
- secondaryTextColor       : Color  — texte secondaire (local → preview/global live)
- iconColor                : Color  — icônes (local → preview/global live)
- controlTint              : Color  — teinte des contrôles (local → preview/global live)
- preview                  : Theme  — Theme local pour peindre les cartes de CETTE vue
- snapshot                 : struct  — capture complète de l’état d’entrée (Theme + toutes les valeurs)
- committed                : Bool   — true si “Appliquer”/“Annuler” a été pressé (sinon on rollback en onDisappear)

Internal types
- Snapshot { theme:Theme, start,end,startColor,endColor,bgColor,header,primary,secondary,icon,control }

Key funcs
- loadInitialValuesAndSnapshot()
  > Lit ThemeManager.theme, remplit tous les @State, construit snapshot et preview.
- rebuildPreview(pushLive = true)
  > Construit un Theme “t” depuis les @State,
  > preview = t,
  > si pushLive == true → ThemeManager.applyTheme(t) (live preview globale).
- rollbackToSnapshot()
  > Restaure tous les @State + ThemeManager.applyTheme(snapshot.theme), preview = snapshot.theme.

UI flow (résumé)
- Sections ThemedCard pour chaque groupe (opacités, couleurs carte, fond, textes, icônes, contrôles).
- “Annuler” → rollbackToSnapshot(), themeManager.endColorEditing(), committed = true.
- “Appliquer” → themeManager.applyTheme(preview), themeManager.beginColorEditing(), committed = true.
  (Si tu veux persister aussi ici, décommente persistCurrentThemeToDisk)

Reactivity
- onAppear:
  > loadInitialValuesAndSnapshot()
  > rebuildPreview(pushLive: true)    // pour voir le header/back recolorisés
  > themeManager.beginColorEditing()
  > committed = false
- onChange(of: chaque @State):
  > rebuildPreview() + themeManager.beginColorEditing()
- onDisappear:
  > si !committed → rollbackToSnapshot() + themeManager.endColorEditing()

Side effects
- Live preview pousse dans ThemeManager.theme (source unique) pour recoloriser immédiatement.
- “Appliquer” ne quitte pas l’écran et laisse colorModified = true (signal “non enregistré”).
- “Annuler/Retour” remet ThemeManager.theme à l’état d’entrée et colorModified = false.
