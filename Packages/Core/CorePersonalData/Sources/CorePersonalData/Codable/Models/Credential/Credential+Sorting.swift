import Foundation

extension Credential {
  fileprivate var sortableId: String {
    if !login.isEmpty {
      return login
    } else if !secondaryLogin.isEmpty {
      return secondaryLogin
    } else {
      return email
    }
  }
}

extension Collection where Element == Credential {
  public func sortedByLastUsage() -> [Element] {
    self.sorted { credentialL, credentialR in
      switch (credentialL.metadata.lastLocalUseDate, credentialR.metadata.lastLocalUseDate) {
      case (nil, nil):
        return credentialL.sortableId.lowercased() < credentialR.sortableId.lowercased()
      case (.some, nil):
        return true
      case (nil, .some):
        return false
      case let (.some(firstDate), .some(secondDate)):
        return firstDate.compare(secondDate) == .orderedDescending
      }
    }
  }
}
