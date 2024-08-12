import Foundation

struct DashboardBreach: SecurityDashboardBreach {

  var id: String
  var name: String
  var eventDate: EventDate
  var creationDate: Date
  let kind: BreachKind

  init?(breach: Breach) {

    let breachCreationDate = Date(timeIntervalSince1970: breach.creationDate ?? 0)

    guard let eventDate = breach.eventDate else {
      return nil
    }

    self.id = breach.id
    self.name = breach.name ?? breach.domains().first ?? ""
    self.eventDate = eventDate
    self.creationDate = breachCreationDate
    self.kind = breach.kind
  }
}
