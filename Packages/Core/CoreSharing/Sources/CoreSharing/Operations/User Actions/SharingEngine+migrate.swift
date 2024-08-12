import DashTypes
import Foundation

extension SharingEngine {
  public func shareAllTeamItemsIfAdmin(to destinationUserId: UserId, sharedInSpaceIds: [Identifier])
    async throws -> [ItemGroup]
  {
    let itemGroups = try operationDatabase.fetchAllItemGroups().filter { itemGroup in
      itemGroup.user(with: userId)?.permission == .admin
        && itemGroup.user(with: destinationUserId) == nil
        && (!itemGroup.userGroupMembers.isEmpty
          || itemGroup.itemKeyPairs.contains {
            sharedInSpaceIds.contains($0.id)
          })
    }

    try await self.shareItems(
      withIds: itemGroups.flatMap(\.itemKeyPairs).map(\.id), recipients: [destinationUserId],
      userGroupIds: [], permission: .admin, limitPerUser: nil,
      makeActivityLogDetails: { _ in
        return nil
      })

    return itemGroups
  }

  public func acceptItemGroups(withIds ids: [Identifier]) async throws {
    for id in ids {
      guard let group = try operationDatabase.fetchItemGroup(withId: id) else {
        throw SharingUpdaterError.unknownSharedItem
      }

      try await accept(group.info, userAuditLogDetails: nil)
    }
  }
}
