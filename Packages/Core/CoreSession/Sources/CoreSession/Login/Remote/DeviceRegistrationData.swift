import Foundation
import DashTypes
import DashlaneAPI

public typealias RemoteKey = AuthenticationCompleteWithAuthTicketRemoteKeys

public struct DeviceRegistrationData: Equatable {
        var initialSettings: String

    public let deviceAccessKey: String
    public let deviceSecretKey: String
    public let analyticsIds: AnalyticsIdentifiers

        let serverKey: String?
    let remoteKeys: [RemoteKey]?
    let ssoServerKey: String?
    public let authTicket: AuthTicket
    public init(initialSettings: String,
                deviceAccessKey: String,
                deviceSecretKey: String,
                analyticsIds: AnalyticsIdentifiers,
                serverKey: String? = nil,
                remoteKeys: [AuthenticationCompleteWithAuthTicketRemoteKeys]? = nil,
                ssoServerKey: String? = nil,
                authTicket: String) {
        self.initialSettings = initialSettings
        self.deviceAccessKey = deviceAccessKey
        self.deviceSecretKey = deviceSecretKey
        self.serverKey = serverKey
        self.remoteKeys = remoteKeys
        self.ssoServerKey = ssoServerKey
        self.authTicket = AuthTicket(value: authTicket)
        self.analyticsIds = analyticsIds
    }

    public var masterPasswordRemoteKey: RemoteKey? {
        return remoteKeys?.masterPasswordRemoteKey()
    }

    public var ssoRemoteKey: RemoteKey? {
        return remoteKeys?.ssoRemoteKey()
    }

    public func remoteKey(for masterKey: MasterKey) -> RemoteKey? {
        switch masterKey {
        case .masterPassword:
            return masterPasswordRemoteKey
        case .ssoKey:
            return ssoRemoteKey
        }
    }
}

public extension DeviceRegistrationData {
    static var mock: DeviceRegistrationData {
        DeviceRegistrationData(initialSettings: "", deviceAccessKey: "deviceAccessKey", deviceSecretKey: "deviceSecretKey", analyticsIds: AnalyticsIdentifiers(device: "device", user: "user"), authTicket: "authTicket")
    }
}
