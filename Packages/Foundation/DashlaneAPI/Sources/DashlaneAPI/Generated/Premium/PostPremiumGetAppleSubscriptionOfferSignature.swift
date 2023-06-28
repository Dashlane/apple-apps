import Foundation
extension UserDeviceAPIClient.Premium {
        public struct GetAppleSubscriptionOfferSignature: APIRequest {
        public static let endpoint: Endpoint = "/premium/GetAppleSubscriptionOfferSignature"

        public let api: UserDeviceAPIClient

                public func callAsFunction(appBundleID: AppBundleID, productIdentifier: String, offerIdentifier: String, applicationUsername: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(appBundleID: appBundleID, productIdentifier: productIdentifier, offerIdentifier: offerIdentifier, applicationUsername: applicationUsername)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAppleSubscriptionOfferSignature: GetAppleSubscriptionOfferSignature {
        GetAppleSubscriptionOfferSignature(api: api)
    }
}

extension UserDeviceAPIClient.Premium.GetAppleSubscriptionOfferSignature {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case appBundleID = "appBundleID"
            case productIdentifier = "productIdentifier"
            case offerIdentifier = "offerIdentifier"
            case applicationUsername = "applicationUsername"
        }

                public let appBundleID: AppBundleID

                public let productIdentifier: String

                public let offerIdentifier: String

                public let applicationUsername: String
    }

        public enum AppBundleID: String, Codable, Equatable, CaseIterable {
        case comDashlaneDashlanephonefinaldev = "com.dashlane.dashlanephonefinaldev"
        case comDashlaneDashlanephonefinal = "com.dashlane.dashlanephonefinal"
        case comDashlaneDashlane = "com.dashlane.Dashlane"
    }
}

extension UserDeviceAPIClient.Premium.GetAppleSubscriptionOfferSignature {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case keyIdentifier = "keyIdentifier"
            case nonce = "nonce"
            case signature = "signature"
            case timestamp = "timestamp"
        }

                public let keyIdentifier: String

                public let nonce: String

                public let signature: String

                public let timestamp: String

        public init(keyIdentifier: String, nonce: String, signature: String, timestamp: String) {
            self.keyIdentifier = keyIdentifier
            self.nonce = nonce
            self.signature = signature
            self.timestamp = timestamp
        }
    }
}
