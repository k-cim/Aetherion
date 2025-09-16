// === File: NavigationCoordinator.swift
// Version: 1.1 (global path)
// Date: 2025-09-14
// Description: Coordonnateur de navigation global pour NavigationStack(path:).

import SwiftUI

@MainActor
final class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func push(_ value: any Hashable) {
        path.append(value)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToRoot() {
        path = NavigationPath()
    }
}
