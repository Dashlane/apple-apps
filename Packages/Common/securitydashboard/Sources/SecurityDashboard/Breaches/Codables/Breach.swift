import DashlaneAPI
import Foundation

public typealias PublicBreach = UserDeviceAPIClient.Breaches.GetBreach.Response
  .LatestBreachesElement
public typealias DataLeakBreach = UserDeviceAPIClient.Darkwebmonitoring.ListLeaks.Response
  .LeaksElement

public enum Breach: Hashable, Codable {
  case `public`(PublicBreach)
  case dataLeak(DataLeakBreach)

  public var kind: BreachKind {
    switch self {
    case .public:
      return .default
    case .dataLeak:
      return .dataLeak
    }
  }

  public var eventDate: EventDate? {
    let date =
      switch self {
      case .public(let publicBreach):
        publicBreach.eventDate
      case .dataLeak(let dataLeakBreach):
        dataLeakBreach.eventDate
      }
    guard let date else { return nil }
    return EventDate(withValue: date)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .public(let publicBreach):
      try container.encode(publicBreach)
    case .dataLeak(let dataLeak):
      try container.encode(dataLeak)
    }
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let breach = try? container.decode(DataLeakBreach.self) {
      self = .dataLeak(breach)
    } else {
      let breach = try container.decode(PublicBreach.self)
      self = .public(breach)
    }
  }
}

public struct BreachAndContent: Hashable {
  public let breach: PublicBreach
  public let json: String
}

extension Breach {
  public var id: String {
    switch self {
    case .public(let publicBreach):
      publicBreach.id ?? ""
    case .dataLeak(let dataLeakBreach):
      dataLeakBreach.id
    }
  }
}

extension Breach {
  var name: String? {
    switch self {
    case .public(let publicBreach):
      publicBreach.name
    case .dataLeak:
      nil
    }
  }
}

extension Breach {
  var status: BreachesStatus? {
    switch self {
    case .public(let publicBreach):
      publicBreach.status
    case .dataLeak(let dataLeak):
      BreachesStatus(rawValue: dataLeak.status)
    }
  }
}

extension Breach {
  public var lastModificationRevision: Int? {
    switch self {
    case .public(let publicBreach):
      publicBreach.lastModificationRevision
    case .dataLeak(let dataLeak):
      dataLeak.lastModificationRevision
    }
  }
}

extension Breach {
  public var creationDate: TimeInterval? {
    switch self {
    case .public(let publicBreach):
      return publicBreach.breachCreationDate.map { TimeInterval($0) }
    case .dataLeak(let dataLeakBreach):
      return TimeInterval(dataLeakBreach.breachCreationDate)
    }
  }
}

extension Breach {
  public var impactedEmails: [String] {
    switch self {
    case .public:
      []
    case .dataLeak(let dataLeakBreach):
      dataLeakBreach.impactedEmails
    }
  }
}

extension Breach {
  public func domains() -> [String] {
    switch self {
    case .public(let publicBreach):
      publicBreach.domains ?? []
    case .dataLeak(let dataLeakBreach):
      dataLeakBreach.domains
    }
  }
}

extension Breach {
  public func leakedData() -> [LeakedData] {
    switch self {
    case .public(let publicBreach):
      publicBreach.makeLeakedData()
    case .dataLeak(let dataLeakBreach):
      dataLeakBreach.makeLeakedData()
    }
  }
}

extension PublicBreach {
  func makeLeakedData() -> [LeakedData] {
    (leakedData ?? [])
      .compactMap(LeakedData.init(rawValue:))
  }
}

extension DataLeakBreach {
  func makeLeakedData() -> [LeakedData] {
    leakedData
      .compactMap(LeakedData.init(rawValue:))
  }
}

public enum LeakedData: DefaultValueDecodable, CaseIterable {

  public typealias RawValue = String

  case username
  case email
  case password
  case social
  case ssn
  case address
  case creditCard
  case phoneNumber
  case ip
  case geolocation
  case personalInfo
  case unknown

  public static var defaultDecodedValue: LeakedData {
    return .unknown
  }

  public init?(rawValue: String) {
    switch rawValue {
    case "login": self = .username
    case "username": self = .username
    case "email": self = .email
    case "password": self = .password
    case "social": self = .social
    case "ssn": self = .ssn
    case "address": self = .address
    case "creditcard": self = .creditCard
    case "phone": self = .phoneNumber
    case "ip": self = .ip
    case "geolocation": self = .geolocation
    case "personalinfo": self = .personalInfo
    default:
      return nil
    }
  }

  public var rawValue: String {
    switch self {

    case .username: return "username"
    case .email: return "email"
    case .password: return "password"
    case .social: return "social"
    case .ssn: return "ssn"
    case .creditCard: return "creditcard"
    case .phoneNumber: return "phone"
    case .ip: return "ip"
    case .geolocation: return "geolocation"
    case .personalInfo: return "personalinfo"
    case .address: return "address"
    case .unknown: return "unknown"
    }
  }

}

public enum BreachKind {
  case `default`
  case dataLeak
}

extension PublicBreach: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension DataLeakBreach: Hashable {

  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Breach {
  public static var mock: Breach {
    .public(
      .init(
        announcedDate: nil,
        breachCreationDate: nil,
        breachModelVersion: nil,
        criticality: nil,
        description: nil,
        domains: nil,
        eventDate: nil,
        id: "mock",
        lastModificationRevision: nil,
        leakedData: nil,
        name: nil,
        relatedLinks: nil,
        restrictedArea: nil,
        sensitiveDomain: nil,
        status: nil,
        template: nil)
    )
  }
}
