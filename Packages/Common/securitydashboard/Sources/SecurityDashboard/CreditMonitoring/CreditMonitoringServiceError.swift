import Foundation

public enum CreditMonitoringServiceError: Error, Codable, Equatable {

	case userNotAllowed
	case unknownError(Error?)

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		self = CreditMonitoringServiceError(rawValue: try container.decode(String.self))
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		try container.encode(self.stringValue)
	}

	public init(rawValue: String) {
		switch rawValue {
		case "USER_IS_NOT_ALLOWED": self = .userNotAllowed
		default:
			self = .unknownError(nil)
		}
	}

	public var stringValue: String {
		switch self {
		case .userNotAllowed: return "USER_IS_NOT_ALLOWED"
		default: return "UNKNOWN"
		}
	}

	public static func == (lhs: CreditMonitoringServiceError, rhs: CreditMonitoringServiceError) -> Bool {
		return lhs.stringValue == rhs.stringValue
	}
}
