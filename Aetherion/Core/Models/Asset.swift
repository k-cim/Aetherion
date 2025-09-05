// === File: Asset.swift
// Date: 2025-08-30
// Description: File descriptor model for Vault (with size and optional dates).

import Foundation

struct Asset: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let url: URL
    let sizeBytes: Int64
    let modifiedAt: Date?

    /// Human-readable size (e.g., "1.2 Mo")
    var sizeString: String {
        ByteCountFormatter.string(fromByteCount: sizeBytes, countStyle: .file)
            .replacingOccurrences(of: "KB", with: "Ko")
            .replacingOccurrences(of: "MB", with: "Mo")
            .replacingOccurrences(of: "GB", with: "Go")
    }
}
