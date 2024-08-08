import DashTypes
import Foundation

extension Array where Element == PrivateCollection {
  public mutating func remove<T: PersonalDataCodable>(_ element: T, from collection: Element) {
    var collectionCopy = collection
    collectionCopy.remove(element)

    if let index = firstIndex(where: { $0.id == collectionCopy.id }) {
      self[index] = collectionCopy
    }
  }

  public func sortedByName() -> Self {
    return sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
  }

  public mutating func sortByName() {
    sort(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
  }

  public func filter(spaceId: String?) -> Self {
    filter { ($0.spaceId ?? "") == (spaceId ?? "") }
  }
}
