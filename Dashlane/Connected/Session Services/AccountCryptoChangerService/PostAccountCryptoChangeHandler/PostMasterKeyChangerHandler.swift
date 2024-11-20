import CoreData
import CoreKeychain
import CorePersonalData
import CoreSession
import DashTypes
import Foundation
import LoginKit
import VaultKit

final class PostMasterKeyChangerHandler: PostAccountCryptoChangeHandler {

  let keychainService: AuthenticationKeychainServiceProtocol
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  private(set) var syncService: SyncServiceProtocol

  init(
    keychainService: AuthenticationKeychainServiceProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, syncService: SyncServiceProtocol
  ) {
    self.keychainService = keychainService
    self.resetMasterPasswordService = resetMasterPasswordService
    self.syncService = syncService
  }

  func handle(_ session: Session, syncTimestamp: Timestamp) throws {
    let masterKeyStatus = keychainService.masterKeyStatus(for: session.login)
    if case let .available(accessMode: accessMode) = masterKeyStatus {
      try? keychainService.save(
        session.authenticationMethod.sessionKey.keyChainMasterKey,
        for: session.login,
        expiresAfter: AuthenticationKeychainService.defaultPasswordValidityPeriod,
        accessMode: accessMode)
    }

    if let newMasterPassword = session.authenticationMethod.userMasterPassword {
      #if !targetEnvironment(simulator)
        try resetMasterPasswordService.update(masterPassword: newMasterPassword)
      #endif
    }
    syncService.lastSync = syncTimestamp
  }
}

extension CoreSession.MasterKey {
  var keyChainMasterKey: DashTypes.MasterKey {
    switch self {
    case .masterPassword(let password, _):
      return .masterPassword(password)
    case .ssoKey(let data):
      return .key(data)
    }
  }
}
