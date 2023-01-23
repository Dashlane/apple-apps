import Foundation
extension UserDeviceAPIClient.Pairing {
        public struct RequestPairing {
        public static let endpoint: Endpoint = "/pairing/RequestPairing"

        public let api: UserDeviceAPIClient

                public func callAsFunction(pairingId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(pairingId: pairingId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var requestPairing: RequestPairing {
        RequestPairing(api: api)
    }
}

extension UserDeviceAPIClient.Pairing.RequestPairing {
        struct Body: Encodable {

                public let pairingId: String?
    }
}

extension UserDeviceAPIClient.Pairing.RequestPairing {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let pairingId: String?

        public init(pairingId: String? = nil) {
            self.pairingId = pairingId
        }
    }
}
