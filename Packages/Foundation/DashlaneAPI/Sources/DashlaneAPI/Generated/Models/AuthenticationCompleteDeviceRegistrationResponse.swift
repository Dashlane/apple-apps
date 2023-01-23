import Foundation

public struct AuthenticationCompleteDeviceRegistrationResponse: Codable, Equatable {

        public let deviceAccessKey: String

        public let deviceSecretKey: String

    public let settings: AuthenticationCompleteDeviceRegistrationSettings

        public let numberOfDevices: Int

        public let hasDesktopDevices: Bool

        public let publicUserId: String

        public let deviceAnalyticsId: String

        public let userAnalyticsId: String

        public let remoteKeys: [AuthenticationCompleteRemoteKeys]?

        public let serverKey: String?

    public let sharingKeys: AuthenticationCompleteDeviceRegistrationSharingKeys?

    public init(deviceAccessKey: String, deviceSecretKey: String, settings: AuthenticationCompleteDeviceRegistrationSettings, numberOfDevices: Int, hasDesktopDevices: Bool, publicUserId: String, deviceAnalyticsId: String, userAnalyticsId: String, remoteKeys: [AuthenticationCompleteRemoteKeys]? = nil, serverKey: String? = nil, sharingKeys: AuthenticationCompleteDeviceRegistrationSharingKeys? = nil) {
        self.deviceAccessKey = deviceAccessKey
        self.deviceSecretKey = deviceSecretKey
        self.settings = settings
        self.numberOfDevices = numberOfDevices
        self.hasDesktopDevices = hasDesktopDevices
        self.publicUserId = publicUserId
        self.deviceAnalyticsId = deviceAnalyticsId
        self.userAnalyticsId = userAnalyticsId
        self.remoteKeys = remoteKeys
        self.serverKey = serverKey
        self.sharingKeys = sharingKeys
    }
}
