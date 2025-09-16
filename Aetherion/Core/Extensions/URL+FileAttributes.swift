// === File: Core/Extensions/URL+FileAttributes.swift
// Version: 1.2
// Date: 2025-09-14
// Description: Helpers pour lire les attributs fichiers (date, taille, nom, type).
// Author: K-Cim

import Foundation

extension URL {
    /// Dernière date de modification (si disponible)
    var modifiedAt: Date? {
        let vals = try? resourceValues(forKeys: [.contentModificationDateKey])
        return vals?.contentModificationDate
    }

    /// Taille du fichier en octets (si disponible)
    var fileSize: Int64? {
        let vals = try? resourceValues(forKeys: [.fileSizeKey])
        if let size = vals?.fileSize {
            return Int64(size)
        }
        return nil
    }

    /// Nom de fichier sans extension
    var filenameWithoutExtension: String {
        deletingPathExtension().lastPathComponent
    }

    /// Indique si l’URL pointe vers un dossier
    var isDirectory: Bool {
        let vals = try? resourceValues(forKeys: [.isDirectoryKey])
        return vals?.isDirectory ?? false
    }

    /// Regroupe lecture taille + date en un seul appel (évite 2 accès FS)
    var attributes: (modifiedAt: Date?, fileSize: Int64?) {
        let vals = try? resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey])
        let date = vals?.contentModificationDate
        let size = vals?.fileSize.map { Int64($0) }
        return (date, size)
    }
}
