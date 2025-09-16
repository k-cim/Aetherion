// === File: App/AetherionApp.swift
import SwiftUI
import Foundation

@main
struct AetherionApp: App {
    @StateObject private var theme: ThemeManager
    @StateObject private var router = AppRouter()
    @StateObject private var nav    = NavigationCoordinator()

    init() {
        // Récupère le thème persistant (sinon dark)
        let saved = UserDefaults.standard.string(forKey: "ae.selectedThemeID")
        let initialID = saved.flatMap(ThemeID.init(rawValue:)) ?? .aetherionDark
        _theme = StateObject(wrappedValue: ThemeManager(default: initialID))
        
    #if DEBUG
    ThemeOverrideDiskStore._debugSelfTest()
    #endif
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $nav.path) {
                AppContainerView()
            }
            .environmentObject(theme)
            .environmentObject(router)
            .environmentObject(nav)
            .tint(theme.theme.accent) // ✅ utilise la proxy
        }
    }
}
