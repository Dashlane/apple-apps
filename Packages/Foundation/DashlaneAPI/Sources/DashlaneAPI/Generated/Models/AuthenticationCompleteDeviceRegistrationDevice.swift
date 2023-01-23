import Foundation

public struct AuthenticationCompleteDeviceRegistrationDevice: Codable, Equatable {

        public let deviceName: String

        public let appVersion: String

    public let platform: AuthenticationCompleteDeviceRegistrationPlatform

        public let osCountry: String

        public let osLanguage: String

        public let temporary: Bool

        public let sdkVersion: String?

    public init(deviceName: String, appVersion: String, platform: AuthenticationCompleteDeviceRegistrationPlatform, osCountry: String, osLanguage: String, temporary: Bool, sdkVersion: String? = nil) {
        self.deviceName = deviceName
        self.appVersion = appVersion
        self.platform = platform
        self.osCountry = osCountry
        self.osLanguage = osLanguage
        self.temporary = temporary
        self.sdkVersion = sdkVersion
    }
}
