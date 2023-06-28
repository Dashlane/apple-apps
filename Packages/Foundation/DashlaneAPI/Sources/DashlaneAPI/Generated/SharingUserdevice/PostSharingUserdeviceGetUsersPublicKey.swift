import Foundation
extension UserDeviceAPIClient.SharingUserdevice {
        public struct GetUsersPublicKey: APIRequest {
        public static let endpoint: Endpoint = "/sharing-userdevice/GetUsersPublicKey"

        public let api: UserDeviceAPIClient

                public func callAsFunction(logins: [String], timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(logins: logins)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getUsersPublicKey: GetUsersPublicKey {
        GetUsersPublicKey(api: api)
    }
}

extension UserDeviceAPIClient.SharingUserdevice.GetUsersPublicKey {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case logins = "logins"
        }

                public let logins: [String]
    }
}

extension UserDeviceAPIClient.SharingUserdevice.GetUsersPublicKey {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case data = "data"
        }

                public let data: [DataType]

                public struct DataType: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case email = "email"
                case login = "login"
                case publicKey = "publicKey"
            }

                        public let email: String

                        public let login: String?

                        public let publicKey: String?

            public init(email: String, login: String?, publicKey: String?) {
                self.email = email
                self.login = login
                self.publicKey = publicKey
            }
        }

        public init(data: [DataType]) {
            self.data = data
        }
    }
}
