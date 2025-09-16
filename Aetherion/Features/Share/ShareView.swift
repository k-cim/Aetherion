// === File: Features/Share/ShareView.swift
// Version: 3.0
// Date: 2025-09-14
// Description: Partage (Vue + ViewModel) — génération de lien async, affichage + copie, ShareSheet iOS.
// Author: K-Cim

import SwiftUI
import Foundation

// MARK: - ViewModel
@MainActor
final class ShareViewModel: ObservableObject {
    @Published var link: String?
    @Published var isGenerating = false
    @Published var errorMessage: String?

    /// API moderne (async/await)
    func generateLink() async {
        guard !isGenerating else { return }
        isGenerating = true
        errorMessage = nil
        defer { isGenerating = false }

        do {
            // Simule un petit travail (réseau/crypto)
            try await Task.sleep(nanoseconds: 800_000_000)
            let token = UUID().uuidString.prefix(8).lowercased()
            self.link = "https://demo.aetherion.app/share/\(token)"
        } catch {
            self.errorMessage = (error as NSError).localizedDescription
        }
    }

    /// Compat héritée (appel sans async)
    func generateLink(completion: (() -> Void)? = nil) {
        Task {
            await generateLink()
            completion?()
        }
    }
}

// MARK: - View
struct ShareView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = ShareViewModel()

    @State private var copiedFlash = false

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ThemedHeader(title: "Partage sécurisé", style: .plain)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Erreur éventuelle
                        if let msg = vm.errorMessage {
                            ThemedCard {
                                Text(msg)
                                    .font(.footnote)
                                    .foregroundStyle(.red.opacity(0.9))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 12)
                        }

                        // CTA : générer un lien
                        Button {
                            Task { await vm.generateLink() }
                        } label: {
                            HStack {
                                if vm.isGenerating { ProgressView().padding(.trailing, 8) }
                                Text(vm.isGenerating ? "Génération…" : "Générer un lien (démo)")
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                        .disabled(vm.isGenerating)

                        // Lien généré
                        if let link = vm.link, !link.isEmpty {
                            ThemedCard {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Lien généré")
                                        .font(.headline)
                                        .foregroundStyle(themeManager.theme.foreground)

                                    Text(link)
                                        .font(.footnote.monospaced())
                                        .foregroundStyle(themeManager.theme.secondary)
                                        .textSelection(.enabled)

                                    HStack(spacing: 12) {
                                        Button {
                                            copy(link)
                                        } label: {
                                            Label(copiedFlash ? "Copié ✓" : "Copier",
                                                  systemImage: "doc.on.doc")
                                                .labelStyle(.titleAndIcon)
                                        }
                                        .buttonStyle(.bordered)

                                        #if os(iOS)
                                        if let url = URL(string: link) {
                                            ShareLink(item: url) {
                                                Label("Partager…", systemImage: "square.and.arrow.up")
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                        #endif
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 0)
                    }
                    .padding(.bottom, 120)
                }
            }
        }
    }

    // MARK: - Helpers

    private func copy(_ text: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #elseif os(macOS)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        withAnimation(.easeOut(duration: 0.15)) { copiedFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
            withAnimation(.easeIn(duration: 0.15)) { copiedFlash = false }
        }
    }
}

#Preview {
    NavigationStack {
        ShareView()
            .environmentObject(ThemeManager(default: .aetherionDark))
    }
}
