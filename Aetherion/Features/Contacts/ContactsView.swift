// === File: Features/Contacts/ContactsView.swift
// Version: 2.0
// Date: 2025-09-15
// Rôle : Liste des contacts (affichage basique), cohérente avec le thème.

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = ContactsViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {
                ThemedHeaderTitle(text: "Contacts")

                ScrollView {
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

                    if vm.contacts.isEmpty {
                        ThemedCard(fixedHeight: 80) {
                            HStack {
                                Spacer()
                                Text("Aucun contact")
                                    .font(.title2.bold())
                                    .foregroundStyle(themeManager.theme.foreground)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(vm.contacts) { contact in
                                ThemedCard(fixedHeight: 64) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "person.crop.circle")
                                            .font(.title3)
                                            .foregroundStyle(themeManager.theme.secondary)
                                        Text(contact.name)
                                            .font(.headline.bold())
                                            .foregroundStyle(themeManager.theme.foreground)
                                        Spacer()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                    }
                }
            }
        }
        .onAppear { vm.load() }
    }
}

#Preview {
    NavigationStack {
        ContactsView()
            .environmentObject(ThemeManager(default: .aetherionDark))
    }
}
