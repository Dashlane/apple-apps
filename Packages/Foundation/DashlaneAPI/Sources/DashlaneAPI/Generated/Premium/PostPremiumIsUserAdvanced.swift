import Foundation
extension UserDeviceAPIClient.Premium {
        public struct IsUserAdvanced {
        public static let endpoint: Endpoint = "/premium/IsUserAdvanced"

        public let api: UserDeviceAPIClient

                public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body()
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var isUserAdvanced: IsUserAdvanced {
        IsUserAdvanced(api: api)
    }
}

extension UserDeviceAPIClient.Premium.IsUserAdvanced {
        struct Body: Encodable {
    }
}

extension UserDeviceAPIClient.Premium.IsUserAdvanced {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let isUserAdvanced: Bool

        public init(isUserAdvanced: Bool) {
            self.isUserAdvanced = isUserAdvanced
        }
    }
}
