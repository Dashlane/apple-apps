import CoreKeychain
import CoreSession
import Foundation
import SwiftTreats

extension UnlockSessionHandler {
  public func validateMasterKey(_ masterKey: CoreSession.MasterKey, isRecoveryLogin: Bool)
    async throws
  {
    try await unlock(with: masterKey, isRecoveryLogin: isRecoveryLogin)
  }

  public func validateMasterKey(_ masterKey: CoreKeychain.MasterKey, isRecoveryLogin: Bool)
    async throws
  {
    switch masterKey {
    case .masterPassword(let masterPassword):
      try await validateMasterKey(
        .masterPassword(masterPassword, serverKey: nil), isRecoveryLogin: isRecoveryLogin)
    case .key(let key):
      try await validateMasterKey(.ssoKey(key), isRecoveryLogin: isRecoveryLogin)
    }
  }
}
