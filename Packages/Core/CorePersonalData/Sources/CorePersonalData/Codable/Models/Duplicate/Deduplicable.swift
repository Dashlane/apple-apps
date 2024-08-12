import DashTypes
import Foundation

public protocol Deduplicable {
  var deduplicationKeyPaths: [KeyPath<Self, String>] { get }

  static var contentType: PersonalDataContentType { get }
}

extension Deduplicable {
  public func isDuplicate(of other: Self) -> Bool {
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

extension PersonalDataCodable {
  public func deduplicationIdentifiers() -> [String] {
    return []
  }
}

extension PersonalDataCodable where Self: Deduplicable {
  public func deduplicationIdentifiers() -> [String] {
    [Self.contentType.rawValue] + deduplicationKeyPaths.map({ self[keyPath: $0] })
  }
}

extension Collection where Element: PersonalDataCodable & Deduplicable {
  public func deduplicate() -> [Element] {
    let dictionary = self.reduce(into: [[String]: Element]()) { partialResult, item in
      let identifiers = item.deduplicationIdentifiers()
      guard !identifiers.isEmpty else { return }
      guard partialResult[identifiers] == nil else {
        return
      }
      partialResult[identifiers] = item
    }
    return Array(dictionary.values)
  }

  public func duplicates() -> [Element] {
    var potentialDuplicates: [[String]: Element] = [:]
    let dictionary = self.reduce(into: [String: Element]()) { partialResult, item in
      let identifiers = item.deduplicationIdentifiers()
      guard !identifiers.isEmpty else { return }
      guard potentialDuplicates[identifiers] != nil else {
        potentialDuplicates[identifiers] = item
        return
      }
      partialResult[item.id.rawValue] = item
    }
    return Array(dictionary.values)
  }
}

extension ApplicationDatabase {
  public func filterExisting<Item: PersonalDataCodable & Deduplicable>(items: [Item]) -> [Item] {
    do {
      let allVaultItemsDuplicableIdentifiers = try Set(
        fetchAll(Item.self).map({ $0.deduplicationIdentifiers() }))
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
