# === File: App/AetherionApp.swift
# Version: 1.1
# Date: 2025-08-30
# Author: K-Cim
# Description: Point d’entrée de l’application (struct @main). Initialise et injecte les singletons.

## STRUCTS

### struct AetherionApp: App
- **Propriétés (globales, injectées dans l’arbre SwiftUI)** :
  - `@StateObject theme: ThemeManager`
    → Gère l’état du thème pour toute l’application (couleurs, styles).
  - `@StateObject router = AppRouter()`
    → Gère l’onglet courant (home, vault, contacts, settings).
  - `@StateObject nav = NavigationCoordinator()`
    → Gère la navigation (stack NavigationPath).

- **Init()** :
  - Lit `UserDefaults.standard.string(forKey: "ae.selectedThemeID")`.
  - Convertit en `ThemeID` si trouvé, sinon fallback `.aetherionDark`.
  - Crée `ThemeManager(default: initialID)` et l’attache au `@StateObject theme`.

- **body** :
  - `WindowGroup` → racine de l’app.
  - `NavigationStack(path: $nav.path)` → navigation basée sur `NavigationCoordinator`.
  - Contenu → `AppContainerView()`.
  - Injection des dépendances avec `.environmentObject(theme)`, `.environmentObject(router)`, `.environmentObject(nav)`.
  - `.tint(theme.theme.accent)` → applique la couleur d’accent globale.

## OBJETS EXTERNES UTILISÉS
- `ThemeManager` (UI/Theme/ThemeManager.swift)
- `AppRouter` (App/AppRouter.swift)
- `NavigationCoordinator` (App/NavigationCoordinator.swift)
- `ThemeID` (Core, enum des IDs de thème)
- `AppContainerView` (App/AppContainerView.swift)

## RÔLE GLOBAL
- Point d’entrée (`@main`).
- Centralise les **StateObject** principaux (thème, navigation, onglets).
- Injecte les singletons dans l’environnement SwiftUI.
- Applique le style global (accent color).
