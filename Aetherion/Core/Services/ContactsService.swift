// === File: ContactsService.swift
// Version: 1.1
// Date: 2025-08-30
// Description: Wrapper around Contacts framework (read & optional add).
// Author: K-Cim

import Foundation
import Contacts

@MainActor
final class ContactsService {
    static let shared = ContactsService()
    private let store = CNContactStore()

    private init() {}

    // MARK: - Permissions

    func requestAccess() async throws -> Bool {
        try await withCheckedThrowingContinuation { cont in
            store.requestAccess(for: .contacts) { granted, error in
                if let error { cont.resume(throwing: error) }
                else { cont.resume(returning: granted) }
            }
        }
    }

    // MARK: - Import

    func fetchAll() throws -> [Contact] {
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
            let name = [cn.givenName, cn.familyName].joined(separator: " ").trimmingCharacters(in: .whitespaces)
            let email = cn.emailAddresses.first?.value as String?
            let phone = cn.phoneNumbers.first?.value.stringValue

            let c = Contact(
                name: name.isEmpty ? "Unnamed" : name,
                group: .others,
                isTrusted: false,
                email: email,
                phone: phone,
                systemID: cn.identifier
            )
            results.append(c)
        }
        return results
    }

    // MARK: - Add to system Contacts (export explicite)

    func addToSystem(name: String, email: String?, phone: String?) throws -> String {
        let mutable = CNMutableContact()

        let parts = name.split(separator: " ")
        mutable.givenName  = parts.first.map(String.init) ?? name
        mutable.familyName = parts.dropFirst().joined(separator: " ")

        if let email, !email.isEmpty {
            mutable.emailAddresses = [CNLabeledValue(label: CNLabelHome, value: email as NSString)]
        }
        if let phone, !phone.isEmpty {
            mutable.phoneNumbers = [CNLabeledValue(label: CNLabelPhoneNumberMobile,
                                                   value: CNPhoneNumber(stringValue: phone))]
        }

        let save = CNSaveRequest()
        save.add(mutable, toContainerWithIdentifier: nil)
        try store.execute(save)
        return mutable.identifier
    }
}
