import CoreTypes
import Foundation

extension SharingEngine {
  public func deleteBehaviour(forItemId id: Identifier) throws -> ItemDeleteBehaviour {
    guard let itemGroup = try operationDatabase.fetchItemGroup(withItemId: id) else {
      return .normal
    }

    if !itemGroup.collectionMembers.isEmpty {
      return .cannotDeleteItemInCollection
    }

    for userGroup in itemGroup.userGroupMembers where userGroup.status == .accepted {
      guard
        let userGroupPair = try operationDatabase.fetchUserGroupUserPair(
          withGroupId: userGroup.id, userId: userId), userGroupPair.user.status == .accepted
      else {
        continue
      }

      return .cannotDeleteUserInvolvedInUserGroup
    }

    let adminUsers = itemGroup.users.filter { $0.permission == .admin && $0.status == .accepted }

    if adminUsers.count == 1,
      adminUsers.first?.id == userId,
      itemGroup.users.count > 1
    {
      return .cannotDeleteWhenNoOtherAdmin
    }

    return .canDeleteByLeavingItemGroup
  }
}
