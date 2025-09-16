# === File: Aetherion/App/AppContainerView.swift
# Date: 2025-09-04
# Description: Conteneur principal de l’app. Sert de root view (layout global + bottom bar).

## STRUCTS

### struct AppContainerView: View
- **Environnement global** :
  - `@EnvironmentObject themeManager: ThemeManager` → gère le thème global (couleurs, background).
  - `@EnvironmentObject router: AppRouter` → gère l’onglet sélectionné.
  - `@EnvironmentObject nav: NavigationCoordinator` → navigation (reset chemin, popToRoot).

- **Méthodes internes** :
  - `body: some View`  
    → Affiche :
      - Fond global (`themeManager.theme.background`).
      - Contenu variable selon l’onglet (`contentView(for:)`).
      - Barre du bas (`ThemedBottomBar`).
      - Gère aussi les safeAreas (fond + clavier).
  - `private func contentView(for tab: AppRouter.Tab) -> some View`  
    → Router interne :
      - `.home` → `HomeView()`
      - `.vault` → `VaultView()`
      - `.contacts` → `ContactsView()`
      - `.settings` → `SettingsView()`

## VARIABLES & OBJETS EXTERNES UTILISÉS
- `ThemeManager` (global, UI/Theme/ThemeManager.swift)
- `AppRouter` (global, doit contenir enum `Tab`)
- `NavigationCoordinator` (App/NavigationCoordinator.swift)
- `ThemedScreen` (UI component, applique thème aux écrans)
- `ThemedBottomBar` (UI component, barre navigation inférieure)
- `HomeView`, `VaultView`, `ContactsView`, `SettingsView` (features)

## RÔLE GLOBAL
- Sert de **root container** pour toute l’application.
- Centralise le fond, le switch des onglets, et l’injection de la bottom bar.
- Toutes les vues passent par ce conteneur.
