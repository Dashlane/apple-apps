import Combine

public enum VaultState {
  case `default`
  case frozen
}

public protocol VaultStateServiceProtocol {
  var vaultState: VaultState { get }

  func vaultStatePublisher() -> AnyPublisher<VaultState, Never>
}

public struct VaultStateServiceMock: VaultStateServiceProtocol {
  public let vaultState: VaultState

  public func vaultStatePublisher() -> AnyPublisher<VaultState, Never> {
    return Just(vaultState).eraseToAnyPublisher()
  }
}

extension VaultStateServiceProtocol where Self == VaultStateServiceMock {
  public static func mock(vaultState: VaultState = .default) -> VaultStateServiceMock {
    VaultStateServiceMock(vaultState: vaultState)
  }
}
