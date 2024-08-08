import Foundation

struct BreachesFilter {

  static func delta(
    forOnlineBreaches onlineBreaches: Set<StoredBreach>,
    existingBreaches: Set<StoredBreach>,
    storedCredentials: [SecurityDashboardCredential]?
  ) -> DeltaUpdateBreaches {
    let breachesToUse: Set<StoredBreach>
    if let credentials = storedCredentials {
      breachesToUse = Set(
        onlineBreaches.map {
          let leakedPasswords = $0.leakedPasswords(for: credentials)
          return $0.updated(with: leakedPasswords)
        })
    } else {
      breachesToUse = onlineBreaches
    }

    return existingBreaches.delta(with: breachesToUse)
  }

  static func `is`(_ breach: Breach, containedIn accounts: [SecurityDashboardCredential]?) -> Bool {
    guard let accounts = accounts else { return true }
    return accounts.contains(where: { (credential) -> Bool in
      guard let domain = credential.domain else { return false }
      return breach.domains().contains(domain)
    })
  }

  static func `is`(_ breach: Breach, newerThanPasswordIn accounts: [SecurityDashboardCredential]?)
    -> Bool
  {
    guard let breachEventDate = breach.eventDate else {
      return false
    }
    guard let accounts = accounts else { return true }
    return accounts.first(where: {
      return breachEventDate.posterior(to: $0.lastModificationDate)
    }) != nil
  }
}

extension Array where Element == PublicBreachesData {
  func filterRevisionAndValidPublicBreaches() -> (lastRevision: Int, breaches: Set<PublicBreach>) {
    var lastRevision = 0

    let flatten = self.map({ breachesData -> Set<PublicBreach> in
      if lastRevision < breachesData.revision { lastRevision = breachesData.revision }
      return breachesData.breaches
    })
    .flatMap { $0 }

    let filteredBreaches =
      flatten
      .filter { $0.makeLeakedData().contains(.password) }
      .filter {
        guard let status = $0.status else { return false }
        return status != .deleted
      }
    return (lastRevision, Set(filteredBreaches))
  }
}

extension String {

  fileprivate var json: [String: Any]? {
    guard let currentData = self.data(using: .utf8),
      let jsonObject = try? JSONSerialization.jsonObject(
        with: currentData, options: .allowFragments) as? [String: Any]
    else {
      return nil
    }
    return jsonObject
  }
}

extension Collection where Element == StoredBreach {
  func delta<C: Collection>(with collection: C) -> DeltaUpdateBreaches
  where C.Element == StoredBreach {
    var updatedBreaches: Set<StoredBreach> = []
    var collectionByIds = [String: StoredBreach]()
    for breach in collection {
      collectionByIds[breach.breachID] = breach
    }
    for existingBreach in self {
      guard let newBreach = collectionByIds[existingBreach.breachID] else {
        continue
      }
      guard existingBreach.breach != newBreach.breach else {
        continue
      }

      let mergedBreach =
        newBreach
        .mutated(with: existingBreach.objectID, status: existingBreach.status)
        .updated(with: existingBreach.leakedPasswords)
      updatedBreaches.insert(mergedBreach)
    }

    let existingIds = Set(self.map(\.breachID))
    let newBreaches: Set<StoredBreach> = Set(
      collection.filter { !existingIds.contains($0.breachID) })

    return DeltaUpdateBreaches(inserted: newBreaches, updated: updatedBreaches)
  }
}
