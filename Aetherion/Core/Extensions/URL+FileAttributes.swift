// === File: Core/Extensions/URL+FileAttributes.swift
// Helpers d’attributs fichiers (date de modif, taille)


import Foundation

extension URL {
    var modifiedAt: Date? {
        (try? resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
    }

    var fileSize: Int64? {
        if let v = try? resourceValues(forKeys: [.fileSizeKey]).fileSize {
            return Int64(v)
        }
        return nil
    }

    var filenameWithoutExtension: String {
        deletingPathExtension().lastPathComponent
    }
}
