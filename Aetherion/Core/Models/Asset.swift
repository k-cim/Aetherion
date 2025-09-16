// === File: Core/Models/Asset.swift
// Version: 1.1
// Date: 2025-09-14
// Description: File descriptor model for Vault/Dashboard (with size, dates, helpers).
// Author: K-Cim

import Foundation

/// Représente un fichier dans Documents (nom, taille, date, etc.)
struct FileAsset: Identifiable, Hashable {
    let id: URL
    let url: URL
    let name: String
    let modifiedAt: Date?
    let size: Int64?

    init(url: URL) {
        self.url = url
        self.id = url
        self.name = url.lastPathComponent
        self.modifiedAt = url.modifiedAt
        self.size = url.fileSize
    }

    // MARK: - Helpers

    var basename: String { url.filenameWithoutExtension }
    var ext: String { url.pathExtension.lowercased() }

    var formattedSize: String? {
        size.map { ByteCountFormatter.string(fromByteCount: $0, countStyle: .file) }
    }

    var formattedDate: String? {
        modifiedAt.map { DateFormatter.localizedString(from: $0, dateStyle: .short, timeStyle: .short) }
    }
}
