// === File: Features/Settings/SettingsView.swift
// Description: Paramètres — sections Apparence / Stockage / Contact.
//              Version autonome (ne lit pas ThemeManager) pour éviter le crash d'environnement.

import SwiftUI

// Remplace TOUTES tes déclas ThemeChoice par UNE SEULE :
private enum ThemeChoice: CaseIterable, Identifiable {
    case dark, light, blue, sepia, emerald
    var id: Self { self }
}

// Renomme la fonction de mapping pour éviter le conflit avec 'id'
private func themeID(for choice: ThemeChoice) -> ThemeID {
    switch choice {
    case .dark:    return .aetherionDark
    case .light:   return .aetherionLight
    case .blue:    return .aetherionBlue
    case .sepia:   return .aetherionSepia
    case .emerald: return .aetherionEmerald
    }
}

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

// Radio sans libellé (juste le rond), lié à un Bool
private struct RadioDot: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var isOn: Bool
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            Image(systemName: isOn ? "largecircle.fill.circle" : "circle")
                .font(.title3)
                .foregroundStyle(themeManager.theme.accent)
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}


// MARK: - LocalCard (remplace ThemedCard ici, même visuel)
private struct LocalCard<Content: View>: View {
    let theme: LocalTheme
    let fixedHeight: CGFloat?
    @ViewBuilder var content: () -> Content
    @State private var showVisualisation: Bool = false
    
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
    @State private var showVisualisation: Bool = false
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var selectedChoice: ThemeChoice = .dark

    // 5 choix de thèmes pour la roue
    private enum ThemeChoice: String, CaseIterable, Identifiable {
        case dark    = "Thème Foncé"
        case light   = "Thème Clair"
        case blue    = "Thème Bleu"
        case sepia   = "Thème Sépia"
        case emerald = "Thème Émeraude"
        var id: String { rawValue }
    }

    
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
                                    Text(selectedChoice.rawValue)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(theme.foreground)
                                    
                                    // “Thème de l’application” pour Foncé/Clair ; “Thème enregistré” sinon
                                    let isPreset = (selectedChoice == .dark || selectedChoice == .light)
                                    Text(isPreset ? "Thème de l’application" : "Thème enregistré")
                                        .font(.subheadline)
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
                                Spacer()
                                HStack(alignment: .firstTextBaseline, spacing: 12) {
                                    Text("Bouton Radio")
                                        .font(.subheadline)
                                        .foregroundStyle(theme.secondary)
                                        .lineLimit(1)
                                    
                                    Button {
                                        showVisualisation.toggle()
                                    } label: {
                                        Image(systemName: showVisualisation ? "largecircle.fill.circle" : "circle")
                                            .font(.title3)
                                            .foregroundStyle(theme.accent)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 6)
                    }
                     
                    // =======================
                    // Section : choix du theme
                    // =======================
                    VStack(alignment: .leading) {
                        Text("Choix du Thème")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.foreground)
                            .padding(.top, 8)
                            .padding(.horizontal, 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    // Choix du theme
                    
                    LocalCard(theme: theme) {
                        VStack(alignment: .leading, spacing: 8) {
                            // Roue de choix (wheel) — UN SEUL PICKER
                            Picker("Thème", selection: $selectedChoice) {
                                Text("Foncé").tag(ThemeChoice.dark)
                                Text("Clair").tag(ThemeChoice.light)
                                Text("Bleu").tag(ThemeChoice.blue)
                                Text("Sépia").tag(ThemeChoice.sepia)
                                Text("Émeraude").tag(ThemeChoice.emerald)
                            }
                            .pickerStyle(.wheel)
                            .frame(height: 140)

                            // Détail sous la roue : nom + type
                            VStack(alignment: .leading, spacing: 2) {
                                let label: String = {
                                    switch selectedChoice {
                                    case .dark: return "Thème Foncé"
                                    case .light: return "Thème Clair"
                                    case .blue: return "Thème Bleu"
                                    case .sepia: return "Thème Sépia"
                                    case .emerald: return "Thème Émeraude"
                                    }
                                }()
                               
                            }
                            .padding(.top, 4)
                        }
                    }
                    // 👉 applique réellement le thème quand on change la roue
                    .onChange(of: selectedChoice) {
                    }
                    
                    LocalCard(theme: theme) {
                        HStack(spacing: 12) {
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedChoice.rawValue)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(theme.foreground)
                                
                                // “Thème de l’application” pour Foncé/Clair ; “Thème enregistré” sinon
                                let isPreset = (selectedChoice == .dark || selectedChoice == .light)
                                Text(isPreset ? "Thème de l’application" : "Thème enregistré")
                                    .font(.subheadline)
                                    .foregroundStyle(theme.secondary)
                            }
                            .padding(.top, 4)
                        }
                        Spacer()
                        
                        
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
