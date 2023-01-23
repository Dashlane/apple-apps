import Foundation
extension AppAPIClient.Account {
        public struct CreateUserWithSSO {
        public static let endpoint: Endpoint = "/account/CreateUserWithSSO"

        public let api: AppAPIClient

                public func callAsFunction(login: String, contactEmail: String, appVersion: String, sdkVersion: String, platform: AccountCreateUserPlatform, settings: AccountCreateUserSettings, deviceName: String, country: String, osCountry: String, language: String, osLanguage: String, consents: [AccountCreateUserConsents], sharingKeys: AccountCreateUserSharingKeys, ssoToken: String, ssoServerKey: String, remoteKeys: [RemoteKeys], temporaryDevice: Bool? = nil, timeout: TimeInterval? = nil) async throws -> Response {
            let body = Body(login: login, contactEmail: contactEmail, appVersion: appVersion, sdkVersion: sdkVersion, platform: platform, settings: settings, deviceName: deviceName, country: country, osCountry: osCountry, language: language, osLanguage: osLanguage, consents: consents, sharingKeys: sharingKeys, ssoToken: ssoToken, ssoServerKey: ssoServerKey, remoteKeys: remoteKeys, temporaryDevice: temporaryDevice)
            return try await api.post(Self.endpoint, body: body, timeout: timeout)
        }
    }

        public var createUserWithSSO: CreateUserWithSSO {
        CreateUserWithSSO(api: api)
    }
}

extension AppAPIClient.Account.CreateUserWithSSO {
        struct Body: Encodable {

                public let login: String

                public let contactEmail: String

                public let appVersion: String

                public let sdkVersion: String

        public let platform: AccountCreateUserPlatform

        public let settings: AccountCreateUserSettings

                public let deviceName: String

                public let country: String

                public let osCountry: String

                public let language: String

                public let osLanguage: String

                public let consents: [AccountCreateUserConsents]

        public let sharingKeys: AccountCreateUserSharingKeys

                public let ssoToken: String

                public let ssoServerKey: String

                public let remoteKeys: [RemoteKeys]

                public let temporaryDevice: Bool?
    }

        public struct RemoteKeys: Codable, Equatable {

                public enum `Type`: String, Codable, Equatable, CaseIterable {
            case sso = "sso"
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

extension AppAPIClient.Account.CreateUserWithSSO {
    public typealias Response = DataType

        public struct DataType: Codable, Equatable {

                public let origin: String

                public let accountReset: Bool

                public let deviceAccessKey: String

                public let deviceSecretKey: String

                public let userAnalyticsId: String

                public let deviceAnalyticsId: String

                public let abTestingVersion: String?

        public init(origin: String, accountReset: Bool, deviceAccessKey: String, deviceSecretKey: String, userAnalyticsId: String, deviceAnalyticsId: String, abTestingVersion: String? = nil) {
            self.origin = origin
            self.accountReset = accountReset
            self.deviceAccessKey = deviceAccessKey
            self.deviceSecretKey = deviceSecretKey
            self.userAnalyticsId = userAnalyticsId
            self.deviceAnalyticsId = deviceAnalyticsId
            self.abTestingVersion = abTestingVersion
        }
    }
}
