// === File: Features/Settings/ThemeConfigView.swift
// Version: 1.4 (allègement type-checker, visuel inchangé)
// Description: Config couleur avec live preview + persistance JSON

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

    // Thème de prévisualisation (état local, pas computed pour épargner le type-checker)
    @State private var preview: Theme = Theme.preset(.aetherionDark)

    // Snapshot pour “Annuler”
    private struct Snapshot {
        var start: Double; var end: Double
        var startColor: Color; var endColor: Color
        var bgColor: Color
        var header: Color; var primary: Color; var secondary: Color
        var icon: Color; var control: Color
    }
    @State private var snapshot: Snapshot?

    // MARK: - Helpers

    private func fmt(_ v: Double) -> String {
        // évite les surcharges lourdes dans le body
        String(format: "%.2f", v as CDouble)
    }
    
    // Construit un Theme à partir des @State
    private func makePreviewTheme(from base: Theme) -> Theme {
        var t = base
        t.background       = bgColor
        t.cardStartOpacity = start
        t.cardEndOpacity   = end
        t.cardStartColor   = startColor
        t.cardEndColor     = endColor
        t.headerColor      = headerColor
        t.foreground       = textColor
        t.secondary        = secondaryTextColor
        t.accent           = iconColor
        t.controlTint      = controlTint
        return t
    }

    private func rebuildPreview() {
        rebuildPreview(pushLive: true)     // ← version “courte”, appelle la version détaillée
    }

    private func rebuildPreview(pushLive: Bool) {
        var t = themeManager.theme
        t.background       = bgColor
        t.cardStartOpacity = start
        t.cardEndOpacity   = end
        t.cardStartColor   = startColor
        t.cardEndColor     = endColor
        t.headerColor      = headerColor
        t.foreground       = textColor
        t.secondary        = secondaryTextColor
        t.accent           = iconColor
        t.controlTint      = controlTint

        preview = t

        if pushLive {
            // évite “Publishing changes from within view updates”
            DispatchQueue.main.async {
                themeManager.applyTheme(t)
            }
        }
    }

    private func loadInitialValuesAndSnapshot() {
        let t = themeManager.theme
        start      = t.cardStartOpacity
        end        = t.cardEndOpacity
        startColor = t.cardStartColor
        endColor   = t.cardEndColor
        bgColor    = t.background
        headerColor        = t.headerColor
        textColor          = t.foreground
        secondaryTextColor = t.secondary
        iconColor          = t.accent
        controlTint        = t.controlTint

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
        start = s.start; end = s.end
        startColor = s.startColor; endColor = s.endColor
        bgColor    = s.bgColor
        headerColor = s.header
        textColor   = s.primary
        secondaryTextColor = s.secondary
        iconColor   = s.icon
        controlTint = s.control
        rebuildPreview(pushLive: true)
    }

    // MARK: - Sous-vues (visuel inchangé, juste découpé)

    @ViewBuilder
    private func header() -> some View {
        ThemedHeaderTitle(text: "Thème — Couleurs")
    }

    @ViewBuilder
    private func cardGradientOpacities() -> some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dégradé des cartes (opacités)")
                    .font(.headline.bold())
                    .foregroundStyle(preview.foreground)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Opacité gauche").font(.caption).foregroundStyle(preview.secondary)
                    ColoredSlider(value: $start, range: 0...1, step: 0.01, tint: preview.controlTint)
                    Text(fmt(start)).font(.caption2).foregroundStyle(preview.secondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Opacité droite").font(.caption).foregroundStyle(preview.secondary)
                    ColoredSlider(value: $end, range: 0...1, step: 0.01, tint: preview.controlTint)
                    Text(fmt(end)).font(.caption2).foregroundStyle(preview.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func cardGradientColors() -> some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Dégradé des cartes (couleurs)")
                    .font(.headline.bold())
                    .foregroundStyle(preview.foreground)

                HStack {
                    Text("Couleur gauche").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $startColor, supportsOpacity: true).labelsHidden()
                }

                HStack {
                    Text("Couleur droite").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $endColor, supportsOpacity: true).labelsHidden()
                }
            }
        }
    }

    @ViewBuilder
    private func cardBackground() -> some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Couleur du fond")
                    .font(.headline.bold())
                    .foregroundStyle(preview.foreground)

                HStack {
                    Text("Fond de l’application").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $bgColor, supportsOpacity: true).labelsHidden()
                }
            }
        }
    }

    @ViewBuilder
    private func cardTextColors() -> some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Couleurs des textes")
                    .font(.headline.bold())
                    .foregroundStyle(preview.foreground)

                HStack {
                    Text("Titres").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $headerColor, supportsOpacity: true).labelsHidden()
                }

                HStack {
                    Text("Texte principal").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $textColor, supportsOpacity: true).labelsHidden()
                }

                HStack {
                    Text("Texte secondaire").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $secondaryTextColor, supportsOpacity: true).labelsHidden()
                }
            }
        }
    }

    @ViewBuilder
    private func cardIcons() -> some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Icônes")
                    .font(.headline.bold())
                    .foregroundStyle(preview.foreground)

                HStack {
                    Text("Couleur des icônes").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $iconColor, supportsOpacity: true).labelsHidden()
                }
            }
        }
    }

    @ViewBuilder
    private func cardControls() -> some View {
        ThemedCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Contrôles")
                    .font(.headline.bold())
                    .foregroundStyle(preview.foreground)

                HStack {
                    Text("Couleur des contrôles").font(.subheadline).foregroundStyle(preview.secondary)
                    Spacer()
                    ColorPicker("", selection: $controlTint, supportsOpacity: true).labelsHidden()
                }
            }
        }
    }

    @ViewBuilder
    private func actionsBar() -> some View {
        HStack(spacing: 12) {
            Button { cancelToSnapshot() } label: {
                ThemedCard(fixedHeight: 56) {
                    HStack { Spacer(); Text("Annuler").font(.headline.bold()).foregroundStyle(preview.foreground); Spacer() }
                }
            }
            .buttonStyle(.plain)

            Button {
                // 1) Applique globalement
                themeManager.applyTheme(preview)
                // 2) Persiste sur disque (JSON)
                themeManager.persistCurrentThemeToDisk()
            } label: {
                ThemedCard(fixedHeight: 56) {
                    HStack { Spacer(); Text("Appliquer").font(.headline.bold()).foregroundStyle(preview.foreground); Spacer() }
                }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    // MARK: - Body (visuel inchangé)
    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                header()

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        cardGradientOpacities()
                        cardGradientColors()
                        cardBackground()
                        cardTextColors()
                        cardIcons()
                        cardControls()
                        actionsBar()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            loadInitialValuesAndSnapshot()
            rebuildPreview(pushLive: false)
        }
        .onChange(of: start)              { _ in rebuildPreview(pushLive: true) }
        .onChange(of: end)                { _ in rebuildPreview(pushLive: true) }
        .onChange(of: startColor)         { _ in rebuildPreview(pushLive: true) }
        .onChange(of: endColor)           { _ in rebuildPreview(pushLive: true) }
        .onChange(of: bgColor)            { _ in rebuildPreview(pushLive: true) }
        .onChange(of: headerColor)        { _ in rebuildPreview(pushLive: true) }
        .onChange(of: textColor)          { _ in rebuildPreview(pushLive: true) }
        .onChange(of: secondaryTextColor) { _ in rebuildPreview(pushLive: true) }
        .onChange(of: iconColor)          { _ in rebuildPreview(pushLive: true) }
        .onChange(of: controlTint)        { _ in rebuildPreview(pushLive: true) }
        
        .onChange(of: start)              { _ in rebuildPreview() }
        .onChange(of: end)                { _ in rebuildPreview() }
        .onChange(of: startColor)         { _ in rebuildPreview() }
        .onChange(of: endColor)           { _ in rebuildPreview() }
        .onChange(of: bgColor)            { _ in rebuildPreview() }
        .onChange(of: headerColor)        { _ in rebuildPreview() }
        .onChange(of: textColor)          { _ in rebuildPreview() }
        .onChange(of: secondaryTextColor) { _ in rebuildPreview() }
        .onChange(of: iconColor)          { _ in rebuildPreview() }
        .onChange(of: controlTint)        { _ in rebuildPreview() }
    }
}
