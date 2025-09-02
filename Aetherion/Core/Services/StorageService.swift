// === File: StorageService.swift
// Version: 1.1
// Date: 2025-08-30 06:10:00 UTC
// Description: Basic file storage service returning Asset models with optional URL.
// Author: K-Cim

import Foundation

@MainActor
final class StorageService {
    static let shared = StorageService()

    private let fileManager = FileManager.default
    private let baseDir: URL

    private init() {
        // Store inside Application Support/Aetherion
        let support = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let dir = support.appendingPathComponent("Aetherion", isDirectory: true)

        // Ensure directory exists
        try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)

        baseDir = dir
    }

    // MARK: - Public API

    /// List all assets currently stored.
    func listAssets() -> [Asset] {
        guard let urls = try? fileManager.contentsOfDirectory(at: baseDir, includingPropertiesForKeys: [.fileSizeKey]) else {
            return []
        }

        return urls.compactMap { url in
            do {
                let values = try url.resourceValues(forKeys: [.fileSizeKey])
                let size = values.fileSize ?? 0
                return Asset(name: url.lastPathComponent, size: size, url: url)
            } catch {
                return nil
            }
        }
    }

    /// Save raw data as a new file, returns an Asset.
    func save(data: Data, name: String) throws -> Asset {
        let url = baseDir.appendingPathComponent(name)
        try data.write(to: url, options: .atomic)

        let size = (try? fileManager.attributesOfItem(atPath: url.path)[.size] as? Int) ?? data.count
        return Asset(name: name, size: size, url: url)
    }

    /// Delete an asset (by file URL).
    func delete(_ asset: Asset) {
        guard let url = asset.url else { return }
        try? fileManager.removeItem(at: url)
    }

    /// Load raw data for an asset.
    func load(_ asset: Asset) -> Data? {
        guard let url = asset.url else { return nil }
        return try? Data(contentsOf: url)
    }

    /// Clear all stored assets.
    func clearAll() {
        let assets = listAssets()
        for asset in assets {
            delete(asset)
        }
    }
}
