import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {

                // Titre en haut (unis avec le thème)
                ThemedHeaderTitle(text: "Accueil")

                ScrollView {
                    VStack(spacing: 12) {

                        // Bandeau Aetherion avec logo si dispo
                        ThemedCard(fixedHeight: 64) {
                            HStack(spacing: 12) {
                                // ✅ Essaie d'afficher l'asset "AppLogo"; sinon fallback SF Symbol
                                if UIImage(named: "AppMark") != nil {
                                    Image("AppMark")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 40, height: 40)
                                } else {
                                    Image(systemName: "seal.fill")
                                        .font(.title2.weight(.semibold))
                                        .themedForeground(themeManager.theme)
                                        .frame(width: 40, height: 40, alignment: .center)
                                }

                                Text("Aetherion")
                                    .font(.title.bold())
                                    .themedForeground(themeManager.theme)

                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        // Carte "Entrer" -> Dashboard, NavigationLink DANS la carte (meilleure zone cliquable)
                        ThemedCard(fixedHeight: 80) {
                            NavigationLink {
                                DashboardView()
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Entrer")
                                        .font(.title2.bold())
                                        .themedForeground(themeManager.theme)
                                    Spacer()
                                }
                                .contentShape(Rectangle()) // ✅ toute la zone est cliquable
                            }
                            .buttonStyle(.plain)           // ✅ pas de style bouton qui écrase le fond
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 12)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        HomeView()
            .environmentObject(ThemeManager(default: .aetherionDark))
    }
}
