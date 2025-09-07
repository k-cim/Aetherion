// UI/Theme/JSON+Utils.swift
import Foundation

extension Data {
    /// Parse JSON en dictionnaire racine (lecture non-stricte pour juste extraire displayName/id)
    func jsonRootObject() -> [String: Any]? {
        (try? JSONSerialization.jsonObject(with: self, options: [])) as? [String: Any]
    }
}

extension Dictionary where Key == String, Value == Any {
    func string(_ key: String) -> String? { self[key] as? String }
    func dict(_ key: String) -> [String: Any]? { self[key] as? [String: Any] }
    func array(_ key: String) -> [[String: Any]]? { self[key] as? [[String: Any]] }
}
