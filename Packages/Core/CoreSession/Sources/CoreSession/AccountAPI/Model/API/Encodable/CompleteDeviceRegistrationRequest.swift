import Foundation

public struct CompleteDeviceRegistrationRequest: Encodable {
    let device: DeviceInfo
    let login: String
    let authTicket: String
}

public struct DeviceInfo: Encodable {
    public  let deviceName: String
    public  let appVersion: String
    public  let platform: String
    public  let osCountry: String
    public  let osLanguage: String
    public  let temporary: Bool

    public init(deviceName: String, appVersion: String, platform: String, osCountry: String, osLanguage: String, temporary: Bool = false) {
        self.deviceName = deviceName
        self.appVersion = appVersion
        self.platform = platform
        self.osCountry = osCountry
        self.osLanguage = osLanguage
        self.temporary = temporary
    }
}
