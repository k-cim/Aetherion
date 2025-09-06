// === File: Features/Settings/SettingsView.swift
// Description: Paramètres — sections Apparence / Stockage / Contact.
//              Version autonome (ne lit pas ThemeManager) pour éviter le crash d'environnement.

import SwiftUI

// MARK: - Local theme snapshot (chargé depuis la persistance)
private struct LocalTheme {
    let background: Color
    let foreground: Color
    let secondary: Color
    let accent: Color
    let controlTint: Color
    let cardStartOpacity: Double
    let cardEndOpacity: Double
    let cardStartColor: Color
    let cardEndColor: Color
    let cornerRadius: CGFloat
    let headerColor: Color

    static func load() -> LocalTheme {
        let p = ThemePersistence.shared
        // on part du preset dark (cohérent avec l’app) puis on applique les persistences
        let base = Theme.preset(.aetherionDark)
        return LocalTheme(
            background: p.loadBackgroundColor(default: .black),
            foreground: p.loadPrimaryTextColor(default: base.foreground),
            secondary: p.loadSecondaryTextColor(default: base.secondary),
            accent: p.loadIconColor(default: base.accent),
            controlTint: p.loadControlTint(default: base.controlTint),
            cardStartOpacity: p.loadCardGradient(defaultStart: base.cardStartOpacity, defaultEnd: base.cardEndOpacity).0,
            cardEndOpacity:   p.loadCardGradient(defaultStart: base.cardStartOpacity, defaultEnd: base.cardEndOpacity).1,
            cardStartColor:   p.loadCardGradientColors(defaultStart: base.cardStartColor, defaultEnd: base.cardEndColor).0,
            cardEndColor:     p.loadCardGradientColors(defaultStart: base.cardStartColor, defaultEnd: base.cardEndColor).1,
            cornerRadius: base.cornerRadius,
            headerColor: p.loadHeaderColor(default: base.headerColor)
        )
    }
}

// MARK: - LocalCard (remplace ThemedCard ici, même visuel)
private struct LocalCard<Content: View>: View {
    let theme: LocalTheme
    let fixedHeight: CGFloat?
    @ViewBuilder var content: () -> Content

    init(theme: LocalTheme, fixedHeight: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
        self.theme = theme
        self.fixedHeight = fixedHeight
        self.content = content
    }

    var body: some View {
        let start = theme.cardStartColor.opacity(theme.cardStartOpacity)
        let end   = theme.cardEndColor.opacity(theme.cardEndOpacity)

        ZStack {
            RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                .fill(LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing))
                .overlay(
                    RoundedRectangle(cornerRadius: theme.cornerRadius, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08))
                )
            content()
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
        .frame(height: fixedHeight)
    }
}

// MARK: - SettingsView (autonome)
struct SettingsView: View {
    // On ne lit plus ThemeManager ici → pas de crash si l'env manque
    @State private var theme = LocalTheme.load()

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                // Titre d'écran (style proche ThemedHeaderTitle)
                HStack {
                    Text("Paramètres")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.headerColor)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // =======================
                        // Section : Apparence
                        // =======================
                        Text("Apparence")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.foreground)
                            .padding(.horizontal, 2)

                        // Pavé : Thème
                        NavigationLink {
                        ThemeDefautlView () // héritera des envObjects depuis l'app (barre globale)
                        } label: {
                            LocalCard(theme: theme) {
                                HStack(spacing: 12) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Thème Enristrés")
                                            .font(.headline.bold())
                                            .foregroundStyle(theme.foreground)
                                        Text("Thème par défaut ou thème enregistrés de l’interface")
                                            .font(.caption)
                                            .foregroundStyle(theme.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)
                        
                        // Pavé : Thème
                        NavigationLink {
                            ThemeConfigView() // héritera des envObjects depuis l'app (barre globale)
                        } label: {
                            LocalCard(theme: theme) {
                                HStack(spacing: 12) {
                                    Image(systemName: "paintpalette.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Thème")
                                            .font(.headline.bold())
                                            .foregroundStyle(theme.foreground)
                                        Text("Couleurs générales de l’interface")
                                            .font(.caption)
                                            .foregroundStyle(theme.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)
                        // =======================
                        // Section : Stockage
                        // =======================
                        Text("Stockage")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.foreground)
                            .padding(.top, 8)
                            .padding(.horizontal, 2)

                        // Pavé : Stockage — Emplacement et options
                        NavigationLink {
                            VaultView()
                        } label: {
                            LocalCard(theme: theme) {
                                HStack(spacing: 12) {
                                    Image(systemName: "externaldrive.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Stockage")
                                            .font(.headline.bold())
                                            .foregroundStyle(theme.foreground)
                                        Text("Emplacement et options")
                                            .font(.caption)
                                            .foregroundStyle(theme.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)

                        // Pavé : Sauvegarde — Planification et restauration
                        NavigationLink {
                            BackupSettingsView_LocalStyle()
                        } label: {
                            LocalCard(theme: theme) {
                                HStack(spacing: 12) {
                                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Sauvegarde")
                                            .font(.headline.bold())
                                            .foregroundStyle(theme.foreground)
                                        Text("Planification et restauration")
                                            .font(.caption)
                                            .foregroundStyle(theme.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)

                        // =======================
                        // Section : Contact
                        // =======================
                        Text("Contact")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.foreground)
                            .padding(.top, 8)
                            .padding(.horizontal, 2)

                        // Pavé : Gestion des contacts — Filtres, groupes, confiance
                        NavigationLink {
                            ContactsView()
                        } label: {
                            LocalCard(theme: theme) {
                                HStack(spacing: 12) {
                                    Image(systemName: "person.2.fill")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(theme.accent)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Gestion des contacts")
                                            .font(.headline.bold())
                                            .foregroundStyle(theme.foreground)
                                        Text("Filtres, groupes, confiance")
                                            .font(.caption)
                                            .foregroundStyle(theme.secondary)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(theme.secondary)
                                }
                                .padding(.vertical, 6)
                            }
                        }
                        .buttonStyle(.plain)

                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120) // espace pour la bottom bar globale
                }
            }
        }
        // si on revient de ThemeConfigView avec des nouveaux réglages persistés, on recharge les couleurs
        .onAppear { theme = LocalTheme.load() }
    }
}

// MARK: - Placeholder local pour “Sauvegarde” (même style local)
private struct BackupSettingsView_LocalStyle: View {
    @State private var theme = LocalTheme.load()

    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("Sauvegarde")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(theme.headerColor)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    LocalCard(theme: theme) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Planification et restauration")
                                .font(.headline.bold())
                                .foregroundStyle(theme.foreground)
                            Text("Écran de configuration à venir.")
                                .font(.subheadline)
                                .foregroundStyle(theme.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear { theme = LocalTheme.load() }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
