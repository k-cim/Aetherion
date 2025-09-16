// === File:/NavigationCoordinator
// Date: 2025-09-04

import SwiftUI

final class NavigationCoordinator: ObservableObject {
    @Published var path = NavigationPath()

    func popToRoot() { path = NavigationPath() }
}
