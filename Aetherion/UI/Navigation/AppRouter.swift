// === File: AppRouter.swift
// Date: 2025-09-04
// Description: Global tab router to drive bottom bar navigation safely.

import SwiftUI

final class AppRouter: ObservableObject {
    enum Tab: Hashable {
        case home, vault, contacts, settings
    }
    @Published var tab: Tab = .home
}
