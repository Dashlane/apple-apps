import Foundation

public struct DataLeakMonitoringOptResponse: DataLeakMonitoringResponseProtocol {

	public let results: [Result]

		public struct Result: Codable {
		public let email: String
		public let result: DataLeakMonitoringServiceError
	}

    init(object: DataLeakMonitoringOptResponse, originalData: Data) {
        self.results = object.results
    }
}

public struct DataLeakMonitoringStatusResponse: DataLeakMonitoringResponseProtocol {

	public let emails: Set<DataLeakEmail>

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.emails = try container.decode(Set<DataLeakEmail>.self, forKey: .emails)
	}

    public init(emails: Set<DataLeakEmail>) {
        self.emails = emails
    }

    init(object: DataLeakMonitoringStatusResponse, originalData: Data) {
        self.emails = object.emails
    }
}

public struct DataLeakMonitoringLeaksResponse: DataLeakMonitoringResponseProtocol {

    public struct Details: Codable {
        let cipheredKey: String
        let cipheredInfo: String
    }

	public let leaks: [Breach]
    public let lastUpdateDate: TimeInterval
    public let details: Details?

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.leaks = try container.decode([Breach].self, forKey: .leaks)
        self.lastUpdateDate = try container.decode(TimeInterval.self, forKey: .lastUpdateDate)
        self.details = try container.decodeIfPresent(Details.self, forKey: .details)
	}

    init(object: DataLeakMonitoringLeaksResponse, originalData: Data) {
        guard let serverResponse = (try? JSONSerialization.jsonObject(with: originalData, options: .allowFragments)) as? [String: Any],
            let responseContent = serverResponse["content"] as? [String: Any],
            let responseLeaks = responseContent["leaks"] as? [[String: Any]] else {
                self.leaks = []
                self.lastUpdateDate = Date().timeIntervalSince1970
                self.details = nil
                return
        }

        let originalLeakByBreachID = responseLeaks.reduce(into: [String: Data]()) { (result, leak) in
            guard let breachID = leak["id"] as? String,
                let data = try? JSONSerialization.data(withJSONObject: leak) else {
                    return
            }
            result[breachID] = data
        }

        self.leaks = object.leaks.compactMap({
            var mutableBreach = $0
            guard let originalContentData = originalLeakByBreachID[$0.id] else { return nil }
            mutableBreach.originalContent = String(data: originalContentData, encoding: .utf8)
            return mutableBreach
        })
        self.lastUpdateDate = object.lastUpdateDate
        self.details = object.details
    }
}

public struct DataLeakEmail: Codable, Hashable {

		public let email: String
		public let state: State

						public enum State: String, Codable {
		case pending
		case active
		case disabled
	}

    public func hash(into hasher: inout Hasher) {
        hasher.combine(email)
    }

    public static func == (lhs: DataLeakEmail, rhs: DataLeakEmail) -> Bool {
        return lhs.email == rhs.email
    }

	public init(_ email: String) {
		self.email = email
		self.state = .pending
	}
}

public extension Set where Element == DataLeakEmail {
    var ordered: [DataLeakEmail] {
		return self.sorted(by: {
			guard $0.state.orderValue != $1.state.orderValue else {
				return $0.email < $1.email
			}
			return $0.state.orderValue < $1.state.orderValue
		})
	}
}

private extension DataLeakEmail.State {
	var orderValue: Int {
		switch self {
		case .pending: return 0
		case .active: return 1
		case .disabled: return 2
		}
	}
}
