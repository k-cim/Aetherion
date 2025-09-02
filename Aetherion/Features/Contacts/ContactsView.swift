// === File: ContactsView.swift
// Version: 1.2
// Date: 2025-08-30 07:35:00 UTC
// Description: Contacts screen with a segmented Picker (filter), vertical action buttons, and bottom bar.
// Author: K-Cim

import SwiftUI

struct ContactsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @StateObject private var vm = ContactsViewModel()

    @State private var showError = false

    var body: some View {
        ThemedScreen {
            VStack(spacing: 12) {
                // Titre
                Text(NSLocalizedString("contacts_title", comment: "Contacts"))
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .themedForeground(themeManager.theme)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                // === Picker — Filtre par groupe ===
                ThemedCard {
                    Picker(NSLocalizedString("contacts_filter", comment: "Filter"), selection: $vm.selectedGroup) {
                        Text(NSLocalizedString("contacts_group_all", comment: "All")).tag(ContactGroup?.none)
                        ForEach(ContactGroup.allCases) { g in
                            Text(NSLocalizedString(g.displayKey, comment: "")).tag(ContactGroup?.some(g))
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(.horizontal, 16)

                // === Actions — Boutons empilés verticalement ===
                ThemedCard {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Actions")
                            .font(.headline.weight(.bold))
                            .themedForeground(themeManager.theme)

                        VStack(spacing: 10) {
                            Button {
                                vm.importFromSystem()
                            } label: {
                                Text("Importer depuis Contacts")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                            .fill(ThemeStyle.primaryButtonBackground(themeManager.theme))
                                    )
                                    .foregroundStyle(themeManager.theme.background)
                            }
                            .buttonStyle(.plain)

                            Button {
                                vm.addAndSaveToSystem(name: "Nouveau Contact", group: .others, email: nil, phone: nil)
                            } label: {
                                Text("Ajouter dans Contacts")
                                    .font(.subheadline)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: themeManager.theme.cornerRadius)
                                            .fill(ThemeStyle.primaryButtonBackground(themeManager.theme))
                                    )
                                    .foregroundStyle(themeManager.theme.background)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .padding(.horizontal, 16)

                // === Liste des contacts ===
                List {
                    if vm.filtered.isEmpty {
                        ThemedCard {
                            Text(NSLocalizedString("contacts_empty", comment: ""))
                                .font(.headline.weight(.bold))
                                .themedForeground(themeManager.theme)
                        }
                        .listRowBackground(Color.clear)
                    } else {
                        ForEach(vm.filtered) { c in
                            HStack(spacing: 12) {
                                Image(systemName: c.isTrusted ? "person.crop.circle.badge.checkmark" : "person.crop.circle")
                                    .font(.title3)
                                    .themedSecondary(themeManager.theme)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(c.name)
                                        .font(.body.weight(.semibold))
                                        .themedForeground(themeManager.theme)
                                    HStack(spacing: 8) {
                                        Text(NSLocalizedString(c.group.displayKey, comment: ""))
                                            .font(.caption)
                                            .themedSecondary(themeManager.theme)
                                        if let mail = c.email {
                                            Text(mail).font(.caption).themedSecondary(themeManager.theme)
                                        }
                                        if let phone = c.phone {
                                            Text(phone).font(.caption).themedSecondary(themeManager.theme)
                                        }
                                    }
                                }

                                Spacer()

                                Button(role: .destructive) { vm.delete(c) } label: {
                                    Image(systemName: "trash")
                                }
                                .buttonStyle(.borderless)
                                .themedSecondary(themeManager.theme)
                            }
                        }
                    }
                }
                .themedListAppearance()

                // Barre du bas
                ThemedBottomBar(current: .contacts)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(vm.$errorMessage.dropFirst().compactMap { $0 }) { _ in
            showError = true
        }
        .alert("Erreur", isPresented: $showError, actions: {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        }, message: {
            Text(vm.errorMessage ?? "")
        })
        .onAppear {
            if vm.all.isEmpty { vm.loadDemo() }
        }
    }
}

#Preview {
    NavigationStack {
        ContactsView()
            .environmentObject(ThemeManager(default: ThemeID.aetherionDark))
    }
}
