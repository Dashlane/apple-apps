import Foundation
import SwiftTreats

public protocol UnlockSessionHandler {
    func unlock(with masterKey: MasterKey, loginContext: LoginContext, isRecoveryLogin: Bool) async throws
}

public struct FakeUnlockSessionHandler: UnlockSessionHandler {
    public func unlock(with masterKey: MasterKey, loginContext: LoginContext, isRecoveryLogin: Bool) async throws {}
}

extension UnlockSessionHandler where Self == FakeUnlockSessionHandler {
     public static var mock: UnlockSessionHandler {
        FakeUnlockSessionHandler()
    }
}
