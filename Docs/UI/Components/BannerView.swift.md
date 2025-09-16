# === File: UI/Components/BannerView.swift
# Version: 1.0
# Date: 2025-08-30
# Author: K-Cim
# Description: Reusable top banner (logo + title) stylisé avec ThemedCard.

---

## STRUCT BannerView : View
- **Scope**: Public (utilisable dans toutes les vues SwiftUI)
- **Type**: SwiftUI `View`

### Variables d’instance
- `@EnvironmentObject private var themeManager: ThemeManager`
  - Global (injecté par `.environmentObject`)
  - Sert à coloriser dynamiquement le texte avec le thème courant (`themeManager.theme.foreground`).

- `let logoName: String`
  - Local, paramètre externe.
  - Nom d’une image dans les `Assets` (ex: `"AppLogo"`).

- `let title: String`
  - Local, paramètre externe.
  - Texte du titre affiché à droite du logo (ex: `"Aetherion"`).

---

### BODY
- `ThemedCard { … }`
  - Composant stylisé (fond, coins arrondis, etc.).
- Contenu interne:
  - `HStack(spacing: 12)`
    - `Image(logoName)` → logo
    - `Text(title)` → titre principal
      - Style: `.title.bold()`
      - Couleur: `themeManager.theme.foreground` (global)
    - `Spacer()` → pousse le texte à gauche, espace à droite.

- `padding(.horizontal, 16)`
- `padding(.top, 8)`

---

## EXTERNES UTILISÉS
- **ThemeManager (global)**
  - `themeManager.theme.foreground` : couleur dynamique du texte.
- **ThemedCard (composant externe)**
  - Encapsule le contenu dans une carte stylisée.
- **SwiftUI Assets**
  - `Image(logoName)` attend une ressource image dans le bundle.

---

## APPELS / RETOUR
- Entrée :
  - `logoName: String`
  - `title: String`
- Sortie :
  - Vue SwiftUI (`some View`) affichant une bannière (logo + titre).
- Effets globaux :
  - Lit le `ThemeManager` pour appliquer la couleur du texte.

---

## UTILISATION
```swift
BannerView(logoName: "AppLogo", title: "Aetherion")
    .environmentObject(themeManager)
