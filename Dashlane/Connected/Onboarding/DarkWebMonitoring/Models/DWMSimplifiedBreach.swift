import CorePersonalData
import Foundation
import SecurityDashboard

public typealias DWMBreachId = String
public struct DWMSimplifiedBreach: Hashable {
  let breachId: DWMBreachId
  let url: PersonalDataURL
  let leakedPassword: String?
  let date: Date?
  let email: String?
  let status: StoredBreach.Status
  let otherLeakedData: [String]?

  init(
    breachId: String, url: PersonalDataURL, leakedPassword: String?, date: Date?,
    email: String? = nil, otherLeakedData: [String]? = nil, status: StoredBreach.Status = .pending
  ) {
    self.breachId = breachId
    self.url = url
    self.leakedPassword = leakedPassword
    self.date = date
    self.email = email
    self.otherLeakedData = otherLeakedData
    self.status = status
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(breachId)
  }
}

extension DWMSimplifiedBreach: Comparable {
  public static func < (lhs: DWMSimplifiedBreach, rhs: DWMSimplifiedBreach) -> Bool {
    if let leftDate = lhs.date, let rightDate = rhs.date, leftDate != rightDate {
      return leftDate < rightDate
    }
    return lhs.breachId < rhs.breachId
  }
}
