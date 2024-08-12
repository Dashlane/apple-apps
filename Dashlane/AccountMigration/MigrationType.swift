import CoreSession
import Foundation

enum MigrationType {
  case masterPasswordToMasterPassword
  case masterPasswordToRemoteKey(SSOAuthenticationInfo)
  case remoteKeyToMasterPassword(SSOAuthenticationInfo)
}

extension MigrationType {
  var isMasterPasswordToMasterPassword: Bool {
    if case .masterPasswordToMasterPassword = self {
      return true
    }
    return false
  }
}
