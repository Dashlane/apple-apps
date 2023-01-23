import Foundation
import SwiftTreats

public protocol UnlockSessionHandler {
    func unlock(with masterKey: MasterKey, loginContext: LoginContext) async throws
}
