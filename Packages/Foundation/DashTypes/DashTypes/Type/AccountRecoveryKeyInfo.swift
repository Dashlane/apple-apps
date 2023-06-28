import Foundation

public struct AccountRecoveryKeyInfo {
    public var recoveryKey: String
    public var recoveryId: String

    public init(recoveryKey: String, recoveryId: String) {
        self.recoveryKey = recoveryKey
        self.recoveryId = recoveryId
    }
}
