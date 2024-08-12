import CorePersonalData

extension Array where Element == VaultCollection {
  public func filterAndSortItemsUsingCriteria(_ criteria: String) -> [Element] {
    return compactMap { collection -> (collection: VaultCollection, ranking: SearchMatch)? in
      guard let ranking: SearchMatch = collection.match(criteria) else { return nil }
      return (collection, ranking)
    }
    .sorted { $0.ranking < $1.ranking }
    .map(\.collection)
  }
}
