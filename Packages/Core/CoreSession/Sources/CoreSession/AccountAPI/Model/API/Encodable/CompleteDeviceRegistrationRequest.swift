import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public typealias DeviceInfo = AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket
  .Body.Device

extension DeviceInfo: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(appVersion)
    hasher.combine(deviceName)
    hasher.combine(osCountry)
    hasher.combine(osLanguage)
    hasher.combine(platform)
    hasher.combine(sdkVersion)
    hasher.combine(temporary)
  }
}

public struct CompleteDeviceRegistrationRequest: Encodable {
  let device: DeviceInfo
  let login: String
  let authTicket: String
}

extension DeviceInfo {
  public static var mock: DeviceInfo {
    self.init(
      deviceName: "", appVersion: "", platform: .serverIphone, osCountry: "", osLanguage: "",
      temporary: true, sdkVersion: nil)
  }
}

extension DeviceInfo {
  public static let `default` = DeviceInfo(
    deviceName: Device.localizedName(),
    appVersion: Application.version(),
    platform: Platform(rawValue: DashTypes.Platform.passwordManager.rawValue) ?? .serverIphone,
    osCountry: System.country,
    osLanguage: System.language,
    temporary: false)
}
