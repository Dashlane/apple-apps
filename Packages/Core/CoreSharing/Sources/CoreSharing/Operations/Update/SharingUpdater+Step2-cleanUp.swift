import Foundation
import DashTypes

extension SharingUpdater {
                    func deleteItemGroupsWithoutCurrentUser(from itemGroups: [ItemGroup]) async throws {
        let groupsToDelete = itemGroups.filter { group in
            guard let members = try? database.sharingMembers(forUserId: userId, in: group) else {
                return false
            }
            
           return !members.contains { $0.status.isAcceptedOrPending }
        }
        
        guard !groupsToDelete.isEmpty else {
            return
        }
        
        logger.debug("\(groupsToDelete.count) ItemGroup(s) cleaned that does not contain current user, items within the group(s) removed")
        try database.deleteItemGroups(withIds: groupsToDelete.map(\.id))
        let itemIds = groupsToDelete.flatMap { $0.itemKeyPairs.map(\.id) }
        try await personalDataDB.delete(with: itemIds)
        try database.deleteItemContentCaches(withIds: itemIds)
    }

                                func deleteItemGroupsWithCurrentUserAloneAdmin(from itemGroups: [ItemGroup], nextRequest: inout UpdateRequest) async throws {
        let groupsToDelete = itemGroups.filter { group in
            guard let user = group.user(with: userId),
                  user.status == .accepted,
                  user.permission ==  .admin,
                  group.users.filter({ $0.status.isAcceptedOrPending }).count == 1,
                  group.userGroupMembers.filter({ $0.status.isAcceptedOrPending }).isEmpty else {
                return false
            }
            return true
        }

        guard !groupsToDelete.isEmpty else {
            return
        }
        
        var successfullyDeletedIds: [Identifier] = []
        
        for group in groupsToDelete {
            do {
                let _ = try await sharingClientAPI.deleteItemGroup(withId: group.id, revision: group.info.revision)
                
                for item in group.itemKeyPairs {
                    try await personalDataDB.reCreateAcceptedItem(with: item.id)
                    try database.deleteItemContentCaches(withIds: [item.id])
                }
                
                successfullyDeletedIds.append(group.id)
                
            } catch let error as SharingInvalidActionError {
                nextRequest += UpdateRequest(error: error)
                logger.error("item group not up to date")
            } catch {
                logger.error("item group failed to be deleted", error: error)
            }
        }
        
        try database.deleteItemGroups(withIds: successfullyDeletedIds)
        logger.debug("\(successfullyDeletedIds.count) ItemGroup(s) cleaned that contain only current user, item(s) recreated on vault")
    }
}

