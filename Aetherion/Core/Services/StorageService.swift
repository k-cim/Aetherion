// === File: StorageService.swift
// Date: 2025-08-30
// Description: Utilities to list files from app Documents directory for Vault.

import Foundation

enum StorageService {
    /// Returns the app Documents directory URL.
    static func documentsURL() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    /// Lists files in Documents (non-recursive) as `Asset`.
    static func listAssets() -> [Asset] {
        let dir = documentsURL()
        let fm = FileManager.default

        guard let items = try? fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.fileSizeKey, .contentModificationDateKey], options: [.skipsHiddenFiles]) else {
            return []
        }

        var result: [Asset] = []
        for url in items {
            // Skip directories
            var isDir: ObjCBool = false
            if fm.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                continue
            }

            // Attributes
            let attrs = (try? fm.attributesOfItem(atPath: url.path)) ?? [:]
            let size = (attrs[.size] as? NSNumber)?.int64Value ?? 0
            let modified = attrs[.modificationDate] as? Date

            let asset = Asset(name: url.lastPathComponent,
                              url: url,
                              sizeBytes: size,
                              modifiedAt: modified)
            result.append(asset)
        }

        // Sort by name ascending
        return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
}
