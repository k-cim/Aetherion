// === File: StorageService.swift
// Version: 1.0
// Date: 2025-08-29 20:55:00 UTC
// Description: Service to manage file storage in app's Documents directory.
// Author: K-Cim

import Foundation

final class StorageService {
    private let fm = FileManager.default

    /// Returns URL to Documents directory
    var documentsURL: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    /// List all files in Documents and return as [Asset]
    func listDocuments() throws -> [Asset] {
        let urls = try fm.contentsOfDirectory(
            at: documentsURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        return urls.compactMap { url in
            guard !url.hasDirectoryPath else { return nil }
            let attrs = (try? fm.attributesOfItem(atPath: url.path)) ?? [:]
            return Asset(
                name: url.lastPathComponent,
                url: url,
                size: (attrs[.size] as? NSNumber)?.int64Value ?? 0,
                createdAt: attrs[.creationDate] as? Date
            )
        }
        .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }

    /// Create a sample file in Documents for testing
    func createSampleFile(named name: String = "sample.txt") throws -> URL {
        let fileURL = documentsURL.appendingPathComponent(name)
        try "Hello Aetherion\n".write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    /// Delete a given file (asset)
    func delete(_ asset: Asset) throws {
        try fm.removeItem(at: asset.url)
    }
}
