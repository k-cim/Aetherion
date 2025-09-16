# File: UI/Components/BannerView.swift
- Struct BannerView: View (public) → bannière logo + titre
- Vars:
  - global: themeManager: ThemeManager (couleur texte)
  - local: logoName:String (image Assets), title:String (texte)
- Body: ThemedCard { HStack [Image(logoName, 40x40), Text(title, .title.bold, couleur = themeManager.theme.foreground), Spacer()] }
- Padding: horizontal 16, top 8
- Externes: ThemeManager, ThemedCard, SwiftUI Assets
- Entrées: logoName, title
- Sortie: some View (bannière stylisée)
d
