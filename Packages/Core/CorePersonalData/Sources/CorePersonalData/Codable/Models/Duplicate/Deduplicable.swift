import Foundation
import DashTypes

public protocol Deduplicable {
        var deduplicationKeyPaths: [KeyPath<Self, String>] { get }

    static var contentType: PersonalDataContentType { get }
}

public extension Deduplicable {
    func isDuplicate(of other: Self) -> Bool {
        for keyPath in deduplicationKeyPaths {
            let value = self[keyPath: keyPath]
            let otherValue = other[keyPath: keyPath]
            if value != otherValue {
                                return false
            }
        }
        return true
    }
}

public extension PersonalDataCodable {
    func deduplicationIdentifiers() -> [String] {
        return []
    }
}

public extension PersonalDataCodable where Self: Deduplicable {
    func deduplicationIdentifiers() -> [String] {
        [Self.contentType.rawValue] + deduplicationKeyPaths.map({ self[keyPath: $0 ]})
    }
}

public extension Collection where Element: PersonalDataCodable & Deduplicable {
    func deduplicate() -> [Element] {
        let dictionary = self.reduce(into: [[String]: Element]()) { partialResult, item in
            let identifiers = item.deduplicationIdentifiers()
            guard !identifiers.isEmpty else {
                assertionFailure("Item sent for deduplication but Deduplicable not implemented. Will fallback to default ID.")
                partialResult[[UUID().uuidString]] = item
                return
            }
            guard partialResult[identifiers] == nil else {
                return
            }
            partialResult[identifiers] = item
        }
        return Array(dictionary.values)

    }
}

public extension ApplicationDatabase {
    func filterExisting<Item: PersonalDataCodable & Deduplicable>(items: [Item]) -> [Item] {
        do {
            let allVaultItemsDuplicableIdentifiers = try Set(fetchAll(Item.self).map({ $0.deduplicationIdentifiers() }))
            return items.filter({
                let ids = $0.deduplicationIdentifiers()
                guard !ids.isEmpty else {
                                        return true
                }
                return !allVaultItemsDuplicableIdentifiers.contains(where: { $0 == ids })
            })
        } catch {
            return items
        }
    }
}
