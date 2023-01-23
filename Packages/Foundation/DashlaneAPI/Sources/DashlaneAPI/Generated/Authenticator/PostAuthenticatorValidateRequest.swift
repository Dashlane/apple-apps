import Foundation
extension AppAPIClient.Authenticator {
        public struct ValidateRequest {
        public static let endpoint: Endpoint = "/authenticator/ValidateRequest"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(requestId: String, deviceAccessKey: String, approval: Approval, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(requestId: requestId, deviceAccessKey: deviceAccessKey, approval: approval)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var validateRequest: ValidateRequest {
        ValidateRequest(api: api)
    }
}

extension AppAPIClient.Authenticator.ValidateRequest {
        struct Body: Encodable {

                public let requestId: String

                public let deviceAccessKey: String

        public let approval: Approval
    }

        public struct Approval: Codable, Equatable {

                public enum Status: String, Codable, Equatable, CaseIterable {
            case approved = "approved"
            case rejected = "rejected"
        }

                public let status: Status

                public let isSuspicious: Bool?

        public init(status: Status, isSuspicious: Bool? = nil) {
            self.status = status
            self.isSuspicious = isSuspicious
        }
    }
}

extension AppAPIClient.Authenticator.ValidateRequest {
    public typealias Response = Empty?
}
