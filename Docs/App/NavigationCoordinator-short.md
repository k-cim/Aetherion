## NavigationCoordinator.swift
- class globale `NavigationCoordinator : ObservableObject`
- @Published var path : NavigationPath (pile de navigation)
- func popToRoot() → reset path
- Sert uniquement si injecté via `.environmentObject`
- Pas lié aux thèmes, ni aux JSON
- Si pas utilisé → supprimable
