// === File: OnboardingView.swift
// Version: 1.0
// Date: 2025-08-29 20:45:00 UTC
// Description: SwiftUI view for onboarding process introduction.
// Author: K-Cim

import SwiftUI

struct OnboardingView: View {
    @StateObject private var vm = OnboardingViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Aetherion").font(.title).bold()
            Text("A distributed vault for your files.")
                .foregroundStyle(.secondary)

            Button("Continue") {
                vm.markDone()
            }
            .buttonStyle(.borderedProminent)

            Spacer()
        }
        .padding()
        .navigationTitle("Onboarding")
    }
}

#Preview { OnboardingView() }
