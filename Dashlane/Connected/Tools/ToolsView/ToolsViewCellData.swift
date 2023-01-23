import Foundation
import Combine
import CorePremium

typealias BadgeConfigurationPublisher = AnyPublisher<BadgeConfiguration?, Never>

private extension BadgeConfigurationPublisher {
    static var `default`: BadgeConfigurationPublisher {
        CurrentValueSubject<BadgeConfiguration?, Never>(nil).eraseToAnyPublisher()
    }
}

public struct ToolsViewCellData: Hashable {
    let image: ImageAsset
    let title: String
    let item: ToolsItem
    let isEnabled: Bool
    let badgeConfiguration: BadgeConfigurationPublisher

    fileprivate init(item: ToolsItem,
                     isEnabled: Bool = true,
                     badgeConfiguration: BadgeConfigurationPublisher = .default) {
        self.image = item.image
        self.title = item.title
        self.isEnabled = isEnabled
        self.badgeConfiguration = badgeConfiguration
        self.item = item
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title
    }
}

extension ToolsViewCellData {
    static func mock(item: ToolsItem,
                     isEnabled: Bool = true,
                     badgeConfiguration: BadgeConfiguration? = nil) -> ToolsViewCellData {
        ToolsViewCellData(
            item: item,
            isEnabled: isEnabled,
            badgeConfiguration: CurrentValueSubject<BadgeConfiguration?, Never>.init(badgeConfiguration).eraseToAnyPublisher()
        )

    }
}

extension ToolsViewCellData {
    init(withItem item: ToolsItem, capabilityService: CapabilityServiceProtocol) {
        switch item {
        case .secureWifi:
            self.init(item: item,
                      isEnabled: !(capabilityService.state(of: .secureWiFi) == .unavailable),
                      badgeConfiguration: capabilityService.badgeConfigurationPublisher(of: .secureWiFi))
        case .darkWebMonitoring:
            self.init(item: item,
                      badgeConfiguration: capabilityService.badgeConfigurationPublisher(of: .dataLeak))
        case .authenticator:
            self.init(item: item,
                      badgeConfiguration: Just(.init(capabilityState: .available(beta: true))).eraseToAnyPublisher())
        default:
            self.init(item: item)
        }
    }
}

private extension CapabilityServiceProtocol {
    func badgeConfigurationPublisher(of capability: CapabilityKey) -> AnyPublisher<BadgeConfiguration?, Never> {
        let capabilityState = statePublisher(of: capability)
        return capabilityState.map(BadgeConfiguration.init).eraseToAnyPublisher()
    }
}
