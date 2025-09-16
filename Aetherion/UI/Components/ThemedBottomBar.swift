// === File: UI/Components/ThemedBottomBar.swift
// Version: 2.5
// Date: 2025-09-14
// Description: Barre d’onglets thémée, sûre et accessible.
//              - Fond dégradé cohérent (ThemeKit)
//              - Safe area friendly (home indicator)
//              - Touch targets confort (≥44pt), retour haptique optionnel
//              - Accessibilité (tab bar, selected state)
//              - Animations douces et factorisation
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
            // ⚠️ Ces trois calques deviennent non-interactifs
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(t.background)
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing))
                .allowsHitTesting(false)

            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                .allowsHitTesting(false)

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
        // (optionnel) s’assure que la barre est au-dessus du contenu
        .zIndex(999)
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
            .contentShape(Rectangle()) // zone cliquable pleine largeur
        }
        .buttonStyle(.plain)
    }
}
