import Foundation
extension AppAPIClient.Darkwebmonitoring {
        public struct ConfirmRegistration {
        public static let endpoint: Endpoint = "/darkwebmonitoring/ConfirmRegistration"

        public let api: AppAPIClient

                public func callAsFunction(token: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(token: token)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var confirmRegistration: ConfirmRegistration {
        ConfirmRegistration(api: api)
    }
}

extension AppAPIClient.Darkwebmonitoring.ConfirmRegistration {
        struct Body: Encodable {

                public let token: String
    }
}

extension AppAPIClient.Darkwebmonitoring.ConfirmRegistration {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let email: String

        public let requestedBy: String

        public init(email: String, requestedBy: String) {
            self.email = email
            self.requestedBy = requestedBy
        }
    }
}
