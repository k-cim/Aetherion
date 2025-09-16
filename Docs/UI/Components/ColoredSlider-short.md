# ThemedCard.swift (UI/Components)

## STRUCT ThemedCard<Content: View>
- Type: SwiftUI View générique
- Scope: Public
- Rôle: Carte réutilisable (fond dégradé + bordure) avec contenu enfant

### Vars
- global: @EnvObject themeManager (ThemeManager)
- local: fixedHeight: CGFloat?, content: () -> Content

### Body
- ZStack: RoundedRectangle (LinearGradient start/end du thème + stroke)
- content() → padding, frame infini, height optionnelle

### Dépendances
- ThemeManager.theme (cardStartColor, cardEndColor, opacities, cornerRadius)
- SwiftUI (View, LinearGradient, RoundedRectangle)

### Entrée/Sortie
- Entrées: fixedHeight?, content closure
- Sortie: some View (carte stylisée)
