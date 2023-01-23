import Foundation
import CoreKeychain
import CoreSession
import SwiftTreats


extension UnlockSessionHandler {
    public func validateMasterKey(_ masterKey: CoreSession.MasterKey) async throws {
        try await unlock(with: masterKey, loginContext: LoginContext(origin: .mobile))
    }

    public func validateMasterKey(_ masterKey: CoreKeychain.MasterKey) async throws {
        switch masterKey {
        case .masterPassword(let masterPassword):
            try await validateMasterKey(.masterPassword(masterPassword, serverKey: nil))
        case .key(let key):
            try await validateMasterKey(.ssoKey(key))
        }
    }
}
