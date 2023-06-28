import Foundation
extension AppAPIClient.DarkwebmonitoringQa {
        public struct DeleteTestBreachEmail: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring-qa/DeleteTestBreachEmail"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(breachUuid: String, email: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(breachUuid: breachUuid, email: email)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deleteTestBreachEmail: DeleteTestBreachEmail {
        DeleteTestBreachEmail(api: api)
    }
}

extension AppAPIClient.DarkwebmonitoringQa.DeleteTestBreachEmail {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case breachUuid = "breachUuid"
            case email = "email"
        }

                public let breachUuid: String

                public let email: String
    }
}

extension AppAPIClient.DarkwebmonitoringQa.DeleteTestBreachEmail {
    public typealias Response = Empty?
}
