// === File: ShareView.swift
// Version: 1.0
// Date: 2025-08-29 20:45:00 UTC
// Description: SwiftUI view for Share feature. Displays share link generator.
// Author: K-Cim

import SwiftUI

struct ShareView: View {
    @StateObject private var vm = ShareViewModel()

    var body: some View {
        VStack(spacing: 16) {
            Text("Secure Sharing").font(.title3).bold()

            Button("Generate link (demo)") {
                vm.generateLink()
            }
            .buttonStyle(.borderedProminent)

            if let link = vm.link {
                Text(link)
                    .font(.footnote)
                    .textSelection(.enabled)
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Share")
    }
}

#Preview { ShareView() }
