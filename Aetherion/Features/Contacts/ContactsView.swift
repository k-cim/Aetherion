// === File: ContactsView.swift
// Date: 2025-09-04
// Description: Contacts — header title from theme (no card), consistent card heights.

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = ContactsViewModel()

    var body: some View {
        ThemedScreen {
            VStack(spacing: 0) {

                ThemedHeaderTitle(text: "Contacts")   // ← Titre cohérent, sans encadré

                ScrollView {
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
            // // // .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
    }
}
