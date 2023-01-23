import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct CreateTokenExtAuth {
        public static let endpoint: Endpoint = "/authentication/CreateTokenExtAuth"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createTokenExtAuth: CreateTokenExtAuth {
        CreateTokenExtAuth(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.CreateTokenExtAuth {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.CreateTokenExtAuth {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let accessKey: String

                public let secretKey: String

                public let creationDateUnix: Int

                public let expirationDateUnix: Int

                public let livemode: Bool

        public init(accessKey: String, secretKey: String, creationDateUnix: Int, expirationDateUnix: Int, livemode: Bool) {
            self.accessKey = accessKey
            self.secretKey = secretKey
            self.creationDateUnix = creationDateUnix
            self.expirationDateUnix = expirationDateUnix
            self.livemode = livemode
        }
    }
}
