import Foundation
import UserTrackingFoundation

public enum SessionLoadingContext: Sendable {
  public enum LocalContextOrigin: Sendable {
    case regular(reportedLoginMode: Definition.Mode)
    case afterLogout(reason: SessionServicesUnloadReason)
  }

  case accountCreation
  case localLogin(LocalContextOrigin, isRecoveryKeyUsed: Bool = false)
  case remoteLogin(isRecoveryKeyUsed: Bool = false)

  public var isFirstLogin: Bool {
    switch self {
    case .localLogin:
      return false
    case .accountCreation, .remoteLogin:
      return true
    }
  }

  public var isAccountRecoveryLogin: Bool {
    switch self {
    case let .localLogin(_, isRecoveryKeyUsed):
      return isRecoveryKeyUsed
    case let .remoteLogin(isRecoveryKeyUsed):
      return isRecoveryKeyUsed
    case .accountCreation:
      return false
    }
  }

  public var isAccountCreation: Bool {
    switch self {
    case .localLogin, .remoteLogin:
      return false
    case .accountCreation:
      return true
    }
  }
}
