import Foundation
import DashTypes

public struct AccountCreationResponse: Decodable {
    let origin: String
    let accountReset: Bool
    public let deviceAccessKey: String
    public let deviceSecretKey: String
    let token: String?
    public let deviceAnalyticsId: String
    public let userAnalyticsId: String

        public var analyticsIds: AnalyticsIdentifiers {
        return AnalyticsIdentifiers(device: deviceAnalyticsId, user: userAnalyticsId)
    }
}
