import Foundation
import Combine
import SwiftTreats
import DashlaneAppKit
import CoreFeature
import DashTypes
import CorePremium

public protocol ToolsServiceProtocol {
    func availableNavigationToolItems() -> [ToolsItem]
    func displayableTools() -> any Publisher<[ToolInfo], Never>
}

struct ToolsService: ToolsServiceProtocol {
    private let featureService: FeatureServiceProtocol
    private let capabilityService: CapabilityServiceProtocol

    init(featureService: FeatureServiceProtocol,
         capabilityService: CapabilityServiceProtocol) {
        self.featureService = featureService
        self.capabilityService = capabilityService
    }

    func availableNavigationToolItems() -> [ToolsItem] {
        return ToolsItem.allCases.filter {
            isAvailable($0)
        }
    }

    private func isAvailable(_ item: ToolsItem) -> Bool {
        switch item {
        case .passwordGenerator:
            return Device.isIpadOrMac
        case .identityDashboard:
            return true
        case .secureWifi:
            return true
        case .multiDevices:
            return !Device.isMac
        case .contacts:
            return !Device.isIpadOrMac
        case .darkWebMonitoring:
            return true
        case .authenticator:
            return featureService.isEnabled(.authenticatorTool)
        case .collections:
            return !Device.isIpadOrMac && featureService.isEnabled(.collectionsContainer)
        }
    }

    func displayableTools() -> any Publisher<[ToolInfo], Never> {
        let toolItems = availableNavigationToolItems()
        return capabilityService
            .capabilitiesPublisher()
            .eraseToAnyPublisher()
            .map { (capabilities: StatusCapabilitySet) -> [ToolInfo] in
                toolItems.compactMap { toolItem -> ToolInfo? in
                    if let capabilityKey = toolItem.capabilityKey {
                                                if capabilityKey == .secureWiFi && capabilities.secureWiFi.info?.reason == .unpaidFamilyMember {
                            return nil
                        }
                        return ToolInfo(item: toolItem, state: capabilities.state(of: capabilityKey))
                    } else if case .collections = toolItem {
                        return ToolInfo(item: toolItem, state: .available(beta: true))
                    } else {
                        return ToolInfo(item: toolItem)
                    }
                }
            }
    }
}

extension ToolsItem {
    var capabilityKey: CapabilityKey? {
        switch self {
        case .secureWifi:
            return .secureWiFi
        case .darkWebMonitoring:
            return .dataLeak
        default:
            return nil
        }
    }
}

extension ToolsServiceProtocol where Self == ToolsService {
    static func mock(capabilities: StatusCapabilitySet = .init(), features: [ControlledFeature] = []) -> ToolsService {
        return .init(featureService: .mock(features: features), capabilityService: .mock(capabilities))
    }
}
