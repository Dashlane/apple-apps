import Foundation

public enum CapabilityState: Equatable {
    case available(beta: Bool = false)
    case needsUpgrade
    case unavailable
}

public extension CapabilitySet {
    func state(of capability: CapabilityKey) -> CapabilityState {
        switch capability {
        case .creditMonitoring:
            return .init(capability: creditMonitoring)
        case .dataLeak:
            return .init(capability: dataLeak)
        case .devicesLimit:
            return .init(capability: devicesLimit)
        case .identityRestoration:
            return .init(capability: identityRestoration)
        case .identityTheftProtection:
            return .init(capability: identityTheftProtection)
        case .secureFiles:
            return .init(capability: secureFiles)
        case .secureNotes:
            return .init(capability: secureNotes)
        case .secureWiFi:
                                    if secureWiFi.info?.reason == .team && !secureWiFi.enabled {
                return .unavailable
            }
            if secureWiFi.info?.reason == .unpaidFamilyMember {
                return .unavailable
            }
            return .init(capability: secureWiFi)
        case .securityBreach:
            return .init(capability: securityBreach)
        case .sharingLimit:
            return .init(capability: sharingLimit)
        case .sync:
            return .init(capability: sync)
        case .yubikey:
            return .init(capability: yubikey)
        }
    }
}

fileprivate extension CapabilityState {
    init<Info: Decodable>(capability: Capability<Info>) {
        self = capability.enabled ? .available(beta: false) : .needsUpgrade
    }
}
