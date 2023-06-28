import Foundation
import DashTypes
import SwiftTreats
import DashlaneAPI

public struct SharingClientAPIImpl: SharingClientAPI {
    let apiClient: UserDeviceAPIClient.SharingUserdevice

    public init(apiClient: UserDeviceAPIClient.SharingUserdevice) {
        self.apiClient = apiClient
    }
}
