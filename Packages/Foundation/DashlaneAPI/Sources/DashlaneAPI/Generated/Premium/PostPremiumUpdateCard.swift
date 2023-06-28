import Foundation
extension UserDeviceAPIClient.Premium {
        public struct UpdateCard: APIRequest {
        public static let endpoint: Endpoint = "/premium/UpdateCard"

        public let api: UserDeviceAPIClient

                public func callAsFunction(tokenId: String, stripeAccount: String, billingCountry: String? = nil, customerId: String? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(tokenId: tokenId, stripeAccount: stripeAccount, billingCountry: billingCountry, customerId: customerId)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var updateCard: UpdateCard {
        UpdateCard(api: api)
    }
}

extension UserDeviceAPIClient.Premium.UpdateCard {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case tokenId = "tokenId"
            case stripeAccount = "stripeAccount"
            case billingCountry = "billingCountry"
            case customerId = "customerId"
        }

                public let tokenId: String

                public let stripeAccount: String

                public let billingCountry: String?

                public let customerId: String?
    }
}

extension UserDeviceAPIClient.Premium.UpdateCard {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case success = "success"
        }

                public let success: Bool?

        public init(success: Bool? = nil) {
            self.success = success
        }
    }
}
