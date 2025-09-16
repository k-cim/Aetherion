// === File: AppRouter.swift
// Version: 2.0
// Date: 2025-09-14
// Description: Global tab router with persistence & basic deeplinks.

import SwiftUI

@MainActor
final class AppRouter: ObservableObject {

    enum Tab: String, CaseIterable, Identifiable, Codable {
        case home, vault, contacts, settings
        var id: String { rawValue }
    }

    @Published var tab: Tab {
        didSet { persist(tab) }
    }

    // MARK: - Persistence
    private let ud = UserDefaults.standard
    private let key = "ae.router.selectedTab"

    init(default initial: Tab = .home) {
        if let raw = ud.string(forKey: key), let saved = Tab(rawValue: raw) {
            self.tab = saved
        } else {
            self.tab = initial
        }
    }

    func select(_ t: Tab) { tab = t }

    func next() {
        let all = Tab.allCases
        guard let idx = all.firstIndex(of: tab) else { return }
        tab = all[(idx + 1) % all.count]
    }

    func previous() {
        let all = Tab.allCases
        guard let idx = all.firstIndex(of: tab) else { return }
        tab = all[(idx - 1 + all.count) % all.count]
    }

    /// aetherion://tab/<name> → sélectionne l’onglet si valide
    @discardableResult
    func handle(url: URL) -> Bool {
        guard url.scheme?.lowercased() == "aetherion",
              url.host?.lowercased() == "tab",
              let name = url.pathComponents.dropFirst().first,
              let t = Tab(rawValue: name.lowercased()) else { return false }
        tab = t
        return true
    }

    private func persist(_ t: Tab) { ud.set(t.rawValue, forKey: key) }
}
