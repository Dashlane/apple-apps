import Foundation

extension UserEvent {

public struct `DeleteAccountRecoveryKey`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`deleteKeyReason`: Definition.DeleteKeyReason) {
self.deleteKeyReason = deleteKeyReason
}
public let deleteKeyReason: Definition.DeleteKeyReason
public let name = "delete_account_recovery_key"
}
}
