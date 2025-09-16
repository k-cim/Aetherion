# === File: Resources/Localization/Localizable.strings (FR)
# Version: 1.0
# Date: 2025-08-30 05:30:00 UTC
# Author: K-Cim
# Description: Table de localisation en français (UI de base Aetherion).
# Type: Key-Value pairs (Apple .strings format, UTF-16 recommandé)

## FORMAT
- Chaque ligne : `"clé" = "valeur";`
- Utilisé via `NSLocalizedString("clé", comment: "")` ou `Text("clé", tableName: "Localizable")` en SwiftUI.

## CLÉS ET VALEURS

### Accueil
- `"home"` = "Accueil"
- `"home_title"` = "Bienvenue dans Aetherion"
- `"home_tagline"` = "Votre coffre-fort numérique pour les souvenirs"
- `"home_enter"` = "Entrer"

### Dashboard
- `"dashboard_title"` = "Tableau de bord"
- `"documents_section"` = "Documents"
- `"no_files_title"` = "Aucun fichier"
- `"no_files_subtitle"` = "Commencez par ajouter votre premier document"

### Navigation générale
- `"navigation_section"` = "Navigation"
- `"settings"` = "Paramètres"
- `"vault"` = "Coffre"
- `"share"` = "Partager"
- `"onboarding"` = "Démarrage"
- `"refresh"` = "Rafraîchir"
- `"add"` = "Ajouter"

### Paramètres
- `"settings_appearance"` = "Apparence"
- `"settings_theme"` = "Thème"
- `"settings_theme_desc"` = "Configurer les couleurs et le dégradé des encadrés"

#### Stockage
- `"settings_storage_section"` = "Stockage"
- `"settings_storage"` = "Sauvegarde de fichiers"
- `"settings_storage_desc"` = "Emplacements et rétention"
- `"settings_backup"` = "Sauvegarde"
- `"settings_backup_desc"` = "Sauvegardes automatiques et restauration"

#### Contacts
- `"settings_contacts_section"` = "Contacts"
- `"settings_contacts"` = "Contacts"
- `"settings_contacts_desc"` = "Contacts de confiance et partage"

### Placeholders génériques
- `"soon_title"` = "Bientôt"
- `"soon_message"` = "\"%@\" sera disponible prochainement."

### Contacts (liste)
- `"contacts"` = "Contacts"
- `"contacts_title"` = "Contacts"
- `"contacts_filter"` = "Filtre"
- `"contacts_group_all"` = "Tous"
- `"contacts_group_family"` = "Famille"
- `"contacts_group_friends"` = "Amis"
- `"contacts_group_others"` = "Autres"
- `"contacts_empty"` = "Aucun contact"

## OBJETS EXTERNES QUI UTILISENT CE FICHIER
- `HomeView` → home_title, home_tagline
- `DashboardView` → dashboard_title, documents_section
- `SettingsView / SettingsMenuView` → settings_theme, settings_storage, settings_contacts
- `ContactsView` → contacts_group_*, contacts_empty
- `Common UI` (navigation bar, buttons) → vault, share, refresh, add
