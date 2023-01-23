import Foundation
import CorePremium
import CoreFeature
import Combine
import DashlaneAppKit

class CapabilityService: CapabilityServiceProtocol {
    
    private let featureService: FeatureServiceProtocol
    private let premiumService: PremiumService

    init(featureService: FeatureServiceProtocol,
         premiumService: PremiumService) {
        self.featureService = featureService
        self.premiumService = premiumService
    }
    
    func statePublisher(of capability: CapabilityKey) -> AnyPublisher<CapabilityState, Never> {
        return premiumService.$status.map { _ in
            self.state(of: capability)
        }.eraseToAnyPublisher()
    }
    
    func state(of capability: CapabilityKey) -> CapabilityState {
        switch capability {
        case .creditMonitoring:
            return premiumService.capability(for: \.creditMonitoring).enabled  ? .available(beta: false) : .needsUpgrade
        case .dataLeak:
            return premiumService.capability(for: \.dataLeak).enabled  ? .available(beta: false) : .needsUpgrade
        case .devicesLimit:
            return premiumService.capability(for: \.devicesLimit).enabled  ? .available(beta: false) : .needsUpgrade
        case .identityRestoration:
            return premiumService.capability(for: \.identityRestoration).enabled  ? .available(beta: false) : .needsUpgrade
        case .identityTheftProtection:
            return premiumService.capability(for: \.identityTheftProtection).enabled  ? .available(beta: false) : .needsUpgrade
        case .secureFiles:
            return premiumService.capability(for: \.secureFiles).enabled  ? .available(beta: false) : .needsUpgrade
        case .secureNotes:
            return premiumService.capability(for: \.secureNotes).enabled ? .available(beta: false) : .needsUpgrade
        case .secureWiFi:
            let capability = premiumService.capability(for: \.secureWiFi)
                                    if capability.info?.reason == .team && !capability.enabled {
                return .unavailable
            }
            return capability.enabled ? .available(beta: false) : .needsUpgrade
        case .securityBreach:
            return premiumService.capability(for: \.securityBreach).enabled  ? .available(beta: false) : .needsUpgrade
        case .sharingLimit:
            return premiumService.capability(for: \.sharingLimit).enabled  ? .available(beta: false) : .needsUpgrade
        case .sync:
            return premiumService.capability(for: \.sync).enabled  ? .available(beta: false) : .needsUpgrade
        case .yubikey:
            return premiumService.capability(for: \.yubikey).enabled  ? .available(beta: false) : .needsUpgrade
        }
    }
}

extension CapabilityService {
    static var mock: CapabilityServiceProtocol {
        return CapabilityServiceMock()
    }
}
