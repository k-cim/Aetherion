// === File: Core/Services/ContactsService.swift
// Version: 3.0
// Date: 2025-09-15
// Rôle : Modèle Contact + Accès Contacts (permissions, lecture, ajout).
// Notes : requiert NSContactsUsageDescription dans Info.plist.

import Foundation
import Contacts

// MARK: - Modèle (fusionné ici)
enum ContactGroup: String, CaseIterable, Identifiable {
    case family, friends, others
    var id: String { rawValue }

    var displayKey: String {
        switch self {
        case .family:  return "contacts_group_family"
        case .friends: return "contacts_group_friends"
        case .others:  return "contacts_group_others"
        }
    }
}

struct Contact: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let group: ContactGroup
    let isTrusted: Bool
    let email: String?
    let phone: String?
    /// Lien vers le carnet système (CNContact.identifier)
    let systemID: String?
}

// MARK: - Service
@MainActor
final class ContactsService: ObservableObject {

    static let shared = ContactsService()
    private let store = CNContactStore()

    private init() {}

    enum ContactsError: LocalizedError {
        case accessDenied, accessRestricted, unknownStatus, cannotCreate
        var errorDescription: String? {
            switch self {
            case .accessDenied:    return "Accès aux contacts refusé. Activez-le dans Réglages."
            case .accessRestricted:return "Accès aux contacts restreint sur cet appareil."
            case .unknownStatus:   return "Statut d’autorisation inconnu."
            case .cannotCreate:    return "Impossible de créer le contact."
            }
        }
    }

    // MARK: Permissions

    private func requestAccess() async throws -> Bool {
        try await withCheckedThrowingContinuation { cont in
            store.requestAccess(for: .contacts) { granted, error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: granted) }
            }
        }
    }

    func ensureContactsAccess() async throws {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: return
        case .notDetermined:
            let ok = try await requestAccess()
            if !ok { throw ContactsError.accessDenied }
        case .denied:      throw ContactsError.accessDenied
        case .restricted:  throw ContactsError.accessRestricted
        @unknown default:  throw ContactsError.unknownStatus
        }
    }

    // MARK: Lecture

    func fetchAll() async throws -> [Contact] {
        try await ensureContactsAccess()

        let keys: [CNKeyDescriptor] = [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        let request = CNContactFetchRequest(keysToFetch: keys)
        var results: [Contact] = []

        try store.enumerateContacts(with: request) { cn, _ in
            let fullName = [cn.givenName, cn.familyName]
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
                .joined(separator: " ")
            let name  = fullName.isEmpty ? "Unnamed" : fullName
            let email = cn.emailAddresses.first?.value as String?
            let phone = cn.phoneNumbers.first?.value.stringValue

            results.append(
                Contact(name: name,
                        group: .others,
                        isTrusted: false,
                        email: email,
                        phone: phone,
                        systemID: cn.identifier)
            )
        }

        results.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        return results
    }

    // MARK: Ajout

    func addToSystem(name: String, email: String?, phone: String?) async throws -> String {
        try await ensureContactsAccess()

        let c = CNMutableContact()
        let parts = name.split(separator: " ")
        c.givenName  = parts.first.map(String.init) ?? name
        c.familyName = parts.dropFirst().joined(separator: " ")

        if let email, !email.isEmpty {
            c.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: email as NSString)]
        }
        if let phone, !phone.isEmpty {
            c.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile,
                                             value: CNPhoneNumber(stringValue: phone))]
        }

        let save = CNSaveRequest()
        save.add(c, toContainerWithIdentifier: nil)
        do {
            try store.execute(save)
            return c.identifier
        } catch {
            throw ContactsError.cannotCreate
        }
    }
}
