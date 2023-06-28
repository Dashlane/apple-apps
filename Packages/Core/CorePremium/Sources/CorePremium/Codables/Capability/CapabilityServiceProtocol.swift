import Foundation
import Combine

public protocol CapabilityServiceProtocol {
    func capabilitiesPublisher() -> any Publisher<StatusCapabilitySet, Never>
    func state(of capability: CapabilityKey) -> CapabilityState
    func statePublisher(of capability: CapabilityKey) -> any Publisher<CapabilityState, Never>
}

public class CapabilityServiceMock: CapabilityServiceProtocol {
    @Published var capabilities: StatusCapabilitySet = .init()

    public init(_ capabilities: StatusCapabilitySet = .init()) {
        self.capabilities = capabilities
    }

    public func capabilitiesPublisher() -> any Publisher<StatusCapabilitySet, Never> {
        return $capabilities
    }

    public func state(of capability: CapabilityKey) -> CapabilityState {
        return capabilities.state(of: capability)
    }

    public func statePublisher(of capability: CapabilityKey) -> any Publisher<CapabilityState, Never> {
        return $capabilities.map { $0.state(of: capability) }
    }
}

public extension CapabilityServiceProtocol where Self == CapabilityServiceMock {
    static func mock(_ capabilities: StatusCapabilitySet = .init()) -> CapabilityServiceMock {
        return .init(capabilities)
    }
}
