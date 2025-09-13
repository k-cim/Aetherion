// === File: Asset.swift
// Date: 2025-08-30
// Description: File descriptor model for Vault (with size and optional dates).

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
}
