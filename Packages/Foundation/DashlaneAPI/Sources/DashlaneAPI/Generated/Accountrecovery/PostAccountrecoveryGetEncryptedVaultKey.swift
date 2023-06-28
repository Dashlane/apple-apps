import Foundation
extension AppAPIClient.Accountrecovery {
        public struct GetEncryptedVaultKey: APIRequest {
        public static let endpoint: Endpoint = "/accountrecovery/GetEncryptedVaultKey"

        public let api: AppAPIClient

                public func callAsFunction(login: String, authTicket: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, authTicket: authTicket)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getEncryptedVaultKey: GetEncryptedVaultKey {
        GetEncryptedVaultKey(api: api)
    }
}

extension AppAPIClient.Accountrecovery.GetEncryptedVaultKey {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case authTicket = "authTicket"
        }

                public let login: String

                public let authTicket: String
    }
}

extension AppAPIClient.Accountrecovery.GetEncryptedVaultKey {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case encryptedVaultKey = "encryptedVaultKey"
            case recoveryId = "recoveryId"
        }

                public let encryptedVaultKey: String

                public let recoveryId: String

        public init(encryptedVaultKey: String, recoveryId: String) {
            self.encryptedVaultKey = encryptedVaultKey
            self.recoveryId = recoveryId
        }
    }
}
