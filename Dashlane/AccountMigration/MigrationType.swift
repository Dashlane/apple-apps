import Foundation
import CoreSession

enum MigrationType {
    case masterPasswordToMasterPassword
    case masterPasswordToRemoteKey(SSOValidator) 
    case remoteKeyToMasterPassword(SSOValidator) 
}

extension MigrationType {
    var isMasterPasswordToMasterPassword: Bool {
        if case .masterPasswordToMasterPassword = self {
            return true
        }
        return false
    }
}
