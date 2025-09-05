// === File:
// Date: 2025-09-04

import SwiftUI

struct AppContainerView: View {
    var body: some View {
        ThemedScreen {
            RootSwitch()   // juste l’agrégateur d’écrans
        }
        .safeAreaInset(edge: .bottom) {
            ThemedBottomBar(current: .home)   // l’onglet actif est géré par AppRouter dans la barre
        }
    }
}
