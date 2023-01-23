import Foundation
import Combine
import SwiftTreats
import DashlaneAppKit
import CoreFeature
import DashTypes
import CorePremium

struct ToolsService: Mockable {

    private let featureService: FeatureServiceProtocol
    private let capabilityService: CapabilityServiceProtocol

    init(featureService: FeatureServiceProtocol,
         capabilityService: CapabilityServiceProtocol) {
        self.featureService = featureService
        self.capabilityService = capabilityService
    }

    private func isDisplayable(_ item: ToolsItem) -> Bool {
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
        }
    }

    public func displayableItems() -> [ToolsViewCellData] {
        ToolsItem.allCases
            .filter { isDisplayable($0) }
            .map({ ToolsViewCellData(withItem: $0, capabilityService: capabilityService) })
    }
}

struct ToolsServiceMock: ToolsServiceProtocol {

    var currentlyAvailableItems: [ToolsItem] = ToolsItem.allCases

    func displayableItems() -> [ToolsViewCellData] {
        currentlyAvailableItems.map({ ToolsViewCellData(withItem: $0, capabilityService: CapabilityService.mock) })
    }

}
