import Foundation
extension AppAPIClient.DarkwebmonitoringQa {
        public struct DeleteAllTestBreachEmails: APIRequest {
        public static let endpoint: Endpoint = "/darkwebmonitoring-qa/DeleteAllTestBreachEmails"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(breachUuid: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(breachUuid: breachUuid)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deleteAllTestBreachEmails: DeleteAllTestBreachEmails {
        DeleteAllTestBreachEmails(api: api)
    }
}

extension AppAPIClient.DarkwebmonitoringQa.DeleteAllTestBreachEmails {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case breachUuid = "breachUuid"
        }

                public let breachUuid: String
    }
}

extension AppAPIClient.DarkwebmonitoringQa.DeleteAllTestBreachEmails {
    public typealias Response = Empty?
}
