// === File: Features/Settings/ThemeDefautlView.swift
// Choix d’un preset avec prévisualisation locale, tout en restant
// synchronisé avec le thème global (et les changements venant de ThemeConfigView).

import SwiftUI

// Mapping ThemeID -> choix de roue
private func choice(for id: ThemeID) -> ThemeDefautlView.ThemeChoice {
    switch id {
    case .aetherionDark:    return .dark
    case .aetherionLight:   return .light
    case .aetherionBlue:    return .blue
    case .aetherionSepia:   return .sepia
    case .aetherionEmerald: return .emerald
    }
}

// Mapping choix de roue -> ThemeID
private func themeID(for choice: ThemeDefautlView.ThemeChoice) -> ThemeID {
    switch choice {
    case .dark:    return .aetherionDark
    case .light:   return .aetherionLight
    case .blue:    return .aetherionBlue
    case .sepia:   return .aetherionSepia
    case .emerald: return .aetherionEmerald
    }
}

// Carte autonome qui prend un Theme (pour preview locale)
private struct PreviewCard<Content: View>: View {
    let theme: Theme
    let fixedHeight: CGFloat?
    @ViewBuilder var content: () -> Content

    init(theme: Theme, fixedHeight: CGFloat? = nil, @ViewBuilder content: @escaping () -> Content) {
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

struct ThemeDefautlView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // 👇 Prévisualisation locale (ne modifie pas le global tant qu’on n’appuie pas sur Appliquer)
    @State private var preview: Theme = Theme.preset(.aetherionDark)
    @State private var selectedChoice: ThemeChoice = .dark
    @State private var showVisualisation: Bool = false

    // Choix appliqué actuellement (d’après le global)
    private var appliedChoice: ThemeChoice { choice(for: themeManager.theme.id) }
    private var canApply: Bool { selectedChoice != appliedChoice }

    enum ThemeChoice: String, CaseIterable, Identifiable {
        case dark    = "Thème Foncé"
        case light   = "Thème Clair"
        case blue    = "Thème Bleu"
        case sepia   = "Thème Sépia"
        case emerald = "Thème Émeraude"
        var id: String { rawValue }
    }

    var body: some View {
        ZStack {
            // 👇 Le fond de CET écran suit la preview locale
            preview.background.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Text("Thème")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(preview.headerColor)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Info
                        PreviewCard(theme: preview) {
                            HStack(spacing: 12) {
                                Image(systemName: "paintpalette.fill")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(preview.accent)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedChoice.rawValue)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(preview.foreground)
                                    Text((selectedChoice == .dark || selectedChoice == .light) ? "Thème de l’application" : "Thème enregistré")
                                        .font(.subheadline)
                                        .foregroundStyle(preview.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }

                        // Visualisation simple
                        PreviewCard(theme: preview) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Visualisation")
                                        .font(.headline.bold())
                                        .foregroundStyle(preview.foreground)
                                    Spacer()
                                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                                        Text("Bouton Radio").font(.subheadline).foregroundStyle(preview.secondary)
                                        Button {
                                            showVisualisation.toggle()
                                        } label: {
                                            Image(systemName: showVisualisation ? "largecircle.fill.circle" : "circle")
                                                .font(.title3)
                                                .foregroundStyle(preview.accent)
                                        }
                                    }
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }

                        // Choix roue
                        VStack(alignment: .leading) {
                            Text("Choix du Thème")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(preview.foreground)
                                .padding(.top, 8)
                                .padding(.horizontal, 2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        PreviewCard(theme: preview) {
                            VStack(alignment: .leading, spacing: 8) {
                                Picker("Thème", selection: $selectedChoice) {
                                    Text("Foncé").tag(ThemeChoice.dark)
                                    Text("Clair").tag(ThemeChoice.light)
                                    Text("Bleu").tag(ThemeChoice.blue)
                                    Text("Sépia").tag(ThemeChoice.sepia)
                                    Text("Émeraude").tag(ThemeChoice.emerald)
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 140)
                            }
                        }
                        .onChange(of: selectedChoice) { newValue in
                            // 🔁 Tourner la roue recolorise la page en local, sans toucher le global
                            let id = themeID(for: newValue)
                            preview = Theme.preset(id)
                        }

                        // Rappel du choix
                        PreviewCard(theme: preview) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(selectedChoice.rawValue)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(preview.foreground)
                                Text((selectedChoice == .dark || selectedChoice == .light) ? "Thème de l’application" : "Thème enregistré")
                                    .font(.subheadline)
                                    .foregroundStyle(preview.secondary)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4)
                        }

                        // Actions
                        HStack(spacing: 12) {
                            Button {
                                // Remet la preview sur le thème global courant
                                preview = themeManager.theme
                                selectedChoice = choice(for: themeManager.theme.id)
                            } label: {
                                PreviewCard(theme: preview, fixedHeight: 56) {
                                    HStack { Spacer(); Text("Réinitialiser").font(.headline.bold()).foregroundStyle(preview.foreground); Spacer() }
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                guard canApply else { return }
                                // On choisit un PRESET => on supprime l’override JSON et on persiste l’ID
                                let id = themeID(for: selectedChoice)
                                themeManager.clearDiskOverride()
                                themeManager.applyID(id, persist: true)
                                // La preview va se resynchroniser via onReceive ci-dessous
                            } label: {
                                PreviewCard(theme: preview, fixedHeight: 56) {
                                    HStack {
                                        Spacer()
                                        Text("Appliquer")
                                            .font(.headline.bold())
                                            .foregroundStyle(canApply ? preview.foreground : preview.secondary)
                                        Spacer()
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(!canApply)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
        }
        // 🧲 Sync initiale & quand ThemeConfigView applique des changements globaux
        .onAppear {
            preview = themeManager.theme
            selectedChoice = choice(for: themeManager.theme.id)
        }
        .onReceive(themeManager.$theme) { newTheme in
            // Si ThemeConfigView applique un override JSON, on le reflète ici (fond + textes)
            preview = newTheme
            selectedChoice = choice(for: newTheme.id)
        }
    }
}

#Preview {
    NavigationStack { ThemeDefautlView() }
}
