import DashTypes
import DashlaneAPI
import Foundation

extension SharingEngine {
  public func forceRevokeItemGroup(withItemIds ids: [Identifier]) async throws {
    for id in ids {
      guard let itemGroup = try operationDatabase.fetchItemGroup(withItemId: id) else {
        continue
      }

      let itemState = try operationDatabase.sharingMembers(forUserId: userId, in: itemGroup)
        .computeItemState()
      switch itemState?.permission {
      case .admin:
        let adminUsers = itemGroup.users.filter { $0.id != userId && $0.permission == .admin }
        let adminGroups = itemGroup.userGroupMembers.filter { $0.permission == .admin }
        let hasOtherAdmin = !adminUsers.isEmpty || !adminGroups.isEmpty
        if hasOtherAdmin {
          try await personalDataDB.reCreateAcceptedItem(with: id)
          try await self.refuse(itemGroup.info)
        } else {
          let usersToRevoke = itemGroup.users.filter { $0.id != userId }
          let userGroupsToRevoke = itemGroup.userGroupMembers

          try await revoke(
            in: itemGroup.info,
            users: usersToRevoke,
            userGroupMembers: userGroupsToRevoke,
            userAuditLogDetails: nil)

        }

      case .limited:
        try await self.refuse(itemGroup.info)
      default: break

      }
    }
  }
}
