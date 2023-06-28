import Foundation
extension AppAPIClient.Account {
        public struct CreateUser: APIRequest {
        public static let endpoint: Endpoint = "/account/CreateUser"

        public let api: AppAPIClient

                public func callAsFunction(login: String, appVersion: String, platform: AccountCreateUserPlatform, settings: AccountCreateUserSettings, deviceName: String, country: String, osCountry: String, language: String, osLanguage: String, consents: [AccountCreateUserConsents], sharingKeys: AccountCreateUserSharingKeys, abTestingVersion: String? = nil, accountType: AccountAccountType? = nil, askM2dToken: Bool? = nil, contactEmail: String? = nil, contactPhone: String? = nil, origin: String? = nil, remoteKeys: [RemoteKeys]? = nil, sdkVersion: String? = nil, temporaryDevice: Bool? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, appVersion: appVersion, platform: platform, settings: settings, deviceName: deviceName, country: country, osCountry: osCountry, language: language, osLanguage: osLanguage, consents: consents, sharingKeys: sharingKeys, abTestingVersion: abTestingVersion, accountType: accountType, askM2dToken: askM2dToken, contactEmail: contactEmail, contactPhone: contactPhone, origin: origin, remoteKeys: remoteKeys, sdkVersion: sdkVersion, temporaryDevice: temporaryDevice)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }

        public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response {
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createUser: CreateUser {
        CreateUser(api: api)
    }
}

extension AppAPIClient.Account.CreateUser {
        public struct Body: Encodable {

        private enum CodingKeys: String, CodingKey {
            case login = "login"
            case appVersion = "appVersion"
            case platform = "platform"
            case settings = "settings"
            case deviceName = "deviceName"
            case country = "country"
            case osCountry = "osCountry"
            case language = "language"
            case osLanguage = "osLanguage"
            case consents = "consents"
            case sharingKeys = "sharingKeys"
            case abTestingVersion = "abTestingVersion"
            case accountType = "accountType"
            case askM2dToken = "askM2dToken"
            case contactEmail = "contactEmail"
            case contactPhone = "contactPhone"
            case origin = "origin"
            case remoteKeys = "remoteKeys"
            case sdkVersion = "sdkVersion"
            case temporaryDevice = "temporaryDevice"
        }

                public let login: String

                public let appVersion: String

        public let platform: AccountCreateUserPlatform

        public let settings: AccountCreateUserSettings

                public let deviceName: String

                public let country: String

                public let osCountry: String

                public let language: String

                public let osLanguage: String

                public let consents: [AccountCreateUserConsents]

        public let sharingKeys: AccountCreateUserSharingKeys

                public let abTestingVersion: String?

        public let accountType: AccountAccountType?

                public let askM2dToken: Bool?

                public let contactEmail: String?

                public let contactPhone: String?

                public let origin: String?

                public let remoteKeys: [RemoteKeys]?

                public let sdkVersion: String?

                public let temporaryDevice: Bool?
    }

        public struct RemoteKeys: Codable, Equatable {

                public enum `Type`: String, Codable, Equatable, CaseIterable {
            case masterPassword = "master_password"
        }

        private enum CodingKeys: String, CodingKey {
            case uuid = "uuid"
            case key = "key"
            case type = "type"
        }

                public let uuid: String

                public let key: String

                public let type: `Type`

        public init(uuid: String, key: String, type: `Type`) {
            self.uuid = uuid
            self.key = key
            self.type = type
        }
    }
}

extension AppAPIClient.Account.CreateUser {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

        private enum CodingKeys: String, CodingKey {
            case origin = "origin"
            case accountReset = "accountReset"
            case deviceAccessKey = "deviceAccessKey"
            case deviceSecretKey = "deviceSecretKey"
            case userAnalyticsId = "userAnalyticsId"
            case deviceAnalyticsId = "deviceAnalyticsId"
            case abTestingVersion = "abTestingVersion"
            case token = "token"
        }

                public let origin: String

                public let accountReset: Bool

                public let deviceAccessKey: String

                public let deviceSecretKey: String

                public let userAnalyticsId: String

                public let deviceAnalyticsId: String

                public let abTestingVersion: String?

                public let token: String?

        public init(origin: String, accountReset: Bool, deviceAccessKey: String, deviceSecretKey: String, userAnalyticsId: String, deviceAnalyticsId: String, abTestingVersion: String? = nil, token: String? = nil) {
            self.origin = origin
            self.accountReset = accountReset
            self.deviceAccessKey = deviceAccessKey
            self.deviceSecretKey = deviceSecretKey
            self.userAnalyticsId = userAnalyticsId
            self.deviceAnalyticsId = deviceAnalyticsId
            self.abTestingVersion = abTestingVersion
            self.token = token
        }
    }
}
