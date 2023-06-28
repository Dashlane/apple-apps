import Foundation
extension UserDeviceAPIClient.Darkwebmonitoring {
        public struct ListRegistrations: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring/ListRegistrations"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var listRegistrations: ListRegistrations {
        ListRegistrations(api: api)
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListRegistrations {
        public struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListRegistrations {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case emails = "emails"
        }

                public let emails: [DarkwebmonitoringListEmails]

        public init(emails: [DarkwebmonitoringListEmails]) {
            self.emails = emails
        }
    }
}
