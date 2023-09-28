import Foundation
import CorePremium
import Combine

extension PremiumService {
    public func capability<T>(for keyPath: KeyPath<StatusCapabilitySet, Capability<T>>) -> Capability<T> {
        guard  let status = status else {
            return .init()
        }

        return status.capabilities[keyPath: keyPath]
    }

    public func capabilityPublisher<T>(for keyPath: KeyPath<StatusCapabilitySet, Capability<T>>) -> AnyPublisher<Capability<T>, Never> {
        return $status.map { status in
            guard let capability = status?.capabilities[keyPath: keyPath] else {
                return .init()
            }
            return capability
        }.eraseToAnyPublisher()
    }
}

extension PremiumService: CapabilityServiceProtocol {
    public func capabilitiesPublisher() -> any Publisher<StatusCapabilitySet, Never> {
        $status.compactMap(\.?.capabilities)
    }

    public func statePublisher(of capability: CapabilityKey) -> any Publisher<CapabilityState, Never> {
        return $status.map { status in
            status?.capabilities.state(of: capability) ?? .available()
        }
    }

    public func state(of capability: CapabilityKey) -> CapabilityState {
        status?.capabilities.state(of: capability) ?? .available()
    }
}
