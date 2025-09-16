// === File: Features/Contacts/ContactsViewModel.swift
// Version: 2.0
// Date: 2025-09-15
// Rôle : ViewModel Contacts — charge via ContactsService.

import Foundation

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published var contacts: [Contact] = []
    @Published var errorMessage: String?

    init() {}

    func load() {
        Task {
            do {
                let list = try await ContactsService.shared.fetchAll()
                self.contacts = list
            } catch {
                self.errorMessage = (error as NSError).localizedDescription
            }
        }
    }
}
