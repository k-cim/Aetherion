// === File: Features/Settings/ThemeDefaultView.swift
// Version: 2.2
// Date: 2025-09-15
// Rôle : Afficher les thèmes (bundle + Documents) via ThemeCatalog,
//        prévisualiser en LIVE, Appliquer/Reset, rollback si on quitte sans appliquer.
// Note : fichier unique dans la target (avec la typo "Defautl") pour éviter toute confusion.

import SwiftUI

// Carte de prévisualisation indépendante (on injecte `theme`)
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

private struct WheelChoice: Identifiable, Equatable {
    enum Kind: Equatable {
        case preset(ThemeID)                 // item /dev/null mappé à ThemeID
        case bundle(url: URL, rawID: String) // JSON réel (bundle/Documents)
        case userUnsaved                     // thème modifié non persisté
    }
    var id: String
    var name: String
    var kind: Kind
}

struct ThemeDefaultView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // Aperçu local (pour peindre les cartes)
    @State private var preview: Theme = Theme.preset(.aetherionDark)

    // Données roue
    @State private var choices: [WheelChoice] = []
    @State private var selectedChoiceID: String = ""
    private var selectedChoice: WheelChoice? { choices.first { $0.id == selectedChoiceID } }

    // Debug
    @State private var showJsonSheet = false
    @State private var debugRows: [String] = []

    // Snapshot d’entrée + commit
    @State private var enterSnapshot: Theme? = nil
    @State private var committed: Bool = false

    // Persistance d’ID
    private let ud = UserDefaults.standard
    private let selectedKey = "ae.selectedThemeID"

    private var persistedID: ThemeID {
        ud.string(forKey: selectedKey).flatMap(ThemeID.init) ?? themeManager.theme.id
    }

    // MARK: - Wheel building

    private func rebuildFromGlobal() {
        let current = themeManager.theme
        preview = current

        let persistedID = ud.string(forKey: "ae.selectedThemeID").flatMap(ThemeID.init)
        let lastRaw = ud.string(forKey: "ae.lastSelectedRawID")

        let items = ThemeCatalog.shared.listThemes()
        var built: [WheelChoice] = []

        for it in items {
            if it.fileURL.path == "/dev/null", let tid = ThemeID(rawValue: it.id) {
                built.append(.init(id: "preset.\(tid.rawValue)", name: it.displayName, kind: .preset(tid)))
            } else {
                built.append(.init(id: "bundle.\(it.id)", name: it.displayName, kind: .bundle(url: it.fileURL, rawID: it.id)))
            }
        }

        built.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        // Ajoute "non enregistré" uniquement à titre d'info dans la roue (pas sélection auto)
        if themeManager.colorModified {
            built.append(.init(id: "user.unsaved", name: "Thème non enregistré", kind: .userUnsaved))
        }

        // 1) Si la sélection actuelle existe encore, on la garde (évite les sauts visuels)
        if built.contains(where: { $0.id == selectedChoiceID }) {
            choices = built
            return
        }

        // 2) Si on a un rawID JSON mémorisé
        if let raw = lastRaw {
            let tag = "bundle.\(raw)"
            if built.contains(where: { $0.id == tag }) {
                selectedChoiceID = tag
                choices = built
                return
            }
        }

        // 3) Si on a un ID enum persisté
        if let pid = persistedID {
            let tag = "preset.\(pid.rawValue)"
            if built.contains(where: { $0.id == tag }) {
                selectedChoiceID = tag
                choices = built
                return
            }
        }

        // 4) Fallback : premier item
        selectedChoiceID = built.first?.id ?? ""
        choices = built
    }

    private func handleSelectionChange() {
        guard let choice = selectedChoice else { return }

        let t: Theme
        switch choice.kind {
        case .preset(let pid):
            t = UserThemeStore.loadTheme(for: pid)   // Override > JSON > preset
        case .bundle(let url, let rawID):
            let fb = ThemeID(rawValue: rawID)
            t = ThemeBundleStore.loadTheme(from: url, fallbackID: fb) ?? Theme.preset(.aetherionDark)
        case .userUnsaved:
            // Vue “info” seulement : on reste sur l’état actuel
            return
        }

        // LIVE (toutes les vues suivent)
        themeManager.applyTheme(t)
        preview = t
    }

    private func actionReset() {
        guard let snap = enterSnapshot else { return }
        themeManager.applyTheme(snap) // rollback à l'état d'entrée
        preview = snap
        committed = true
    }

    private func actionApply() {
        guard let choice = selectedChoice else { return }

        switch choice.kind {
        case .preset(let pid):
            // 1) Palette LIVE
            let t = UserThemeStore.loadTheme(for: pid)
            themeManager.applyTheme(t)
            // 2) Persistance (ID connu)
            themeManager.persistSelectedID(pid)                    // ae.selectedThemeID
            ud.removeObject(forKey: "ae.lastSelectedRawID")        // nettoie ancien rawID
            // 3) UI / flags
            preview = t
            themeManager.endColorEditing()
            committed = true
            // 4) Verrouille la sélection sur l'item appliqué
            selectedChoiceID = "preset.\(pid.rawValue)"

        case .bundle(let url, let rawID):
            // 1) Palette LIVE
            let fb = ThemeID(rawValue: rawID)
            let t = ThemeCatalog.shared.loadTheme(from: .init(id: rawID, displayName: rawID, fileURL: url))
                ?? Theme.preset(fb ?? .aetherionDark)
            themeManager.applyTheme(t)
            // 2) Persistance (toujours rawID ; + ID si convertible)
            ud.set(rawID, forKey: "ae.lastSelectedRawID")
            if let pid = fb { themeManager.persistSelectedID(pid) }
            // 3) UI / flags
            preview = t
            themeManager.endColorEditing()
            committed = true
            // 4) Verrouille la sélection sur l'item appliqué
            selectedChoiceID = "bundle.\(rawID)"

        case .userUnsaved:
            // On valide l'état courant et on le rend durable en override disque (sans toucher l'ID)
            themeManager.persistCurrentThemeToDisk()
            // On peut garder l'indicateur "modifié" si tu veux signaler le statut "ad hoc"
            themeManager.beginColorEditing()
            committed = true
        }
    }

    private func canApply() -> Bool {
        guard let c = selectedChoice else { return false }
        switch c.kind {
        case .preset(let pid): return pid != persistedID
        case .bundle:          return true
        case .userUnsaved:     return false
        }
    }

    // MARK: - Snapshot / lifecycle

    private func snapshotEnter() {
        enterSnapshot = themeManager.theme
        committed = false
    }

    private func handleDisappear() {
        if !committed, let snap = enterSnapshot {
            themeManager.applyTheme(snap) // rollback simple
        }
    }

    private func buildDebugRows() {
        let items = ThemeCatalog.shared.listThemes()
        debugRows = items.map { "\($0.displayName) | id: \($0.id) | \($0.fileURL.lastPathComponent)" }
    }

    // MARK: - UI

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                // En-tête
                HStack {
                    Text("Thème")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(themeManager.theme.headerColor)
                    Spacer()
                    Button {
                        buildDebugRows()
                        showJsonSheet = true
                    } label: {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(themeManager.theme.accent)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Carte titre + statut
                        PreviewCard(theme: preview) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(selectedChoice?.name ?? "—")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(preview.foreground)
                                let isUnsaved = (selectedChoice?.kind == .userUnsaved)
                                Text(isUnsaved ? "Thème non enregistré" : "Thème bundle/preset")
                                    .font(.subheadline)
                                    .foregroundStyle(preview.secondary)
                            }
                        }

                        // Carte roue
                        PreviewCard(theme: preview) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Choix du Thème")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(preview.foreground)
                                Picker("Thème", selection: $selectedChoiceID) {
                                    ForEach(choices) { c in Text(c.name).tag(c.id) }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 140)
                                .onChange(of: selectedChoiceID) { _ in handleSelectionChange() }
                            }
                        }

                        // Actions
                        HStack(spacing: 12) {
                            Button(action: actionReset) {
                                PreviewCard(theme: preview, fixedHeight: 56) {
                                    HStack {
                                        Spacer()
                                        Text("Réinitialiser")
                                            .font(.headline.bold())
                                            .foregroundStyle(preview.foreground)
                                        Spacer()
                                    }
                                }
                            }
                            .buttonStyle(.plain)

                            Button(action: actionApply) {
                                PreviewCard(theme: preview, fixedHeight: 56) {
                                    HStack {
                                        Spacer()
                                        Text("Appliquer")
                                            .font(.headline.bold())
                                            .foregroundStyle(preview.foreground)
                                        Spacer()
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .disabled(!canApply())
                        }
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear { rebuildFromGlobal(); snapshotEnter() }
        // IMPORTANT : ne pas rebuilder à chaque changement de theme pour éviter les reboucles
        // .onReceive(themeManager.$theme) { _ in rebuildFromGlobal() }
        .onReceive(themeManager.$colorModified) { _ in rebuildFromGlobal() }
        .onDisappear { handleDisappear() }
        .sheet(isPresented: $showJsonSheet) {
            NavigationStack {
                List(debugRows, id: \.self) {
                    Text($0).font(.caption.monospaced())
                }
                .navigationTitle("JSON détectés")
            }
        }
    }
}
