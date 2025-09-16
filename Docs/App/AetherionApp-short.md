## AetherionApp.swift (2025-08-30)

- **Struct AetherionApp: App**
  - StateObjects initiaux :
    - `ThemeManager` (gère thème global, persistance via UserDefaults)
    - `AppRouter` (onglets)
    - `NavigationCoordinator` (stack navigation)
  - Init : charge `ae.selectedThemeID` ou fallback `.aetherionDark`
  - body :
    - `WindowGroup` → `NavigationStack` avec `AppContainerView`
    - Injecte envObj : `theme`, `router`, `nav`
    - Applique `.tint` = couleur accent du thème
  - Rôle : **Point d’entrée et injection des singletons**
