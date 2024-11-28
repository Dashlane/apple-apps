import Combine

public enum VaultState {
  case `default`
  case frozen
}

public protocol VaultStateServiceProtocol {
  func vaultStatePublisher() -> AnyPublisher<VaultState, Never>
}

public struct FakeVaultStateService: VaultStateServiceProtocol {
  public func vaultStatePublisher() -> AnyPublisher<VaultState, Never> {
    return Just(.default).eraseToAnyPublisher()
  }
}

extension VaultStateServiceProtocol where Self == FakeVaultStateService {
  public static var mock: FakeVaultStateService {
    FakeVaultStateService()
  }
}
