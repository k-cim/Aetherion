# === File: App/NavigationCoordinator.swift
# Date: 2025-09-04 00:00:00 UTC
# Description: Gestion centralisée de la navigation SwiftUI via NavigationPath.

## STRUCTURE
- final class NavigationCoordinator : ObservableObject (GLOBAL)
  - @Published var path : NavigationPath
    - GLOBAL observable (lié aux vues avec .environmentObject)
    - Sert de pile de navigation
  - func popToRoot()
    - Action : réinitialise `path` à vide → retour à la racine

## DÉPENDANCES
- Import: SwiftUI
- Utilise: NavigationPath (SwiftUI)

## UTILISATION
- Si injecté via `.environmentObject(NavigationCoordinator)`, sert à piloter la navigation depuis plusieurs vues.
- Exemple d’appel: `coordinator.path.append(...)` ou `coordinator.popToRoot()`.
- Si **jamais injecté** dans `AetherionApp.swift` ou ailleurs → ce fichier est inutile et peut être supprimé.

## ÉCRITURES
- Écrit dans une variable globale observée (`path`).
- Pas d’accès à d’autres objets globaux (ThemeManager, etc.).

## SORTIE
- Publie des changements de `path` (ObservableObject → SwiftUI View update).
