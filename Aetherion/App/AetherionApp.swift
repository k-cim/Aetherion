import SwiftUI

@main
struct AetherionApp: App {
    @StateObject private var theme  = ThemeManager(default: .aetherionDark)
    @StateObject private var router = AppRouter()
    @StateObject private var nav    = NavigationCoordinator()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $nav.path) {
                AppContainerView()
            }
            // injection globale (ThemedScreen, BottomBar, etc.)
            .environmentObject(theme)
            .environmentObject(router)
            .environmentObject(nav)
            .tint(theme.theme.accent)   // couleur du chevron retour & co
        }
    }
}
