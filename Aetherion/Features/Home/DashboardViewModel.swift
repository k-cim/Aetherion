// === File: Features/Home/DashboardViewModel.swift
// Version: 1.4.1
// Date: 2025-09-14
// Description: Durable Dashboard ViewModel — async reload (non-blocking), cancellation, DI (FileManager/baseURL/Clock), logging, bounded results.
// Author: K-Cim

import Foundation
import os

@MainActor
final class DashboardViewModel: ObservableObject {

    // MARK: - Published
    @Published private(set) var recent: [FileAsset] = []

    // MARK: - DI & Config
    private let fm: FileManager
    private let baseURL: URL
    private let clock: any Clock<Duration>
    private let log = Logger(subsystem: "net.aetherion.app", category: "DashboardVM")

    /// Limite supérieure des éléments retournés par `reload()`
    private let maxResults: Int

    /// Tâche courante (permet annulation et "latest wins")
    private var currentTask: Task<Void, Never>?

    init(
        fileManager: FileManager = .default,
        baseURL: URL = FileStorageService.documentsURL, // ✅ remplacé
        clock: any Clock<Duration> = ContinuousClock(),
        maxResults: Int = 100
    ) {
        self.fm = fileManager
        self.baseURL = baseURL
        self.clock = clock
        self.maxResults = max(1, maxResults)
    }

    // MARK: - API

    /// Recharge les fichiers depuis `baseURL` de façon non bloquante (thread-safe UI).
    func reload() {
        currentTask?.cancel()

        currentTask = Task { [weak self] in
            guard let self else { return }

            let files: [FileAsset] = await withTaskCancellationHandler(operation: {
                await Self.scanDirectory(
                    fm: self.fm,
                    dir: self.baseURL,
                    log: self.log,
                    limit: self.maxResults
                )
            }, onCancel: {
                self.log.debug("reload() cancelled before finishing scan")
            })

            self.recent = files
            self.log.info("reload() updated recent: \(files.count) items")
        }
    }

    /// Ajoute un fichier d’exemple et recharge la liste (non bloquant).
    func addSample() {
        currentTask?.cancel()

        currentTask = Task { [weak self] in
            guard let self else { return }

            do {
                try await Self.ensureDirectory(self.fm, at: self.baseURL, log: self.log)

                let ts = UInt64(Date().timeIntervalSince1970)
                let url = self.baseURL.appendingPathComponent("Dashboard-\(ts).txt")
                let data = Data("Hello from Dashboard\n".utf8)

                try data.write(to: url, options: [.atomic])
                self.log.info("addSample() wrote: \(url.lastPathComponent, privacy: .public)")

                try? await self.clock.sleep(for: .milliseconds(20))

                await self.reload()
            } catch {
                self.log.error("addSample() error: \(error.localizedDescription, privacy: .public)")
            }
        }
    }

    /// Annule toute opération en cours.
    func cancel() {
        currentTask?.cancel()
        currentTask = nil
        log.debug("cancel() invoked")
    }

    // MARK: - Static helpers (off-Main work)

    private static func scanDirectory(
        fm: FileManager,
        dir: URL,
        log: Logger,
        limit: Int
    ) async -> [FileAsset] {
        await Task.yield()

        do {
            try await ensureDirectory(fm, at: dir, log: log)

            let urls = try fm.contentsOfDirectory(
                at: dir,
                includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey],
                options: [.skipsHiddenFiles]
            )

            let assets = urls
                .filter { $0.isFileURL }
                .map(FileAsset.init(url:))
                .sorted { ($0.modifiedAt ?? .distantPast) > ($1.modifiedAt ?? .distantPast) }

            let capped = Array(assets.prefix(limit))
            log.debug("scanDirectory() -> \(capped.count) / \(assets.count) items (limit \(limit))")
            return capped
        } catch {
            log.error("scanDirectory() error: \(error.localizedDescription, privacy: .public)")
            return []
        }
    }

    private static func ensureDirectory(_ fm: FileManager, at url: URL, log: Logger) async throws {
        var isDir: ObjCBool = false
        if fm.fileExists(atPath: url.path, isDirectory: &isDir) {
            if isDir.boolValue { return }
            throw CocoaError(.fileWriteFileExists)
        }
        try fm.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
        log.debug("ensureDirectory(): created \(url.path, privacy: .public)")
    }
}
