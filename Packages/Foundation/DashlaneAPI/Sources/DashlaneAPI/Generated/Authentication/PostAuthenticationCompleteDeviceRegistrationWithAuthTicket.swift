import Foundation
extension AppAPIClient.Authentication {
        public struct CompleteDeviceRegistrationWithAuthTicket: APIRequest {
        public static let endpoint: Endpoint = "/authentication/CompleteDeviceRegistrationWithAuthTicket"

        public let api: AppAPIClient

                public func callAsFunction(device: Device, login: String, authTicket: String, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(device: device, login: login, authTicket: authTicket)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var completeDeviceRegistrationWithAuthTicket: CompleteDeviceRegistrationWithAuthTicket {
        CompleteDeviceRegistrationWithAuthTicket(api: api)
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case device = "device"
            case login = "login"
            case authTicket = "authTicket"
        }

        public let device: Device

                public let login: String

                public let authTicket: String
    }

        public struct Device: Codable, Equatable {

                public enum Platform: String, Codable, Equatable, CaseIterable {
            case serverMacosx = "server_macosx"
            case serverWin = "server_win"
            case desktopWin = "desktop_win"
            case desktopMacos = "desktop_macos"
            case serverCatalyst = "server_catalyst"
            case serverIphone = "server_iphone"
            case serverIpad = "server_ipad"
            case serverIpod = "server_ipod"
            case serverAndroid = "server_android"
            case web = "web"
            case webaccess = "webaccess"
            case realWebsite = "real_website"
            case website = "website"
            case serverCarbonTests = "server_carbon_tests"
            case serverWac = "server_wac"
            case serverTac = "server_tac"
            case serverLeeloo = "server_leeloo"
            case serverLeelooDev = "server_leeloo_dev"
            case serverStandalone = "server_standalone"
            case serverSafari = "server_safari"
            case unitaryTests = "unitary_tests"
            case userSupport = "userSupport"
        }

        private enum CodingKeys: String, CodingKey {
            case deviceName = "deviceName"
            case appVersion = "appVersion"
            case platform = "platform"
            case osCountry = "osCountry"
            case osLanguage = "osLanguage"
            case temporary = "temporary"
            case sdkVersion = "sdkVersion"
        }

                public let deviceName: String

                public let appVersion: String

                public let platform: Platform

                public let osCountry: String

                public let osLanguage: String

                public let temporary: Bool

                public let sdkVersion: String?

        public init(deviceName: String, appVersion: String, platform: Platform, osCountry: String, osLanguage: String, temporary: Bool, sdkVersion: String? = nil) {
            self.deviceName = deviceName
            self.appVersion = appVersion
            self.platform = platform
            self.osCountry = osCountry
            self.osLanguage = osLanguage
            self.temporary = temporary
            self.sdkVersion = sdkVersion
        }
    }
}

extension AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case deviceAccessKey = "deviceAccessKey"
            case deviceSecretKey = "deviceSecretKey"
            case settings = "settings"
            case numberOfDevices = "numberOfDevices"
            case hasDesktopDevices = "hasDesktopDevices"
            case publicUserId = "publicUserId"
            case deviceAnalyticsId = "deviceAnalyticsId"
            case userAnalyticsId = "userAnalyticsId"
            case remoteKeys = "remoteKeys"
            case serverKey = "serverKey"
            case sharingKeys = "sharingKeys"
            case ssoServerKey = "ssoServerKey"
        }

                public let deviceAccessKey: String

                public let deviceSecretKey: String

        public let settings: Settings

                public let numberOfDevices: Int

                public let hasDesktopDevices: Bool

                public let publicUserId: String

                public let deviceAnalyticsId: String

                public let userAnalyticsId: String

                public let remoteKeys: [AuthenticationCompleteWithAuthTicketRemoteKeys]?

                public let serverKey: String?

                public let sharingKeys: SharingKeys?

                public let ssoServerKey: String?

                public struct Settings: Codable, Equatable {

                        public enum `Type`: String, Codable, Equatable, CaseIterable {
                case settings = "SETTINGS"
            }

                        public enum Action: String, Codable, Equatable, CaseIterable {
                case backupEdit = "BACKUP_EDIT"
            }

            private enum CodingKeys: String, CodingKey {
                case backupDate = "backupDate"
                case identifier = "identifier"
                case time = "time"
                case content = "content"
                case type = "type"
                case action = "action"
            }

                        public let backupDate: Int

                        public let identifier: String

                        public let time: Int

                        public let content: String

            public let type: `Type`

                        public let action: Action

            public init(backupDate: Int, identifier: String, time: Int, content: String, type: `Type`, action: Action) {
                self.backupDate = backupDate
                self.identifier = identifier
                self.time = time
                self.content = content
                self.type = type
                self.action = action
            }
        }

                public struct SharingKeys: Codable, Equatable {

            private enum CodingKeys: String, CodingKey {
                case privateKey = "privateKey"
                case publicKey = "publicKey"
            }

            public let privateKey: String

            public let publicKey: String

            public init(privateKey: String, publicKey: String) {
                self.privateKey = privateKey
                self.publicKey = publicKey
            }
        }

        public init(deviceAccessKey: String, deviceSecretKey: String, settings: Settings, numberOfDevices: Int, hasDesktopDevices: Bool, publicUserId: String, deviceAnalyticsId: String, userAnalyticsId: String, remoteKeys: [AuthenticationCompleteWithAuthTicketRemoteKeys]? = nil, serverKey: String? = nil, sharingKeys: SharingKeys? = nil, ssoServerKey: String? = nil) {
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
