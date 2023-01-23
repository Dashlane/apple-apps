import Foundation
extension AppAPIClient.Premium {
        public struct SetExternalPremiumStatus {
        public static let endpoint: Endpoint = "/premium/SetExternalPremiumStatus"

        public let api: AppAPIClient

                @discardableResult
        public func callAsFunction(login: String, premiumStatus: Bool, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, premiumStatus: premiumStatus)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var setExternalPremiumStatus: SetExternalPremiumStatus {
        SetExternalPremiumStatus(api: api)
    }
}

extension AppAPIClient.Premium.SetExternalPremiumStatus {
        struct Body: Encodable {

                public let login: String

                public let premiumStatus: Bool
    }
}

extension AppAPIClient.Premium.SetExternalPremiumStatus {
    public typealias Response = Empty?
}
