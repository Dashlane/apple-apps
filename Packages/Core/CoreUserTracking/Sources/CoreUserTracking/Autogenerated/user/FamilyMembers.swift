import Foundation

extension UserEvent {

public struct `FamilyMembers`: Encodable, UserEventProtocol {
public static let isPriority = true
public init(`dashboardAction`: Definition.DashboardAction) {
self.dashboardAction = dashboardAction
}
public let dashboardAction: Definition.DashboardAction
public let name = "family_members"
}
}
