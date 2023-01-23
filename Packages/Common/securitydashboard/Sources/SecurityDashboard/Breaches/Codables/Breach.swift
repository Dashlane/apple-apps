import Foundation

public struct Breach: Codable {

		public let id: String

		public let breachModelVersion: Int?

		public let name: String?

		public let domains: [String]?

		public let eventDate: EventDate?

		public let announcedDate: EventDate?

		public let leakedData: [LeakedData]?

		public let criticality: Int?

		public let restrictedArea: [String]?

		public let status: Status?

		public let sensitiveDomain: Bool?

		public let relatedLinks: [String]?

		public let description: FailableDecodable<Description>?

		public let lastModificationRevision: Int?

		public let breachCreationDate: Date?

		public let impactedEmails: [String]?

		public var originalContent: String?

	public var kind: BreachKind {
		guard self.impactedEmails == nil || (self.impactedEmails ?? []).isEmpty else {
			return .dataLeak
		}
		return .default
	}
}

extension Breach {

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

		public enum Status: DefaultValueDecodable {

		public typealias RawValue = String

		case live 
		case legacy 
		case deleted 
		case staging 
		case unknown

		public static var defaultDecodedValue: Status {
			return .unknown
		}

		public init?(rawValue: String) {
			switch rawValue {
			case "live": self = .live
			case "legacy": self = .legacy
			case "deleted": self = .deleted
			case "staging": self = .staging
			default:
				return nil
			}
		}

		public var rawValue: String {
			switch self {
			case .live: return "live"
			case .legacy: return "legacy"
			case .deleted: return "deleted"
			case .staging: return "staging"
			case .unknown: return "unknown"
			}
		}
	}

		public struct Description: Codable {
		let en: String?
	}
}

public enum BreachKind {
    case `default`
    case dataLeak
}

extension Breach: Hashable {

	public static func == (lhs: Breach, rhs: Breach) -> Bool {
		return lhs.id == rhs.id
	}

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
public extension Breach {
    static var mock: Breach {
        Breach(id: "mock",
               breachModelVersion: nil,
               name: nil,
               domains: nil,
               eventDate: nil,
               announcedDate: nil,
               leakedData: nil,
               criticality: nil,
               restrictedArea: nil,
               status: nil,
               sensitiveDomain: nil,
               relatedLinks: nil,
               description: nil,
               lastModificationRevision: nil,
               breachCreationDate: nil,
               impactedEmails: nil,
               originalContent: nil)
    }
}
