import Foundation
import DashTypes

public struct AccountInfo: Decodable {
    let deviceAnalyticsId: String
    let userAnalyticsId: String

    public init(deviceAnalyticsId: String, userAnalyticsId: String) {
        self.deviceAnalyticsId = deviceAnalyticsId
        self.userAnalyticsId = userAnalyticsId
    }

    public var analyticsIds: AnalyticsIdentifiers {
        return AnalyticsIdentifiers(device: deviceAnalyticsId, user: userAnalyticsId)
    }
}
