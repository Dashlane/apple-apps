import Foundation
extension UserDeviceAPIClient.Authentication {
        public struct GetU2FDevices {
        public static let endpoint: Endpoint = "/authentication/GetU2FDevices"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getU2FDevices: GetU2FDevices {
        GetU2FDevices(api: api)
    }
}

extension UserDeviceAPIClient.Authentication.GetU2FDevices {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Authentication.GetU2FDevices {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        public let u2fDevices: [U2fDevices]

                public struct U2fDevices: Codable, Equatable {

                        public let keyHandle: String

                        public let name: String

                        public let creationDateUnix: Int

                        public let lastUsedDateUnix: Int

                        public let lastUsedFromIP: String

                        public let lastUsedFromThisIp: Bool

                        public let lastUsedFromCountry: String

            public init(keyHandle: String, name: String, creationDateUnix: Int, lastUsedDateUnix: Int, lastUsedFromIP: String, lastUsedFromThisIp: Bool, lastUsedFromCountry: String) {
                self.keyHandle = keyHandle
                self.name = name
                self.creationDateUnix = creationDateUnix
                self.lastUsedDateUnix = lastUsedDateUnix
                self.lastUsedFromIP = lastUsedFromIP
                self.lastUsedFromThisIp = lastUsedFromThisIp
                self.lastUsedFromCountry = lastUsedFromCountry
            }
        }

        public init(u2fDevices: [U2fDevices]) {
            self.u2fDevices = u2fDevices
        }
    }
}
