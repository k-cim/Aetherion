// === File: ThemeConfigView.swift
// Version: 1.3
// Date: 2025-08-30 05:10:00 UTC
// Description: Theme configuration with live preview, Apply (persist), Reset (rollback), and bottom bar.
// Author: K-Cim

import SwiftUI

struct ThemeConfigView: View {
    @EnvironmentObject private var themeManager: ThemeManager

    @State private var startOpacity: Double = 0.30
    @State private var endOpacity: Double = 0.10
    @State private var hasLoadedFromTheme: Bool = false

    var body: some View {
        ThemedScreen {
            VStack(spacing: 16) {
                // Large title
                Text(NSLocalizedString("settings_theme", comment: "Theme"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .themedForeground(themeManager.theme)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // Preview
                ZStack {
                    ThemeStyle.screenBackground(themeManager.theme)
                    VStack(spacing: 20) {
                        ThemedCard {
                            HStack(spacing: 16) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 28))
                                    .themedSecondary(themeManager.theme)

                                Text("Aetherion")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .themedForeground(themeManager.theme)

                                Spacer()
                            }
                        }
                        PrimaryButton(title: "Sample Button") { }
                    }
                    .padding()
                }
                .frame(height: 220)
                .clipShape(RoundedRectangle(cornerRadius: 16))

                // Sliders (LIVE update)
                ThemedCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Card Gradient")
                            .font(.headline.weight(.bold))
                            .themedForeground(themeManager.theme)

                        HStack {
                            Text("Start")
                            Slider(value: $startOpacity, in: 0...1, step: 0.05)
                                .onChange(of: startOpacity) { new in
                                    themeManager.liveUpdateCardGradient(startOpacity: new, endOpacity: endOpacity)
                                }
                            Text(String(format: "%.2f", startOpacity))
                        }

                        HStack {
                            Text("End")
                            Slider(value: $endOpacity, in: 0...1, step: 0.05)
                                .onChange(of: endOpacity) { new in
                                    themeManager.liveUpdateCardGradient(startOpacity: startOpacity, endOpacity: new)
                                }
                            Text(String(format: "%.2f", endOpacity))
                        }
                    }
                }
                .padding(.horizontal, 16)

                // Actions
                HStack(spacing: 12) {
                    Button {
                        themeManager.applyCardGradient(startOpacity: startOpacity, endOpacity: endOpacity)
                    } label: {
                        Text("Apply")
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                    .fill(ThemeStyle.primaryButtonBackground(themeManager.theme))
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        themeManager.resetCardGradient()
                        // Sync sliders after rollback
                        startOpacity = themeManager.theme.cardStartOpacity
                        endOpacity   = themeManager.theme.cardEndOpacity
                    } label: {
                        Text("Reset")
                            .font(.headline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 16)
                            .background(
                                RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                    .fill(ThemeStyle.primaryButtonBackground(themeManager.theme))
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)

                Spacer(minLength: 12)
                ThemedBottomBar(current: .settings)
            }
        }
        .onAppear {
            guard !hasLoadedFromTheme else { return }
            startOpacity = themeManager.theme.cardStartOpacity
            endOpacity   = themeManager.theme.cardEndOpacity
            hasLoadedFromTheme = true
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThemeConfigView()
            .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
    }
}
