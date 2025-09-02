// === File: Asset.swift
// Version: 1.1
// Date: 2025-08-30 06:00:00 UTC
// Description: Core model for stored documents/assets, with optional URL.
// Author: K-Cim

import Foundation

struct Asset: Identifiable {
    let id = UUID()
    let name: String
    let size: Int
    let url: URL?   // optional to represent storage location

    init(name: String, size: Int, url: URL? = nil) {
        self.name = name
        self.size = size
        self.url = url
    }
}
