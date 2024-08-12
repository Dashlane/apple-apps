import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public struct SharingClientAPIImpl: SharingClientAPI {
  let apiClient: UserDeviceAPIClient.SharingUserdevice

  public init(apiClient: UserDeviceAPIClient.SharingUserdevice) {
    self.apiClient = apiClient
  }
}
