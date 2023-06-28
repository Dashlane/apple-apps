import Foundation
import DashlaneAPI
import SwiftTreats
import DashTypes

public typealias DeviceInfo = AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket.Device

public struct CompleteDeviceRegistrationRequest: Encodable {
    let device: DeviceInfo
    let login: String
    let authTicket: String
}

extension DeviceInfo {
    public static var mock: DeviceInfo {
        self.init(deviceName: "", appVersion: "", platform: .serverIphone, osCountry: "", osLanguage: "", temporary: true, sdkVersion: nil)
    }
}

public extension DeviceInfo {
    static let `default` = DeviceInfo(deviceName: Device.localizedName(),
                                      appVersion: Application.version(),
                                      platform: Platform(rawValue: DashTypes.Platform.passwordManager.rawValue) ?? .serverIphone,
                                      osCountry: System.country,
                                      osLanguage: System.language,
                                      temporary: false)
}
