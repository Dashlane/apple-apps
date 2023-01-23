import Foundation

extension UserEvent {

public struct `RespondSharedItem`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`hasAccepted`: Bool, `itemType`: Definition.SharingItemType, `responseStatus`: Definition.ResponseStatus, `rights`: Definition.Rights) {
self.hasAccepted = hasAccepted
self.itemType = itemType
self.responseStatus = responseStatus
self.rights = rights
}
public let hasAccepted: Bool
public let itemType: Definition.SharingItemType
public let name = "respond_shared_item"
public let responseStatus: Definition.ResponseStatus
public let rights: Definition.Rights
}
}
