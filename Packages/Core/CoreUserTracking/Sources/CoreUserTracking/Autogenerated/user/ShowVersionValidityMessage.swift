import Foundation

extension UserEvent {

public struct `ShowVersionValidityMessage`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`isUpdatePossible`: Bool, `versionValidityStatus`: Definition.VersionValidityStatus) {
self.isUpdatePossible = isUpdatePossible
self.versionValidityStatus = versionValidityStatus
}
public let isUpdatePossible: Bool
public let name = "show_version_validity_message"
public let versionValidityStatus: Definition.VersionValidityStatus
}
}
