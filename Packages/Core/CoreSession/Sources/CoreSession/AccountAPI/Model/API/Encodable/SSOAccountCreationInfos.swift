import Foundation
import DashTypes

public struct SSOAccountCreationInfos: Encodable {
    public let login: String
    public let contactEmail: String
    public let appVersion: String
    public let sdkVersion: String
    public let platform: String
    public let settings: CoreSessionSettings
    public let consents: [Consent]
    public let deviceName: String
    public let country: String
    public let osCountry: String
    public let language: String
    public let osLanguage: String
    public let sharingKeys: SharingKeys
    public let ssoToken: String
    public let ssoServerKey: String
    public let remoteKeys: [RemoteKey]

    public init(login: String,
                contactEmail: String,
                contactPhone: String? = nil,
                appVersion: String,
                sdkVersion: String = "1.0.0.0",
                platform: String,
                settings: CoreSessionSettings,
                deviceName: String,
                country: String,
                language: String,
                sharingKeys: SharingKeys,
                consents: [Consent],
                ssoToken: String,
                ssoServerKey: String,
                remoteKeys: [RemoteKey]) {
        self.login = login.lowercased()
        self.contactEmail = contactEmail.lowercased()
        self.appVersion = appVersion
        self.sdkVersion = sdkVersion
        self.platform = platform
        self.settings = settings
        self.deviceName = deviceName
        self.country = country
        self.osCountry = country
        self.language = language
        self.osLanguage = language
        self.sharingKeys = sharingKeys
        self.consents = consents
        self.ssoToken = ssoToken
        self.ssoServerKey = ssoServerKey
        self.remoteKeys = remoteKeys
    }
}
