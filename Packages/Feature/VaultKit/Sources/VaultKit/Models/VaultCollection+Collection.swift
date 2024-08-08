import CorePersonalData
import Foundation

extension Collection where Element == any PersonalDataCodable {
  public func filter(by collection: VaultCollection) -> [Element] {
    return filter { collection.contains($0) }
  }
}

extension Collection where Element == VaultCollection {
  public func filter<T: PersonalDataCodable>(by element: T) -> [Element] {
    return filter { $0.contains(element) }
  }
}
