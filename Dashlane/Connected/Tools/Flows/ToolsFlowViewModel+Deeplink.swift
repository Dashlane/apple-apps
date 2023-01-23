import Foundation
import SwiftTreats

extension ToolsFlowViewModel {

    func canHandle(deeplink: ToolDeepLinkComponent) -> Bool {
        let item: ToolsItem
        guard let firstStep = self.steps.first else {
            assertionFailure("Missing first step, shouldn't happen.")
            return false
        }
        switch firstStep {
        case let .item(toolsItem), let .placeholder(toolsItem):
            item = toolsItem
        case .root:
                                    return true
        case .unresolvedAlert:
            assertionFailure("Unresolved alerts should never be the first step for any tool flow, whether it's on iPhone or iPad.")
            return false
        }

        guard let expectedItem = deeplink.expectedItem else {
            return true
        }

        return expectedItem == item
    }

    func handleDeepLink(_ deeplink: ToolDeepLinkComponent, origin: String?) {
        steps = [steps[0]]
        switch deeplink {
        case let .otherTool(tool):
            switch tool {
            case .tools:
                break
            case .generator, .history:
                assertionFailure("Should not land here, the viewModel needs to be called directly by the Sessions Coordinator")
                self.didSelect(item: .passwordGenerator)
            case .vpn:
                self.didSelect(item: .secureWifi)
            case .contacts:
                self.didSelect(item: .contacts)
            }
        case .identityDashboard:
            self.didSelect(item: .identityDashboard)
        case .darkWebMonitoring:
            self.didSelect(item: .darkWebMonitoring)
        case let .unresolvedAlert(alert):
            self.steps.append(.unresolvedAlert(.init(alert)))
        case .authenticator:
            self.didSelect(item: .authenticator)
        }
    }
}

private extension ToolDeepLinkComponent {
    var expectedItem: ToolsItem? {
        switch self {
        case let .otherTool(tool):
            switch tool {
            case .tools:
                                                return Device.isIpadOrMac ? .identityDashboard : nil
            case .generator, .history:
                return .passwordGenerator
            case .vpn:
                return .secureWifi
            case .contacts:
                return .contacts
            }
        case .identityDashboard:
            return .identityDashboard
        case .darkWebMonitoring:
            return .darkWebMonitoring
        case .unresolvedAlert:
                        return nil
        case .authenticator:
            return .authenticator
        }
    }
}
