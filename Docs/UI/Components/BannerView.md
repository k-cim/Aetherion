# === File: UI/Components/BannerView.swift
# Version: 1.0
# Date: 2025-08-30
# Author: K-Cim

## STRUCT BannerView : View
- Scope: Public
- Type: SwiftUI View
- Rôle: Bannière réutilisable (logo + titre alignés)

### Variables
- global: @EnvironmentObject themeManager: ThemeManager → couleur dynamique du texte
- local: let logoName: String → nom d’image depuis Assets
- local: let title: String → texte affiché

### Body
- ThemedCard {
  - HStack(spacing: 12):
    - Image(logoName) → logo (resizable, scaledToFit, 40x40)
    - Text(title) → titre (.title.bold, couleur = themeManager.theme.foreground)
    - Spacer()
}
- Padding horizontal: 16, top: 8

### Externes utilisés
- ThemeManager (global, couleur du texte)
- ThemedCard (composant UI externe)
- SwiftUI Assets (Image)

### Entrées / Sortie
- Entrées: logoName:String, title:String
- Sortie: some View (bannière stylisée)

### Exemple
```swift
BannerView(logoName: "AppLogo", title: "Aetherion")
    .environmentObject(themeManager)

