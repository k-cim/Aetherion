// === File: UI/Components/ThemedBottomBar.swift
// Version: 2.0 (lean build-friendly)
// Description: Bottom bar minimaliste, sûre pour le compilateur.
// Author: K-Cim


import SwiftUI

private let kBarHeight: CGFloat = 64

struct ThemedBottomBar: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var nav: NavigationCoordinator

    let current: AppRouter.Tab

    var body: some View {
        let t = themeManager.theme
        let radius = t.cornerRadius
        let start  = t.cardStartColor.opacity(t.cardStartOpacity)
        let end    = t.cardEndColor.opacity(t.cardEndOpacity)

        ZStack {
            // couche fond (couleur pure)
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(t.background)

            // couche gradient
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing))

            // trait
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)

            HStack(spacing: 0) {
                barItem(.home,     system: "house.fill",     label: "Accueil")
                barItem(.vault,    system: "lock.fill",      label: "Coffre")
                barItem(.contacts, system: "person.2.fill",  label: "Contacts")
                barItem(.settings, system: "gearshape.fill", label: "Paramètres")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .frame(height: kBarHeight)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(Color.clear)
    }

    @ViewBuilder
    private func barItem(_ tab: AppRouter.Tab, system: String, label: String) -> some View {
        let isActive = (router.tab == tab)
        let accent   = themeManager.theme.accent.opacity(isActive ? 0.66 : 1.0)

        Button {
            if router.tab != tab {
                nav.popToRoot()
                router.tab = tab
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: system)
                    .font(.body.weight(.semibold))
                Text(label)
                    .font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .foregroundStyle(accent)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
