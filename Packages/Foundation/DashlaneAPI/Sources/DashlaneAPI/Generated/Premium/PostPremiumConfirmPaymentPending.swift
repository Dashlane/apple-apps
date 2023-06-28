import Foundation
extension AppAPIClient.Premium {
        public struct ConfirmPaymentPending: APIRequest {
        public static let endpoint: Endpoint = "/premium/ConfirmPaymentPending"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(login: String, externalId: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, externalId: externalId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var confirmPaymentPending: ConfirmPaymentPending {
        ConfirmPaymentPending(api: api)
    }
}

extension AppAPIClient.Premium.ConfirmPaymentPending {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case externalId = "externalId"
        }

                public let login: String

                public let externalId: String
    }
}

extension AppAPIClient.Premium.ConfirmPaymentPending {
    public typealias Response = Empty?
}
