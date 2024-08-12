import Combine

public typealias AccessControlPublisher = AnyPublisher<Bool, Never>

public enum AccessControlReason {
  case unlockItem
  case lockOnExit
  case changeContactEmail
}

public protocol AccessControlProtocol {
  func requestAccess(forReason reason: AccessControlReason) -> AccessControlPublisher
}

extension AccessControlProtocol {
  public func requestAccess() -> AccessControlPublisher {
    return requestAccess(forReason: .unlockItem)
  }

  public func requestAccess(_ completion: @escaping (Bool) -> Void) {
    requestAccess().sinkOnce(receiveValue: completion)
  }

  public func requestAccess(
    forReason reason: AccessControlReason, _ completion: @escaping (Bool) -> Void
  ) {
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
