import Foundation
extension UserDeviceAPIClient.Premium {
        public struct UpdateCard {
        public static let endpoint: Endpoint = "/premium/UpdateCard"

        public let api: UserDeviceAPIClient

                public func callAsFunction(tokenId: String, stripeAccount: String, billingCountry: String? = nil, customerId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(tokenId: tokenId, stripeAccount: stripeAccount, billingCountry: billingCountry, customerId: customerId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateCard: UpdateCard {
        UpdateCard(api: api)
    }
}

extension UserDeviceAPIClient.Premium.UpdateCard {
        struct Body: Encodable {

                public let tokenId: String

                public let stripeAccount: String

                public let billingCountry: String?

                public let customerId: String?
    }
}

extension UserDeviceAPIClient.Premium.UpdateCard {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let success: Bool?

        public init(success: Bool? = nil) {
            self.success = success
        }
    }
}
