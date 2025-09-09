// === File: ContactsViewModel.swift
// Date: 2025-08-30
// Description: Observable view model for Contacts screen.

import Foundation

struct ContactItem: Identifiable, Equatable {
    let id = UUID()
    var name: String
}

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published var contacts: [ContactItem] = []

    func load() {
        // Laisse vide pour afficher "Aucun contact".
        // Pour tester avec des données :
        // self.contacts = [ContactItem(name: "Alice"), ContactItem(name: "Bob")]
    }
}
