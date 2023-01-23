import Foundation
import Combine

public enum CapabilityState: Equatable {
    case available(beta: Bool = false)
    case needsUpgrade
    case unavailable
}

public protocol CapabilityServiceProtocol {
    func state(of capability: CapabilityKey) -> CapabilityState
    func statePublisher(of capability: CapabilityKey) -> AnyPublisher<CapabilityState, Never>
}

public class CapabilityServiceMock: CapabilityServiceProtocol {
    @Published var defaultValue: CapabilityState = .available(beta: false)

    public init() {

    }

    public func state(of capability: CapabilityKey) -> CapabilityState {
        return defaultValue
    }

    public func statePublisher(of capability: CapabilityKey) -> AnyPublisher<CapabilityState, Never> {
        return $defaultValue.eraseToAnyPublisher()
    }
}
