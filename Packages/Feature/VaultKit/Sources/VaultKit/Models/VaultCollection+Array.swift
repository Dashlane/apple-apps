import CorePersonalData
import CorePremium
import Foundation

extension Array where Element == VaultCollection {
  public mutating func sortByName() {
    sort(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
  }

  public func sortedByName() -> Self {
    sorted(by: { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending })
  }

  public func filter(bySpaceId: String?) -> Self {
    filter { ($0.spaceId ?? "") == (bySpaceId ?? "") }
  }

  func filter(by space: UserSpace) -> [VaultCollection] {
    switch space {
    case .personal, .team:
      return self.filter { $0.spaceId ?? "" == space.personalDataId }
    case .both:
      return self
    }
  }

  public mutating func remove<T: PersonalDataCodable>(_ element: T, from collection: Element) {
    var collectionCopy = collection
    collectionCopy.remove(element)

    if let index = firstIndex(where: { $0.id == collectionCopy.id }) {
      self[index] = collectionCopy
    }
  }
}
