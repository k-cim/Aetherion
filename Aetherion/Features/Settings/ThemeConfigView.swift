import SwiftUI

struct ThemeConfigView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // Dégradé
    @State private var start: Double = 0.30
    @State private var end:   Double = 0.10
    @State private var startColor: Color = .white
    @State private var endColor:   Color = .white

    // Fond
    @State private var bgColor: Color = .black

    // Textes
    @State private var headerColor: Color = .white
    @State private var textColor:   Color = .white
    @State private var secondaryTextColor: Color = .white.opacity(0.7)

    // Icônes & Contrôles
    @State private var iconColor: Color = .white.opacity(0.85)
    @State private var controlTint: Color = .white.opacity(0.85)

    // 🎯 Snapshot de session (état avant modifs)
    private struct Snapshot {
        var start: Double; var end: Double
        var startColor: Color; var endColor: Color
        var bgColor: Color
        var header: Color; var primary: Color; var secondary: Color
        var icon: Color; var control: Color
    }
    @State private var snapshot: Snapshot?

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {

                ThemedHeaderTitle(text: "Thème")

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // --- Dégradé (opacités) ---
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dégradé des cartes (opacités)")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Opacité gauche").font(.caption).themedSecondary(themeManager.theme)
                                    ColoredSlider(value: $start, range: 0...1, step: 0.01, tint: themeManager.theme.controlTint)
                                    Text(String(format: "%.2f", start)).font(.caption2).themedSecondary(themeManager.theme)
                                }

                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Opacité droite").font(.caption).themedSecondary(themeManager.theme)
                                    ColoredSlider(value: $end, range: 0...1, step: 0.01, tint: themeManager.theme.controlTint)
                                    Text(String(format: "%.2f", end)).font(.caption2).themedSecondary(themeManager.theme)
                                }
                            }
                        }

                        // --- Dégradé (couleurs) ---
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Dégradé des cartes (couleurs)")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                HStack {
                                    Text("Couleur gauche").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $startColor, supportsOpacity: true).labelsHidden()
                                }

                                HStack {
                                    Text("Couleur droite").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $endColor, supportsOpacity: true).labelsHidden()
                                }
                            }
                        }

                        // --- Couleur du fond ---
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Couleur du fond")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                HStack {
                                    Text("Fond de l’application").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $bgColor, supportsOpacity: true).labelsHidden()
                                }
                            }
                        }

                        // --- Couleurs des textes ---
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Couleurs des textes")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                HStack {
                                    Text("Titres").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $headerColor, supportsOpacity: true).labelsHidden()
                                }

                                HStack {
                                    Text("Texte principal").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $textColor, supportsOpacity: true).labelsHidden()
                                }

                                HStack {
                                    Text("Texte secondaire").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $secondaryTextColor, supportsOpacity: true).labelsHidden()
                                }
                            }
                        }

                        // --- Icônes ---
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Icônes")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                HStack {
                                    Text("Couleur des icônes").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $iconColor, supportsOpacity: true).labelsHidden()
                                }
                            }
                        }

                        // --- Contrôles ---
                        ThemedCard {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Contrôles")
                                    .font(.headline.weight(.bold))
                                    .themedForeground(themeManager.theme)

                                HStack {
                                    Text("Couleur des contrôles").font(.subheadline).themedSecondary(themeManager.theme)
                                    Spacer()
                                    ColorPicker("", selection: $controlTint, supportsOpacity: true).labelsHidden()
                                }
                            }
                        }

                        // --- Actions (Annuler / Réinitialiser) ---
                        HStack(spacing: 12) {
                            Button { cancelToSnapshot() } label: {
                                ThemedCard(fixedHeight: 56) {
                                    HStack { Spacer(); Text("Annuler").font(.headline.bold()).themedForeground(themeManager.theme); Spacer() }
                                }
                            }
                            .buttonStyle(.plain)

                            Button { resetAll() } label: {
                                ThemedCard(fixedHeight: 56) {
                                    HStack { Spacer(); Text("Réinitialiser").font(.headline.bold()).themedForeground(themeManager.theme); Spacer() }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear(perform: loadInitialValuesAndSnapshot)
        // live update
        .onChange(of: start)             { themeManager.updateCardGradient(start: $0, end: end) }
        .onChange(of: end)               { themeManager.updateCardGradient(start: start, end: $0) }
        .onChange(of: startColor)        { themeManager.updateGradientColors(start: $0, end: endColor) }
        .onChange(of: endColor)          { themeManager.updateGradientColors(start: startColor, end: $0) }
        .onChange(of: bgColor)           { themeManager.updateBackgroundColor($0) }
        .onChange(of: headerColor)       { themeManager.updateHeaderColor($0) }
        .onChange(of: textColor)         { themeManager.updatePrimaryTextColor($0) }
        .onChange(of: secondaryTextColor){ themeManager.updateSecondaryTextColor($0) }
        .onChange(of: iconColor)         { themeManager.updateIconColor($0) }
        .onChange(of: controlTint)       { themeManager.updateControlTint($0) }
    }

    // MARK: - Init & Session snapshot

    private func loadInitialValuesAndSnapshot() {
        // valeurs UI
        start      = themeManager.theme.cardStartOpacity
        end        = themeManager.theme.cardEndOpacity
        startColor = themeManager.theme.cardStartColor
        endColor   = themeManager.theme.cardEndColor
        bgColor    = themeManager.backgroundColor
        headerColor        = themeManager.theme.headerColor
        textColor          = themeManager.theme.foreground
        secondaryTextColor = themeManager.theme.secondary
        iconColor          = themeManager.theme.accent
        controlTint        = themeManager.theme.controlTint

        // snapshot de session
        snapshot = Snapshot(
            start: start, end: end,
            startColor: startColor, endColor: endColor,
            bgColor: bgColor,
            header: headerColor, primary: textColor, secondary: secondaryTextColor,
            icon: iconColor, control: controlTint
        )
    }

    private func cancelToSnapshot() {
        guard let s = snapshot else { return }
        // réapplique l’état d’entrée de l’écran (live)
        start = s.start; end = s.end
        startColor = s.startColor; endColor = s.endColor
        bgColor    = s.bgColor
        headerColor = s.header
        textColor   = s.primary
        secondaryTextColor = s.secondary
        iconColor   = s.icon
        controlTint = s.control

        themeManager.updateCardGradient(start: start, end: end)
        themeManager.updateGradientColors(start: startColor, end: endColor)
        themeManager.updateBackgroundColor(bgColor)
        themeManager.updateHeaderColor(headerColor)
        themeManager.updatePrimaryTextColor(textColor)
        themeManager.updateSecondaryTextColor(secondaryTextColor)
        themeManager.updateIconColor(iconColor)
        themeManager.updateControlTint(controlTint)
    }

    private func resetAll() {
        let p = Theme.preset(themeManager.theme.id)
        start      = p.cardStartOpacity
        end        = p.cardEndOpacity
        startColor = p.cardStartColor
        endColor   = p.cardEndColor
        bgColor    = (p.id == .aetherionDark) ? .black : .white
        headerColor        = p.headerColor
        textColor          = p.foreground
        secondaryTextColor = p.secondary
        iconColor          = p.accent
        controlTint        = p.controlTint

        // on met aussi à jour le snapshot pour que "Annuler" revienne à ce nouvel état si tu le souhaites
        snapshot = Snapshot(
            start: start, end: end,
            startColor: startColor, endColor: endColor,
            bgColor: bgColor,
            header: headerColor, primary: textColor, secondary: secondaryTextColor,
            icon: iconColor, control: controlTint
        )

        themeManager.updateCardGradient(start: start, end: end)
        themeManager.updateGradientColors(start: startColor, end: endColor)
        themeManager.updateBackgroundColor(bgColor)
        themeManager.updateHeaderColor(headerColor)
        themeManager.updatePrimaryTextColor(textColor)
        themeManager.updateSecondaryTextColor(secondaryTextColor)
        themeManager.updateIconColor(iconColor)
        themeManager.updateControlTint(controlTint)
    }
}
