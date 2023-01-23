import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteDeviceRegistrationWithAuthTicket {
        public static let endpoint: Endpoint = "/authentication/CompleteDeviceRegistrationWithAuthTicket"

        public let api: AppAPIClient

                public func callAsFunction(device: AuthenticationCompleteDeviceRegistrationDevice, login: String, authTicket: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(device: device, login: login, authTicket: authTicket)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeDeviceRegistrationWithAuthTicket: CompleteDeviceRegistrationWithAuthTicket {
        CompleteDeviceRegistrationWithAuthTicket(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket {
        struct Body: Encodable {

        public let device: AuthenticationCompleteDeviceRegistrationDevice

                public let login: String

                public let authTicket: String
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

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

                public let ssoServerKey: String?

        public init(deviceAccessKey: String, deviceSecretKey: String, settings: AuthenticationCompleteDeviceRegistrationSettings, numberOfDevices: Int, hasDesktopDevices: Bool, publicUserId: String, deviceAnalyticsId: String, userAnalyticsId: String, remoteKeys: [AuthenticationCompleteRemoteKeys]? = nil, serverKey: String? = nil, sharingKeys: AuthenticationCompleteDeviceRegistrationSharingKeys? = nil, ssoServerKey: String? = nil) {
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
            self.ssoServerKey = ssoServerKey
        }
    }
}
