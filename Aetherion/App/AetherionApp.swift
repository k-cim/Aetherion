// === File: AetherionApp.swift
// Version: 1.1
// Date: 2025-08-30 05:35:00 UTC
// Description: Main application entry point for Aetherion, injects ThemeManager.
// Author: K-Cim

import SwiftUI

@main
struct AetherionApp: App {
    @StateObject private var .environmentObject(ThemeManager(default: ThemeID.aetherionDark))

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(themeManager)
        }
    }
}
