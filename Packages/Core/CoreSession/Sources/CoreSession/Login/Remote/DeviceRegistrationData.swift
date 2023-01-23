import Foundation
import DashTypes

public struct DeviceRegistrationData: Equatable {
        var initialSettings: String

    public let deviceAccessKey: String
    public let deviceSecretKey: String
    public let analyticsIds: AnalyticsIdentifiers

        let serverKey: String?
    let remoteKeys: [RemoteKey]?
    let ssoServerKey: String?
    public let authTicket: String?
    init(initialSettings: String,
         deviceAccessKey: String,
         deviceSecretKey: String,
         analyticsIds: AnalyticsIdentifiers,
         serverKey: String? = nil,
         remoteKeys: [RemoteKey]? = nil,
         ssoServerKey: String? = nil,
         authTicket: String? = nil) {
        self.initialSettings = initialSettings
        self.deviceAccessKey = deviceAccessKey
        self.deviceSecretKey = deviceSecretKey
        self.serverKey = serverKey
        self.remoteKeys = remoteKeys
        self.ssoServerKey = ssoServerKey
        self.authTicket = authTicket
        self.analyticsIds = analyticsIds
    }
    
    public var masterPasswordRemoteKey: RemoteKey? {
        return remoteKeys?.masterPasswordRemoteKey()
    }
}
