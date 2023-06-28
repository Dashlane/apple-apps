import Foundation

extension UserEvent {

public struct `CredentialHealthReport`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`credentialSecurityStatus`: Definition.CredentialSecurityStatus, `itemId`: String) {
self.credentialSecurityStatus = credentialSecurityStatus
self.itemId = itemId
}
public let credentialSecurityStatus: Definition.CredentialSecurityStatus
public let itemId: String
public let name = "credential_health_report"
}
}
