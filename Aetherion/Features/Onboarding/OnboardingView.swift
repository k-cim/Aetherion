// === File: Features/Onboarding/Onboarding.swift
// Version: 2.0
// Date: 2025-09-14
// Description: Onboarding (vue + viewmodel) — thémé, persistant, avec routage optionnel.
// Author: K-Cim

import SwiftUI
import Foundation

// MARK: - ViewModel
@MainActor
final class OnboardingViewModel: ObservableObject {
    private let key = "ae.onboarding.done"
    @Published var isDone: Bool

    init() {
        self.isDone = UserDefaults.standard.bool(forKey: key)
    }

    func markDone() {
        UserDefaults.standard.set(true, forKey: key)
        isDone = true
    }

    func reset() {
        UserDefaults.standard.set(false, forKey: key)
        isDone = false
    }
}

// MARK: - View
struct OnboardingView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var router: AppRouter   // optionnel : route vers Home quand terminé
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ThemedHeader(title: "Bienvenue", style: .plain)

                VStack(spacing: 20) {
                    ThemedCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Welcome to Aetherion")
                                .font(.title.bold())
                                .foregroundStyle(themeManager.theme.foreground)
                            Text("A distributed vault for your files.")
                                .foregroundStyle(themeManager.theme.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)

                    Button {
                        vm.markDone()
                        // Routage optionnel vers l’accueil si présent
                        router.select(.home)
                    } label: {
                        Text("Continuer")
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .padding(.horizontal, 16)

                    Button("Réinitialiser l’onboarding") {
                        vm.reset()
                    }
                    .buttonStyle(.bordered)
                    .tint(themeManager.theme.controlTint)
                    .padding(.horizontal, 16)
                    
                    // Spacer(minimum: 0)
                    // Spacer().frame(minWidth: 0)
                    Spacer().frame(minHeight: 0)
                }
                .padding(.bottom, 120)
            }
        }
        .navigationTitle("Onboarding")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        OnboardingView()
            .environmentObject(ThemeManager(default: .aetherionDark))
            .environmentObject(AppRouter())
    }
}
