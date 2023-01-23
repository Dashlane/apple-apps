import Foundation
extension UserDeviceAPIClient.Premium {
        public struct GetAppleSubscriptionOfferSignature {
        public static let endpoint: Endpoint = "/premium/GetAppleSubscriptionOfferSignature"

        public let api: UserDeviceAPIClient

                public func callAsFunction(appBundleID: AppBundleID, productIdentifier: String, offerIdentifier: String, applicationUsername: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(appBundleID: appBundleID, productIdentifier: productIdentifier, offerIdentifier: offerIdentifier, applicationUsername: applicationUsername)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var getAppleSubscriptionOfferSignature: GetAppleSubscriptionOfferSignature {
        GetAppleSubscriptionOfferSignature(api: api)
    }
}

extension UserDeviceAPIClient.Premium.GetAppleSubscriptionOfferSignature {
        struct Body: Encodable {

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
