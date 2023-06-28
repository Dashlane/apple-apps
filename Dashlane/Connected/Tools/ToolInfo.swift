import Foundation
import Combine
import CorePremium

public struct ToolInfo: Hashable, Identifiable {
    let item: ToolsItem
    let state: CapabilityState

    public var id: ToolsItem {
        return item
    }

    init(item: ToolsItem,
         state: CapabilityState = .available(beta: false)) {
        self.item = item
        self.state = state
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
        return .init(capabilityState: state)
    }
}
