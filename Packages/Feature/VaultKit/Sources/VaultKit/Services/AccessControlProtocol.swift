import Combine

public typealias AccessControlPublisher = AnyPublisher<Bool, Never>

public enum AccessControlReason {
    case unlockItem
    case lockOnExit
}

public protocol AccessControlProtocol {
    func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher
}

public extension AccessControlProtocol {
    func requestAccess() -> AccessControlPublisher {
        return requestAccess(forReason: .unlockItem)
    }

    func requestAccess(_ completion: @escaping (Bool) -> Void) {
        requestAccess().sinkOnce(receiveValue: completion)
    }

    func requestAccess(forReason reason: AccessControlReason, _ completion: @escaping (Bool) -> Void) {
        requestAccess(forReason: reason).sinkOnce(receiveValue: completion)
    }
}

public struct FakeAccessControl: AccessControlProtocol {
    public let accept: Bool

    public init(accept: Bool) {
        self.accept = accept
    }

    public func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher {
        return Just(accept).eraseToAnyPublisher()
    }
}
