import DashlaneAPI
import Foundation
import SwiftTreats

public typealias SharingSummaryInfo = UserDeviceAPIClient.Sync.GetLatestContent.Response.Sharing2

extension SharingSummaryInfo {
  var isEmpty: Bool {
    return items.isEmpty && itemGroups.isEmpty && userGroups.isEmpty && collections.isEmpty
  }
}
