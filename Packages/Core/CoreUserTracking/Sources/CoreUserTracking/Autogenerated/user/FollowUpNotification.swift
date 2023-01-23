import Foundation

extension UserEvent {

public struct `FollowUpNotification`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`action`: Definition.FollowUpNotificationActions, `itemType`: Definition.ItemType? = nil) {
self.action = action
self.itemType = itemType
}
public let action: Definition.FollowUpNotificationActions
public let itemType: Definition.ItemType?
public let name = "follow_up_notification"
}
}
