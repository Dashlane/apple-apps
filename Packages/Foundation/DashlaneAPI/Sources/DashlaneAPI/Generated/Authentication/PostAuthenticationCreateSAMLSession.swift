import Foundation
extension AppAPIClient.Authentication {
        public struct CreateSAMLSession {
        public static let endpoint: Endpoint = "/authentication/CreateSAMLSession"

        public let api: AppAPIClient

                public func callAsFunction(assertion: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(assertion: assertion)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createSAMLSession: CreateSAMLSession {
        CreateSAMLSession(api: api)
    }
}

extension AppAPIClient.Authentication.CreateSAMLSession {
        struct Body: Encodable {

                public let assertion: String
    }
}

extension AppAPIClient.Authentication.CreateSAMLSession {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let token: String

                public let expirationDateUnix: Int

        public init(token: String, expirationDateUnix: Int) {
            self.token = token
            self.expirationDateUnix = expirationDateUnix
        }
    }
}
