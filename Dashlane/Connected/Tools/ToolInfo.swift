import Combine
import CorePremium
import Foundation

public struct ToolInfo: Hashable, Identifiable {
  let item: ToolsItem
  let status: CapabilityStatus

  public var id: ToolsItem {
    return item
  }

  init(
    item: ToolsItem,
    status: CapabilityStatus = .available()
  ) {
    self.item = item
    self.status = status
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(item)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    lhs.item == rhs.item
  }
}

extension ToolInfo {
  var badgeStatus: FeatureBadge.Status? {
    return .init(capabilityStatus: status)
  }
}
