import Foundation

extension UserEvent {

public struct `ShareItem`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`groupsCount`: Int, `individualsCount`: Int, `itemType`: Definition.SharingItemType, `requestStatus`: Definition.RequestStatus, `rights`: Definition.Rights) {
self.groupsCount = groupsCount
self.individualsCount = individualsCount
self.itemType = itemType
self.requestStatus = requestStatus
self.rights = rights
}
public let groupsCount: Int
public let individualsCount: Int
public let itemType: Definition.SharingItemType
public let name = "share_item"
public let requestStatus: Definition.RequestStatus
public let rights: Definition.Rights
}
}
