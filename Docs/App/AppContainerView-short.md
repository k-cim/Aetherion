## AppContainerView.swift (2025-09-04)

- **Struct AppContainerView: View**
  - Inputs:  
    - EnvObj `ThemeManager`, `AppRouter`, `NavigationCoordinator`
  - Méthodes:  
    - `body` → affiche fond global, contenu dynamique, bottom bar  
    - `contentView(for tab: AppRouter.Tab)` → switch Home/Vault/Contacts/Settings
  - Utilise: `ThemedScreen`, `ThemedBottomBar`, `HomeView`, `VaultView`, `ContactsView`, `SettingsView`
  - Rôle: Root container de l’app (layout principal + navigation onglets)
  
