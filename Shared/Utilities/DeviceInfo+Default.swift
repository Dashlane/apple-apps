import Foundation
import CoreSession
import DashTypes
import SwiftTreats

extension DeviceInfo {
    static let `default` = DeviceInfo(deviceName: Device.localizedName(),
                                      appVersion: Application.version(),
                                      platform: System.platform,
                                      osCountry: System.country,
                                      osLanguage: System.language)
}
