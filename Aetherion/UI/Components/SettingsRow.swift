// === File: UI/Components/SettingsRow.swift
// Version: 3.0
// Date: 2025-09-14
// Description: Rangée de réglage unifiée (sans génériques, compatible toolchain strict).
//              Deux modes :
//              1) Préconfiguré (icône/titre/sous-titre)
//              2) Contenu custom (leading/centre/trailing)
//              Options : chevron, disabled, action, ThemedCard + hauteur fixe
// Author: K-Cim

import SwiftUI

struct SettingsRow: View {
    @EnvironmentObject private var themeManager: ThemeManager

    // Mode préconfiguré
    private let icon: String?
    private let title: String?
    private let subtitle: String?

    // Slots (facultatifs)
    private let leadingView: AnyView?
    private let centerView: AnyView?     // si non-nil, remplace (title/subtitle)
    private let trailingView: AnyView?

    // Comportement
    private let showsChevron: Bool
    private let disabled: Bool
    private let action: (() -> Void)?
    private let inCard: Bool
    private let fixedHeight: CGFloat?

    // MARK: - Init (mode préconfiguré)
    init(
        icon: String? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        showsChevron: Bool = true,
        disabled: Bool = false,
        inCard: Bool = true,
        fixedHeight: CGFloat? = 56,
        action: (() -> Void)? = nil,
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.showsChevron = showsChevron
        self.disabled = disabled
        self.inCard = inCard
        self.fixedHeight = fixedHeight
        self.action = action

        // Slots
        let lead = leading()
        self.leadingView = (lead is EmptyView) ? nil : AnyView(lead)

        self.centerView = nil

        let trail = trailing()
        self.trailingView = (trail is EmptyView) ? nil : AnyView(trail)
    }

    // MARK: - Init (mode contenu custom — remplace le centre)
    init(
        showsChevron: Bool = false,
        disabled: Bool = false,
        inCard: Bool = true,
        fixedHeight: CGFloat? = 56,
        action: (() -> Void)? = nil,
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder center: () -> some View,
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) {
        self.icon = nil
        self.title = nil
        self.subtitle = nil
        self.showsChevron = showsChevron
        self.disabled = disabled
        self.inCard = inCard
        self.fixedHeight = fixedHeight
        self.action = action

        // Slots
        let lead = leading()
        self.leadingView = (lead is EmptyView) ? nil : AnyView(lead)

        self.centerView = AnyView(center())

        let trail = trailing()
        self.trailingView = (trail is EmptyView) ? nil : AnyView(trail)
    }

    // MARK: - Body
    var body: some View {
        let t = themeManager.theme
        let leadingOpacity  = disabled ? 0.5 : 1.0
        let centerOpacity   = disabled ? 0.6 : 1.0
        let titleOpacity    = disabled ? 0.5 : 1.0
        let subtitleOpacity = disabled ? 0.5 : 0.8
        let chevronOpacity  = 0.5

        let row = HStack(spacing: 14) {

            if let leadingView { leadingView.opacity(leadingOpacity) }

            if let centerView {
                centerView.opacity(centerOpacity)
            } else {
                if let icon {
                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(t.secondary)
                        .opacity(disabled ? 0.4 : 1.0)
                }
                VStack(alignment: .leading, spacing: 2) {
                    if let title {
                        Text(title)
                            .font(.headline.weight(.bold))
                            .foregroundStyle(themeManager.fg)   // façade OK
                            .opacity(titleOpacity)
                    }
                    if let subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(t.secondary)
                            .opacity(subtitleOpacity)
                    }
                }
            }

            Spacer(minLength: 0)

            if let trailingView {
                trailingView.opacity(centerOpacity)
            } else if showsChevron && !disabled {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(t.secondary)
                    .opacity(chevronOpacity)
            }
        }
        .contentShape(Rectangle())
        .frame(height: fixedHeight)

        row
    }
    
}

