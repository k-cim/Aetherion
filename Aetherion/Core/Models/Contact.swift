// === File: Contact.swift
// Version: 1.1
// Date: 2025-08-30
// Description: Core model for contacts with basic grouping and optional system link.
// Author: K-Cim

import Foundation

enum ContactGroup: String, CaseIterable, Identifiable {
    case family, friends, others
    var id: String { rawValue }

    var displayKey: String {
        switch self {
        case .family: return "contacts_group_family"
        case .friends: return "contacts_group_friends"
        case .others: return "contacts_group_others"
        }
    }
}

struct Contact: Identifiable {
    let id = UUID()
    let name: String
    let group: ContactGroup
    let isTrusted: Bool
    let email: String?
    let phone: String?

    /// Link to system Contacts (CNContact.identifier)
    let systemID: String?
}
