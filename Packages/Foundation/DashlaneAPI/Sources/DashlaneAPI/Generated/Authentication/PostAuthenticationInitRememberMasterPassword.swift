import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct InitRememberMasterPassword {
        public static let endpoint: Endpoint = "/authentication/InitRememberMasterPassword"

        public let api: UserDeviceAPIClient

                public func callAsFunction(rememberMasterPasswordCipheringKey: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(rememberMasterPasswordCipheringKey: rememberMasterPasswordCipheringKey)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var initRememberMasterPassword: InitRememberMasterPassword {
        InitRememberMasterPassword(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.InitRememberMasterPassword {
        struct Body: Encodable {

                public let rememberMasterPasswordCipheringKey: String
    }
}

extension UserDeviceAPIClient.Authentication.InitRememberMasterPassword {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let sessionAccessKey: String?

                public let sessionSecretKey: String?

        public init(sessionAccessKey: String? = nil, sessionSecretKey: String? = nil) {
            self.sessionAccessKey = sessionAccessKey
            self.sessionSecretKey = sessionSecretKey
        }
    }
}
