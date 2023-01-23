import Foundation
import DashTypes
import CoreSession
import CorePersonalData
import CoreKeychain
import CoreData
import DashlaneAppKit
import LoginKit

final class PostMasterKeyChangerHandler: PostAccountCryptoChangeHandler {

    let keychainService: AuthenticationKeychainServiceProtocol
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    private(set) var syncService: SyncServiceProtocol

    init(keychainService: AuthenticationKeychainServiceProtocol, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, syncService: SyncServiceProtocol) {
        self.keychainService = keychainService
        self.resetMasterPasswordService = resetMasterPasswordService
        self.syncService = syncService
    }

    func handle(_ session: Session, syncTimestamp: Timestamp) throws {
        let masterKeyStatus = keychainService.masterKeyStatus(for: session.login)
        if case let .available(accessMode: accessMode) = masterKeyStatus {
            try? keychainService.save(session.configuration.masterKey.keyChainMasterKey,
                                      for: session.login,
                                      expiresAfter: AuthenticationKeychainService.defaultPasswordValidityPeriod,
                                      accessMode: accessMode)
        }

                if let newMasterPassword = session.configuration.masterKey.masterPassword {
            #if !targetEnvironment(simulator)
            try resetMasterPasswordService.update(masterPassword: newMasterPassword)
            #endif
        }
        syncService.lastSync = syncTimestamp
    }
}

extension CoreSession.MasterKey {
    var keyChainMasterKey: CoreKeychain.MasterKey {
        switch self {
        case .masterPassword(let password, _):
            return .masterPassword(password)
        case .ssoKey(let data):
            return .key(data)
        }
    }
}
