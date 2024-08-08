import Foundation

public protocol AuthenticatorPairingProviderProtocol {
  func isPairedWithAuthenticator() -> Bool
}

public class FakeAuthenticatorPairingProvider: AuthenticatorPairingProviderProtocol {
  public init() {}
  public func isPairedWithAuthenticator() -> Bool {
    return true
  }
}
