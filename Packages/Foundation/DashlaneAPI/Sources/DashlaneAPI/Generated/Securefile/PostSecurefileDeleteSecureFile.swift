import Foundation
extension UserDeviceAPIClient.Securefile {
        public struct DeleteSecureFile {
        public static let endpoint: Endpoint = "/securefile/DeleteSecureFile"

        public let api: UserDeviceAPIClient

                public func callAsFunction(secureFileInfoId: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(secureFileInfoId: secureFileInfoId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var deleteSecureFile: DeleteSecureFile {
        DeleteSecureFile(api: api)
    }
}

extension UserDeviceAPIClient.Securefile.DeleteSecureFile {
        struct Body: Encodable {

                public let secureFileInfoId: String
    }
}

extension UserDeviceAPIClient.Securefile.DeleteSecureFile {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let quota: Quota

                public struct Quota: Codable, Equatable {

                        public let remaining: Int

                        public let max: Int

            public init(remaining: Int, max: Int) {
                self.remaining = remaining
                self.max = max
            }
        }

        public init(quota: Quota) {
            self.quota = quota
        }
    }
}
