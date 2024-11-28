import Foundation

public enum AuthenticationMethod {
  case masterPassword(String, serverKey: String? = nil)
  case invisibleMasterPassword(String)
  case sso(Data)
}

extension AuthenticationMethod {
  public var sessionKey: MasterKey {
    switch self {
    case let .masterPassword(password, serverKey):
      return .masterPassword(password, serverKey: serverKey)
    case let .sso(ssoKey):
      return .ssoKey(ssoKey)
    case let .invisibleMasterPassword(password):
      return .masterPassword(password, serverKey: nil)
    }
  }

  public var userMasterPassword: String? {
    guard case let .masterPassword(masterPassword, _) = self else {
      return nil
    }
    return masterPassword
  }

  public var supportsLock: Bool {
    guard case .sso = self else {
      return true
    }
    return false
  }
}
