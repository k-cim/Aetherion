// === File: HomeView.swift
// Version: 2.4
// Date: 2025-08-30 04:55:00 UTC
// Description: Welcome screen with top-left header, brand card, CTA, and persistent bottom bar.
// Author: K-Cim

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var goToDashboard = false

    var body: some View {
        NavigationStack {
            ThemedScreen {
                VStack(spacing: 28) {
                    // Top-left header + brand card
                    VStack(alignment: .leading, spacing: 12) {
                        Text(NSLocalizedString("home", comment: "Home header"))
                            .font(.title.bold())
                            .foregroundStyle(ThemeStyle.foreground(themeManager.theme))
                            .padding(.leading, 16)

                        // Brand card
                        HStack(spacing: 20) {
                            if let _ = UIImage(named: "AppMark") {
                                Image("AppMark")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .accessibilityHidden(true)
                            } else {
                                Image(systemName: "shield.lefthalf.fill")
                                    .font(.system(size: 40))
                                    .foregroundStyle(ThemeStyle.foreground(themeManager.theme))
                                    .accessibilityHidden(true)
                            }

                            Text("Aetherion")
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundStyle(ThemeStyle.foreground(themeManager.theme))

                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(
                            RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius, style: .continuous)
                                .fill(ThemeStyle.cardBackground(themeManager.theme))
                        )
                        .padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 40)

                    Spacer()

                    // Title + tagline
                    VStack(spacing: 6) {
                        Text(NSLocalizedString("home_title", comment: "App name"))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(ThemeStyle.foreground(themeManager.theme))

                        Text(NSLocalizedString("home_tagline", comment: "Tagline"))
                            .font(.subheadline)
                            .foregroundStyle(ThemeStyle.secondary(themeManager.theme))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                    }

                    // CTA
                    PrimaryButton(
                        title: NSLocalizedString("home_enter", comment: "Enter button")
                    ) {
                        goToDashboard = true
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Bottom bar (always last)
                    ThemedBottomBar(current: .home)
                }
            }
            .navigationDestination(isPresented: $goToDashboard) {
                DashboardView()
            }
        }
    }
}

#Preview("FR") {
    HomeView()
        .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
        .environment(\.locale, .init(identifier: "fr"))
}
#Preview("EN") {
    HomeView()
        .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
        .environment(\.locale, .init(identifier: "en"))
}
