// === File: ContactsViewModel.swift
// Version: 1.1
// Date: 2025-08-30
// Description: ViewModel for Contacts screen with import from system and explicit export.
// Author: K-Cim

import SwiftUI

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published var all: [Contact] = []
    @Published var selectedGroup: ContactGroup? = nil   // nil = All
    @Published var errorMessage: String?

    var filtered: [Contact] {
        guard let g = selectedGroup else { return all }
        return all.filter { $0.group == g }
    }

    // Demo local data (facultatif)
    func loadDemo() {
        all = [
            Contact(name: "Alice Dupont", group: .family, isTrusted: true,  email: "alice@example.com", phone: nil, systemID: nil),
            Contact(name: "Bob Martin",   group: .friends, isTrusted: false, email: nil, phone: "+33 6 01 02 03 04", systemID: nil),
            Contact(name: "Chloé Durand", group: .others, isTrusted: true,  email: "chloe@example.com", phone: nil, systemID: nil)
        ]
    }

    // MARK: - System Contacts (import + ajout)
    func importFromSystem() {
        Task {
            do {
                let granted = try await ContactsService.shared.requestAccess()
                guard granted else {
                    errorMessage = "Accès aux Contacts refusé."
                    return
                }
                let imported = try ContactsService.shared.fetchAll()
                // Fusion simple : on enlève les doublons via systemID
                all = (all + imported).uniqued(by: \.systemID)
            } catch {
                errorMessage = "Import Contacts: \(error.localizedDescription)"
            }
        }
    }

    func addAndSaveToSystem(name: String, group: ContactGroup, email: String?, phone: String?) {
        Task {
            do {
                let granted = try await ContactsService.shared.requestAccess()
                guard granted else {
                    errorMessage = "Accès aux Contacts refusé."
                    return
                }
                let sysID = try ContactsService.shared.addToSystem(name: name, email: email, phone: phone)
                let new = Contact(name: name, group: group, isTrusted: false, email: email, phone: phone, systemID: sysID)
                all.append(new)
            } catch {
                errorMessage = "Ajout dans Contacts: \(error.localizedDescription)"
            }
        }
    }

    // MARK: - Local ops
    func delete(_ contact: Contact) {
        all.removeAll { $0.id == contact.id }
    }
}

// Helper pour dédoublonner un tableau par une clé optionnelle
extension Array {
    func uniqued<T: Hashable>(by keyPath: KeyPath<Element, T?>) -> [Element] {
        var seen = Set<T>()
        return self.filter { element in
            if let key = element[keyPath: keyPath] {
                if seen.contains(key) { return false }
                seen.insert(key)
                return true
            }
            return true
        }
    }
}
