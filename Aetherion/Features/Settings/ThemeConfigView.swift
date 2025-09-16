// === File: Features/Settings/ThemeConfigView.swift
// Version: 2.0
// Date: 2025-09-14
// Rôle: Édition des couleurs avec live preview globale ; Appliquer (live, non sauvegardé),
//       Enregistrer (persistance JSON override + flag OFF), Annuler (rollback).
// Author: K-Cim

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

    // Prévisualisation locale (pour peindre les cartes de CETTE vue)
    @State private var preview: Theme = Theme.preset(.aetherionDark)

    // Snapshot pour rollback (état d’entrée)
    private struct Snapshot {
        var theme: Theme
        var start: Double; var end: Double
        var startColor: Color; var endColor: Color
        var bgColor: Color
        var header: Color; var primary: Color; var secondary: Color
        var icon: Color; var control: Color
    }
    @State private var snapshot: Snapshot?

    // Sert si on quitte l’écran : si false, on rollback dans onDisappear
    @State private var committed: Bool = false

    private func syncFromDiskIfAvailable() {
        let url = ThemeOverrideDiskStore.fileURL()
        debugPrintFileInfo(url)
        if let disk = ThemeOverrideDiskStore.load() {
            print("📥 ThemeConfigView.load OVERRIDE →", debugSummarize(disk))
            themeManager.applyTheme(disk) // pousse en global
        } else {
            print("📥 ThemeConfigView.load OVERRIDE → rien à charger (fichier absent ou illisible)")
        }
    }
    
    // MARK: - Debug helpers (locaux à ThemeConfigView)

    private func debugSummarize(_ t: Theme) -> String {
        // résumé court et stable (évite de convertir précisément les Color)
        "id=\(t.id.rawValue) | bg=\(t.background) | fg=\(t.foreground) | sec=\(t.secondary) | acc=\(t.accent) | ctl=\(t.controlTint) | grad=\(String(format: "%.2f", t.cardStartOpacity))→\(String(format: "%.2f", t.cardEndOpacity)) | corner=\(Int(t.cornerRadius))"
    }

    private func debugPrintFileInfo(_ url: URL) {
        let fm = FileManager.default
        let exists = fm.fileExists(atPath: url.path)
        var sizeStr = "—"
        var mdate = "—"
        if let attrs = try? fm.attributesOfItem(atPath: url.path) {
            if let sz = attrs[.size] as? NSNumber {
                sizeStr = ByteCountFormatter.string(fromByteCount: sz.int64Value, countStyle: .file)
            }
            if let d = attrs[.modificationDate] as? Date {
                mdate = d.formatted(date: .numeric, time: .standard)
            }
        }
        print("📄 override file = \(url.path) | exists=\(exists) | size=\(sizeStr) | mtime=\(mdate)")
    }
    // MARK: - Helpers

    private func fmt(_ v: Double) -> String { String(format: "%.2f", v as CDouble) }

    /// Reconstruit un Theme à partir des @State, le pousse en GLOBAL (live) et met à jour preview.
    private func rebuildPreview(pushLive: Bool = true) {
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
            themeManager.applyTheme(t)
            themeManager.beginColorEditing() // flag = true (non enregistré)
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
            theme: t,
            start: start, end: end,
            startColor: startColor, endColor: endColor,
            bgColor: bgColor,
            header: headerColor, primary: textColor, secondary: secondaryTextColor,
            icon: iconColor, control: controlTint
        )
        preview = t
    }

    private func rollbackToSnapshot() {
        guard let s = snapshot else { return }
        start = s.start; end = s.end
        startColor = s.startColor; endColor = s.endColor
        bgColor    = s.bgColor
        headerColor = s.header
        textColor   = s.primary
        secondaryTextColor = s.secondary
        iconColor   = s.icon
        controlTint = s.control
        themeManager.applyTheme(s.theme) // remet GLOBAL à l’entrée
        preview = s.theme
    }

    // MARK: - Sous-vues

    @ViewBuilder private func header() -> some View {
        ThemedHeaderTitle(text: "Thème — Couleurs")
            .foregroundStyle(themeManager.theme.accent)
    }

    @ViewBuilder private func cardGradientOpacities() -> some View {
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

    @ViewBuilder private func cardGradientColors() -> some View {
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

    @ViewBuilder private func cardBackground() -> some View {
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

    @ViewBuilder private func cardTextColors() -> some View {
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

    @ViewBuilder private func cardIcons() -> some View {
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

    @ViewBuilder private func cardControls() -> some View {
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

    @ViewBuilder private func actionsBar() -> some View {
        HStack(spacing: 12) {
            // ANNULER -> rollback + flag OFF
            Button {
                rollbackToSnapshot()
                themeManager.endColorEditing()
                committed = true
            } label: {
                ThemedCard(fixedHeight: 56) {
                    HStack { Spacer()
                        Text("Annuler").font(.headline.bold()).foregroundStyle(preview.foreground)
                        Spacer() }
                }
            }
            .buttonStyle(.plain)

            Button {
                themeManager.applyTheme(preview)
                // Bouton APPLIQUER
                themeManager.applyTheme(preview)
                themeManager.persistCurrentThemeToDisk()   // ← garantit le reload au prochain lancement
                themeManager.beginColorEditing()
                committed = true

                let url = ThemeOverrideDiskStore.fileURL()
                print("💾 ThemeConfigView.save (APPLIQUER) →", debugSummarize(preview))
                do {
                    try ThemeOverrideDiskStore.save(theme: preview)
                    debugPrintFileInfo(url)
                    print("✅ save OK →", url.lastPathComponent)
                } catch {
                    print("⛔️ save ERROR:", error.localizedDescription)
                }

                themeManager.beginColorEditing() // reste “non enregistré” visuellement
                committed = true                 // évite rollback si on quitte
            } label: {
                HStack { Spacer()
                    Text("Appliquer").font(.headline.bold()).foregroundStyle(preview.foreground)
                    Spacer() }
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    // MARK: - Body

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
            // 1) relit le JSON override s’il existe (après un Apply précédent, un crash, etc.)
            syncFromDiskIfAvailable()

            // 2) Seed des contrôles + snapshot depuis le GLOBAL à jour
            loadInitialValuesAndSnapshot()

            // 3) Live immédiat pour feedback + flag
            rebuildPreview(pushLive: true)
            themeManager.beginColorEditing()
            committed = false
        }
        // Tous les contrôles -> live + flag ON
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
        // Si on quitte sans action -> rollback & flag OFF
        .onDisappear {
            if !committed {
                rollbackToSnapshot()
                themeManager.endColorEditing()
            }
        }
    }
}
