// === File: Asset.swift
// Version: 1.0
// Date: 2025-08-29 20:55:00 UTC
// Description: Model representing a file stored in the app (Documents).
// Author: K-Cim

import Foundation

struct Asset: Identifiable, Hashable {
    let id = UUID()
    let name: String       // File name
    let url: URL           // File location
    let size: Int64        // File size in bytes
    let createdAt: Date?   // File creation date
}
