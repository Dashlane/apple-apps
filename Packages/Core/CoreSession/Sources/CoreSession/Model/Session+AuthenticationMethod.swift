import Foundation

extension Session {
  public var authenticationMethod: AuthenticationMethod {
    switch configuration.masterKey {
    case let .masterPassword(password, serverKey):
      if configuration.info.accountType == .invisibleMasterPassword {
        return .invisibleMasterPassword(password)
      }
      return .masterPassword(password, serverKey: serverKey)
    case let .ssoKey(key):
      return .sso(key)
    }
  }
}
