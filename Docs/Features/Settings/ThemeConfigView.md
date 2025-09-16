# === File: Features/Settings/ThemeConfigView.swift
# Version: 1.0
# Date: 2025-09-13
# Author: K-Cim
# Description: Vue SwiftUI d’édition des couleurs.  
- Permet de modifier toutes les couleurs du thème en live (preview globale).  
- “Appliquer” valide et garde `ThemeManager.colorModified = true`.  
- “Annuler/Retour” restaure l’état initial et remet `ThemeManager.colorModified = false`.  
- Si on quitte sans action → rollback automatique.

---

## STRUCT ThemeConfigView : View
- Scope: Public
- Type: SwiftUI View
- Rôle: UI d’édition complète du thème (background, textes, icônes, contrôles, dégradés cartes).

---

### Vars (local state)

- **@EnvironmentObject themeManager: ThemeManager**  
  Global — fournit et reçoit le thème de l’application + flag `colorModified`.

- **@State start: Double** → opacité gauche du dégradé (local → écrit dans Theme.theme.cardStartOpacity).  
- **@State end: Double** → opacité droite du dégradé (local → écrit dans Theme.theme.cardEndOpacity).  
- **@State startColor: Color** → couleur gauche du dégradé (local → écrit dans Theme.theme.cardStartColor).  
- **@State endColor: Color** → couleur droite du dégradé (local → écrit dans Theme.theme.cardEndColor).  

- **@State bgColor: Color** → couleur de fond globale (local → écrit dans Theme.theme.background).  

- **@State headerColor: Color** → couleur titres (local → écrit dans Theme.theme.headerColor).  
- **@State textColor: Color** → couleur texte principal (local → écrit dans Theme.theme.foreground).  
- **@State secondaryTextColor: Color** → couleur texte secondaire (local → écrit dans Theme.theme.secondary).  

- **@State iconColor: Color** → couleur icônes (local → écrit dans Theme.theme.accent).  
- **@State controlTint: Color** → couleur des contrôles (local → écrit dans Theme.theme.controlTint).  

- **@State preview: Theme** → Theme local utilisé uniquement pour les cartes PreviewCard de cette vue.  

- **@State snapshot: Snapshot?** → capture de l’état initial (global Theme + valeurs locales) pour rollback.  
- **@State committed: Bool** → si vrai, évite le rollback en quittant l’écran.  

---

### STRUCT interne Snapshot
- **theme: Theme** → Theme global initial complet.  
- **start,end,startColor,endColor,bgColor,header,primary,secondary,icon,control** → copie locale de chaque valeur.  
- Rôle: restauration complète si rollback.

---

### Fonctions principales

- **fmt(_ v: Double) -> String**  
  Local — formatage en chaîne (2 décimales).

- **rebuildPreview(pushLive: Bool = true)**  
  Local.  
  - Construit un Theme `t` à partir des @State.  
  - Affecte `preview = t`.  
  - Si pushLive == true → pousse `themeManager.applyTheme(t)` (global).  

- **loadInitialValuesAndSnapshot()**  
  Local.  
  - Lit `themeManager.theme`.  
  - Alimente tous les @State.  
  - Crée `snapshot` et `preview`.

- **rollbackToSnapshot()**  
  Local.  
  - Restaure tous les @State depuis `snapshot`.  
  - Applique `snapshot.theme` dans `themeManager` (global).  
  - Affecte `preview`.

---

### Body
- **ThemedScreen** (fond + cadre)  
  - **header()** : titre avec couleurs du global.  
  - **ScrollView** listant 6 cartes de config :  
    - Dégradé (opacités + couleurs).  
    - Fond global.  
    - Textes (titres, principal, secondaire).  
    - Icônes.  
    - Contrôles.  
  - **actionsBar()** :  
    - Bouton “Annuler” → rollbackToSnapshot() + themeManager.endColorEditing() + committed=true.  
    - Bouton “Appliquer” → themeManager.applyTheme(preview) + themeManager.beginColorEditing() + committed=true.

---

### Hooks SwiftUI

- **onAppear** :  
  - Charge snapshot.  
  - Rebuild preview avec pushLive=true (global recolorisé).  
  - Flag édition = true.  
  - committed=false.

- **onChange(of: @State)** :  
  - Pour chaque champ modifié → rebuildPreview() + themeManager.beginColorEditing().  

- **onDisappear** :  
  - Si !committed → rollbackToSnapshot() + themeManager.endColorEditing().

---

### Externes utilisés
- **ThemeManager** (global) → lit/écrit Theme + flags.  
- **Theme** (global struct) → modèle complet du thème.  
- **ThemeOverrideDiskStore** (optionnel si persistance activée).  
- **SwiftUI ColorPicker, Slider, Button**.  
- **ThemedScreen, ThemedCard, ColoredSlider** (UI internes au projet).

---

### Entrées / Sorties
- Entrées: aucun paramètre externe (lit directement ThemeManager).  
- Sortie: `some View` (vue complète d’édition).  
- Effets: modifie ThemeManager.theme (global), ThemeManager.colorModified (global).  

---

### Exemple
```swift
ThemeConfigView()
    .environmentObject(themeManager)
