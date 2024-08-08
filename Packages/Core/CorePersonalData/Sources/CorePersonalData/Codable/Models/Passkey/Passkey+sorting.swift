import Foundation

extension Collection<Passkey> {
  public func sortedByLastUsage() -> [Element] {
    self.sorted { passkeyL, passkeyR in
      switch (passkeyL.metadata.lastLocalUseDate, passkeyR.metadata.lastLocalUseDate) {
      case (nil, nil):
        return passkeyL.creationDatetime ?? Date() > passkeyR.creationDatetime ?? Date()
      case (.some, nil):
        return true
      case (nil, .some):
        return false
      case let (.some(firstDate), .some(secondDate)):
        return firstDate.compare(secondDate) == .orderedAscending
      }
    }
  }
}
