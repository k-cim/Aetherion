import SwiftUI

private let BOTTOM_BAR_HEIGHT: CGFloat = 64
private let BAR_BASE_OPACITY: Double = 1.0

struct ThemedBottomBar: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter
    @EnvironmentObject private var nav: NavigationCoordinator
    let current: AppRouter.Tab

    var body: some View {
        let radius = themeManager.theme.cornerRadius
        let start = themeManager.theme.cardStartColor.opacity(themeManager.theme.cardStartOpacity)
        let end   = themeManager.theme.cardEndColor.opacity(themeManager.theme.cardEndOpacity)

        ZStack {
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(themeManager.backgroundColor.opacity(BAR_BASE_OPACITY))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .fill(LinearGradient(colors: [start, end], startPoint: .leading, endPoint: .trailing))
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08))

            HStack(spacing: 0) {
                item(.home,     "house.fill",        "Accueil")
                item(.vault,    "lock.fill",         "Coffre")
                item(.contacts, "person.2.fill",     "Contacts")
                item(.settings, "gearshape.fill",    "Paramètres")
            }
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
        .frame(height: BOTTOM_BAR_HEIGHT)
        .padding(.horizontal, 12)
        .padding(.top, 6)
        .padding(.bottom, 8)
        .background(Color.clear)
    }

    @ViewBuilder
    private func item(_ tab: AppRouter.Tab, _ icon: String, _ label: String) -> some View {
        let isActive = (router.tab == tab)
        Button {
            if router.tab != tab {
                nav.popToRoot()     // 👈 on revient à la racine
                router.tab = tab    // 👈 on change d’onglet
            }
        } label: {
            VStack(spacing: 2) {
                Image(systemName: icon).font(.body.weight(.semibold))
                Text(label).font(.caption2.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .foregroundStyle(themeManager.theme.accent.opacity(isActive ? 0.66 : 1.0))
        }
        .buttonStyle(.plain)
    }
}
