// === File: Features/Settings/SettingsView.swift
// Description: Paramètres — sections Apparence / Stockage / Contact.
//              Version autonome (ne lit pas ThemeManager) pour éviter le crash d'environnement.

import SwiftUI
import UIKit

// Enum UNIQUE (niveau fichier)
private enum ThemeChoice: CaseIterable, Identifiable {
    case dark, light, blue, sepia, emerald
    var id: Self { self }

    var label: String {
        switch self {
        case .dark:    return "Thème Foncé"
        case .light:   return "Thème Clair"
        case .blue:    return "Thème Bleu"
        case .sepia:   return "Thème Sépia"
        case .emerald: return "Thème Émeraude"
        }
    }
}

// État persistant complet (valeurs enregistrées via ThemePersistence)
private struct PersistedThemeState {
    var background: Color
    var foreground: Color
    var secondary: Color
    var accent: Color
    var controlTint: Color
    var cardStartOpacity: Double
    var cardEndOpacity: Double
    var cardStartColor: Color
    var cardEndColor: Color
    var headerColor: Color

    static func loadFromDisk(using p: ThemePersistence = .shared, base: Theme) -> PersistedThemeState {
        PersistedThemeState(
            background:      p.loadBackgroundColor(default: base.background),
            foreground:      p.loadPrimaryTextColor(default: base.foreground),
            secondary:       p.loadSecondaryTextColor(default: base.secondary),
            accent:          p.loadIconColor(default: base.accent),
            controlTint:     p.loadControlTint(default: base.controlTint),
            cardStartOpacity:p.loadCardGradient(defaultStart: base.cardStartOpacity, defaultEnd: base.cardEndOpacity).0,
            cardEndOpacity:  p.loadCardGradient(defaultStart: base.cardStartOpacity, defaultEnd: base.cardEndOpacity).1,
            cardStartColor:  p.loadCardGradientColors(defaultStart: base.cardStartColor,  defaultEnd: base.cardEndColor).0,
            cardEndColor:    p.loadCardGradientColors(defaultStart: base.cardStartColor,  defaultEnd: base.cardEndColor).1,
            headerColor:     p.loadHeaderColor(default: base.headerColor)
        )
    }

    func saveToDisk(using p: ThemePersistence = .shared) {
        p.saveBackgroundColor(background)
        p.savePrimaryTextColor(foreground)
        p.saveSecondaryTextColor(secondary)
        p.saveIconColor(accent)
        p.saveControlTint(controlTint)
        p.saveCardGradient(start: cardStartOpacity, end: cardEndOpacity)
        p.saveCardGradientColors(start: cardStartColor, end: cardEndColor)
        p.saveHeaderColor(headerColor)
    }
}// Mapping roue -> ThemeID
private func themeID(for choice: ThemeChoice) -> ThemeID {
    switch choice {
    case .dark:    return .aetherionDark
    case .light:   return .aetherionLight
    case .blue:    return .aetherionBlue
    case .sepia:   return .aetherionSepia
    case .emerald: return .aetherionEmerald
    }
}

// Inverse ThemeID -> ThemeChoice
private func choice(for id: ThemeID) -> ThemeChoice {
    switch id {
    case .aetherionDark:    return .dark
    case .aetherionLight:   return .light
    case .aetherionBlue:    return .blue
    case .aetherionSepia:   return .sepia
    case .aetherionEmerald: return .emerald
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

    static func fromTheme(_ t: Theme) -> LocalTheme {
        LocalTheme(
            background: t.background,
            foreground: t.foreground,
            secondary: t.secondary,
            accent: t.accent,
            controlTint: t.controlTint,
            cardStartOpacity: t.cardStartOpacity,
            cardEndOpacity: t.cardEndOpacity,
            cardStartColor: t.cardStartColor,
            cardEndColor: t.cardEndColor,
            cornerRadius: t.cornerRadius,
            headerColor: t.headerColor
        )
    }

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

// === UIPickerView roue de thèmes (texte coloré via attributedTitleForRow)
private struct ThemeWheelPicker: UIViewRepresentable {
    var options: [ThemeChoice]
    @Binding var selection: ThemeChoice
    var textColor: Color                  // même source que les boutons (themeManager.theme.foreground)
    var onChange: (ThemeChoice) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UIPickerView {
        let v = UIPickerView()
        v.dataSource = context.coordinator
        v.delegate   = context.coordinator
        if let idx = options.firstIndex(of: selection) {
            v.selectRow(idx, inComponent: 0, animated: false)
        }
        return v
    }

    func updateUIView(_ uiView: UIPickerView, context: Context) {
        uiView.reloadAllComponents()
        if let idx = options.firstIndex(of: selection),
           uiView.selectedRow(inComponent: 0) != idx {
            uiView.selectRow(idx, inComponent: 0, animated: false)
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        let parent: ThemeWheelPicker
        init(_ parent: ThemeWheelPicker) { self.parent = parent }

        func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.options.count
        }

        func pickerView(_ pickerView: UIPickerView,
                        attributedTitleForRow row: Int,
                        forComponent component: Int) -> NSAttributedString? {
            let name = parent.options[row].label
            let uiColor = UIColor(parent.textColor)
            return NSAttributedString(string: name, attributes: [.foregroundColor: uiColor])
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            let choice = parent.options[row]
            parent.selection = choice
            parent.onChange(choice)
        }
    }
}

// MARK: - SettingsView (autonome)
struct ThemeDefautlView: View {
    // Thème visuel local à l’écran
    @State private var theme = LocalTheme.load()
    @State private var showVisualisation: Bool = false
    @State private var initialThemeID: ThemeID = .aetherionDark
    @State private var initialSnapshot: Theme? = nil          // snapshot mémoire
    @State private var initialPersisted: PersistedThemeState? = nil // snapshot disque
    @State private var didApply: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    // Pour appliquer globalement
    @EnvironmentObject private var themeManager: ThemeManager

    // Sélection de la roue
    @State private var selectedChoice: ThemeChoice = .dark



    // applique le thème choisi (aperçu live)
    private func applyTheme(for choice: ThemeChoice) {
        let tid = themeID(for: choice)
        let t   = Theme.preset(tid)
        withAnimation(.easeInOut) {
            themeManager.theme = t
            themeManager.updateBackgroundColor(t.background)
            themeManager.updateHeaderColor(t.headerColor)
            themeManager.updatePrimaryTextColor(t.foreground)
            theme = LocalTheme.fromTheme(t)
            didApply = false
        }
    }

    private func applyAction() {
        let t = themeManager.theme
        // 1) Sauvegarde sur disque de l’état actuel (confirmé)
        let p = ThemePersistence.shared
        p.saveBackgroundColor(t.background)
        p.savePrimaryTextColor(t.foreground)
        p.saveSecondaryTextColor(t.secondary)
        p.saveIconColor(t.accent)
        p.saveControlTint(t.controlTint)
        p.saveCardGradient(start: t.cardStartOpacity, end: t.cardEndOpacity)
        p.saveCardGradientColors(start: t.cardStartColor, end: t.cardEndColor)
        p.saveHeaderColor(t.headerColor)

        // 2) Met à jour la baseline mémoire + disque (ce qui sera “l’état d’arrivée” après apply)
        initialThemeID   = t.id
        initialSnapshot  = t
        initialPersisted = PersistedThemeState.loadFromDisk(using: p, base: t)

        // 3) Marque comme appliqué (on ne restaurera plus à la sortie)
        didApply = true
    }

    private func restoreSnapshot() {
        guard let snap = initialSnapshot else { return }
        // restaure la persistance aussi (si tu as ajouté initialPersisted)
        initialPersisted?.saveToDisk()
        withAnimation(.easeInOut) {
            themeManager.theme = snap
            themeManager.updateBackgroundColor(snap.background)
            themeManager.updateHeaderColor(snap.headerColor)
            themeManager.updatePrimaryTextColor(snap.foreground)
            theme = LocalTheme.fromTheme(snap)
            selectedChoice = choice(for: initialThemeID)
        }
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
                                    Text(selectedChoice.label)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(theme.foreground)

                                    let isPreset = (selectedChoice == .dark || selectedChoice == .light)
                                    Text(isPreset ? "Thème de l’application" : "Thème enregistré")
                                        .font(.subheadline)
                                        .foregroundStyle(theme.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 6)
                        }

                        // Pavé : Visualisation
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
                        // Section : Choix du thème
                        // =======================
                        VStack(alignment: .leading) {
                            Text("Choix du Thème")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(theme.foreground)
                                .padding(.top, 8)
                                .padding(.horizontal, 2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }

                        LocalCard(theme: theme) {
                            VStack(alignment: .leading, spacing: 8) {
                                ThemeWheelPicker(
                                    options: Array(ThemeChoice.allCases),
                                    selection: $selectedChoice,
                                    textColor: themeManager.theme.foreground   // même couleur que les boutons
                                ) { choice in
                                    applyTheme(for: choice)                    // aperçu live
                                }
                                .frame(height: 140)
                                .clipped()
                                .id(themeManager.theme.id.rawValue)           // force le refresh quand le thème change
                            }
                        }

                        // Récap’ nom + origine (pavé séparé)
                        LocalCard(theme: theme) {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(selectedChoice.label)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(theme.foreground)

                                    let isPreset = (selectedChoice == .dark || selectedChoice == .light)
                                    Text(isPreset ? "Thème de l’application" : "Thème enregistré")
                                        .font(.subheadline)
                                        .foregroundStyle(theme.secondary)
                                }
                                .padding(.top, 4)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)

                        // --- Actions (Annuler / Appliquer) ---
                        HStack(spacing: 12) {
                            Button {
                                restoreSnapshot()               // ⬅️ revient aux couleurs d’avant
                            } label: {
                                ThemedCard(fixedHeight: 56) {
                                    HStack {
                                        Spacer()
                                        Text("Annuler")
                                            .font(.headline.bold())
                                            .foregroundStyle(themeManager.theme.accent)
                                        Spacer()
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Button {
                                applyAction()                   // ⬅️ confirme et garde les couleurs
                            } label: {
                                ThemedCard(fixedHeight: 56) {
                                    HStack {
                                        Spacer()
                                        Text("Apliquer")
                                            .font(.headline.bold())
                                            .foregroundStyle(themeManager.theme.accent)
                                        Spacer()
                                    }
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
        
        // Snapshot initial à l’arrivée
        .onAppear {
            // Snapshot mémoire initial
            initialThemeID  = themeManager.theme.id
            let lt          = LocalTheme.load()
            initialSnapshot = Theme(
                id: initialThemeID,
                background: lt.background,
                foreground: lt.foreground,
                secondary: lt.secondary,
                accent: lt.accent,
                controlTint: lt.controlTint,
                cardStartOpacity: lt.cardStartOpacity,
                cardEndOpacity: lt.cardEndOpacity,
                cardStartColor: lt.cardStartColor,
                cardEndColor: lt.cardEndColor,
                cornerRadius: themeManager.theme.cornerRadius,
                headerFontSize: themeManager.theme.headerFontSize,
                headerFontWeight: themeManager.theme.headerFontWeight,
                headerFontDesign: themeManager.theme.headerFontDesign,
                headerColor: lt.headerColor
            )
            // Snapshot disque initial
            initialPersisted = PersistedThemeState.loadFromDisk(using: .shared, base: themeManager.theme)
            selectedChoice   = choice(for: initialThemeID)
            didApply         = false
        }
        .onDisappear {
            // Si on quitte par le bouton Retour sans avoir "Appliquer" → restaurer tout
            if !didApply {
                restoreSnapshot()
            }
        }
        // Toute modification invalide l’état appliqué
        .onChange(of: selectedChoice) { _ in
            didApply = false
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // Si l’utilisateur n’a PAS cliqué “Appliquer”, on restaure AVANT de quitter
                    if !didApply {
                        withAnimation(.easeInOut) {
                            restoreSnapshot()
                        }
                    }
                    dismiss()
                } label: {
                    // Chevron système, même look que le back natif
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                        Text("Retour")
                    }
                    .foregroundStyle(themeManager.theme.accent) // même teinte que le thème
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ThemeDefautlView()
            .environmentObject(ThemeManager(default: .aetherionDark)) // évite le crash d'env
    }
}
