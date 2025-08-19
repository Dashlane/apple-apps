import CorePersonalData
import CoreTypes
import Foundation
import SecurityDashboard

struct BreachStoreIdentifier: SecurityDashboard.StoreIdentifier {
  let id: Identifier
}

extension SecurityBreach {
  func storedBreach(using decoder: JSONDecoder) -> StoredBreach? {
    guard let data = self.content.data(using: .utf8) else {
      return nil
    }
    let status = self.status?.storedBreachStatus ?? .unknown
    guard let breach = try? decoder.decode(Breach.self, from: data) else { return nil }

    return StoredBreach(
      objectID: BreachStoreIdentifier(id: self.id),
      breach: breach,
      leakedPasswords: leakedPasswordsFrom(rawJSON: self.leakedPasswords, using: decoder),
      status: status)
  }
}

private func leakedPasswordsFrom(rawJSON: String?, using decoder: JSONDecoder) -> Set<String> {
  guard let leakedPasswordsData = rawJSON?.data(using: .utf8) else { return [] }
  guard let leakedPasswords = try? decoder.decode(Set<String>.self, from: leakedPasswordsData)
  else { return [] }
  return leakedPasswords
}

extension SecurityBreach {
  init?(storedBreach: StoredBreach, encoder: JSONEncoder) {
    self.init()

    self.breachId = storedBreach.breachID

    guard let breachJSONData = try? encoder.encode(storedBreach.breach),
      let breachRawJSON = String(data: breachJSONData, encoding: .utf8)
    else { return }
    self.content = breachRawJSON

    if let lastModificationRevision = storedBreach.breach.lastModificationRevision {
      self.contentRevision = String(lastModificationRevision)
    }

    if let jsonBreachedPasswords = try? encoder.encode(storedBreach.leakedPasswords) {
      self.leakedPasswords = String(data: jsonBreachedPasswords, encoding: .utf8) ?? ""
    }

    self.status = storedBreach.status.securityBreachStatus
  }

  mutating func update(with storedBreach: StoredBreach, encoder: JSONEncoder) {
    self.breachId = storedBreach.breachID

    guard let breachJSONData = try? encoder.encode(storedBreach.breach),
      let breachRawJSON = String(data: breachJSONData, encoding: .utf8)
    else { return }
    self.content = breachRawJSON

    if let lastModificationRevision = storedBreach.breach.lastModificationRevision {
      self.contentRevision = String(lastModificationRevision)
    }

    if let jsonBreachedPasswords = try? encoder.encode(storedBreach.leakedPasswords) {
      self.leakedPasswords = String(data: jsonBreachedPasswords, encoding: .utf8) ?? ""
    }

    self.status = storedBreach.status.securityBreachStatus
  }
}
