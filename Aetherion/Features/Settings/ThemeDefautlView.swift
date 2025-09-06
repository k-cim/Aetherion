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
struct ThemeDefautlView : View {
    // On ne lit plus ThemeManager ici → pas de crash si l'env manque
    @State private var theme = LocalTheme.load()
    
    var body: some View {
        ZStack {
            theme.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Titre d'écran (style proche ThemedHeaderTitle)
                HStack {
                    Text("Thème Enregistré")
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
                        
                        LocalCard(theme: theme) {
                            HStack(spacing: 12) {
                                Image(systemName: "paintpalette.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(theme.accent)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Nom du Thème Enristrés")
                                        .font(.headline.bold())
                                        .foregroundStyle(theme.foreground)
                                    Text("Theme système ou theme custom")
                                        .font(.caption)
                                        .foregroundStyle(theme.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // Pavé : Thème
                    
                    
                    LocalCard(theme: theme) {
                        HStack(spacing: 12) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Visualisation")
                                    .font(.headline.bold())
                                    .foregroundStyle(theme.foreground)
                                Text("texte bouton radio + un bouton radio ")
                                    .font(.caption)
                                    .foregroundStyle(theme.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                     
                    // =======================
                    // Section : Contact
                    // =======================
                    Text("Choix du Thème")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(theme.foreground)
                        .padding(.top, 8)
                        .padding(.horizontal, 2)
                    
                    // Choix du theme 
                    NavigationLink {
                        ContactsView()
                    } label: {
                        LocalCard(theme: theme) {
                            HStack(spacing: 12) {
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("pacer ici un roue de choix de theme").font(.headline.bold()).foregroundStyle(theme.foreground)
                                }
                                Spacer()
                        
                            }
                            .padding(.vertical, 6)
                        }
                    }
                    .buttonStyle(.plain)
                    
                    // --- Actions (Annuler / Réinitialiser) ---
                    HStack(spacing: 12) {
                        Button {  } label: {
                            ThemedCard(fixedHeight: 56) {
                                HStack { Spacer(); Text("Reinitialiser").font(.headline.bold())
                                    Spacer() }
                            }
                        }
                        .buttonStyle(.plain)

                        Button {  } label: {
                            ThemedCard(fixedHeight: 56) {
                                HStack { Spacer(); Text("Appliquer").font(.headline.bold())
                                                                              Spacer() }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.top, 4)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 120) // espace pour la bottom bar globale
            }
        }
    }
        
}
//

#Preview {
    NavigationStack {
        ThemeDefautlView ()
    }
}
