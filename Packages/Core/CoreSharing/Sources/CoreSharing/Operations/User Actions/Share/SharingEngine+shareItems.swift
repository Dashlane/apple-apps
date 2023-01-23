import Foundation
import DashTypes
import CyrilKit
import DashlaneAPI

extension SharingEngine {
    
                                                    @SharingActor
    public func shareItems(withIds ids: [Identifier],
                           recipients: [String],
                           userGroupIds: [Identifier],
                           permission: SharingPermission,
                           limitPerUser: Int?) async throws {
        try await execute { updateRequest in

            let recipients = recipients.map { $0.sanitizedRecipients() }

            let existingItemGroups = try operationDatabase.fetchItemGroups(withItemIds: ids)
            var ids = Set(ids)
            let userPublicKeys = try await sharingClientAPI.findPublicKeys(for: recipients)

                        if let limitPerUser = limitPerUser {
                try checkLimitPerUser(limitPerUser,
                                      forRecipients: recipients,
                                      existingItemGroupIds: existingItemGroups.map(\.id),
                                      totalNumberOfSharedItems: ids.count)
            }
            
                        for group in existingItemGroups {
                ids.subtract(group.itemKeyPairs.map(\.id))
                try await add(into: group,
                              recipients: recipients,
                              userGroupIds: userGroupIds,
                              permission: permission,
                              userPublicKeys: userPublicKeys,
                              updateRequest: &updateRequest)
            }
            
                        let contents = try await personalDataDB.createSharingContents(for: Array(ids))
            for content in contents {
                try await createSharing(for: content,
                                        recipients: recipients,
                                        userGroupIds: userGroupIds,
                                        permission: permission,
                                        userPublicKeys: userPublicKeys,
                                        updateRequest: &updateRequest)
            }
        }
    }

                func checkLimitPerUser(_ limitPerUser: Int,
                           forRecipients recipients: [String],
                           existingItemGroupIds: [Identifier],
                           totalNumberOfSharedItems: Int) throws {
        let counts = try operationDatabase
            .sharingCounts(forUserIds: recipients, excludingGroupIds: existingItemGroupIds) 
        if counts.values.contains(where: { $0 + totalNumberOfSharedItems > limitPerUser }) {
            throw SharingUpdaterError.sharingLimitReached
        }
    }
}

extension SharingEngine {
    @SharingActor
    private func makeInviteBuilder(groupId: Identifier, groupKey: SymmetricKey, permission: SharingPermission, userPublicKeys: [UserId : RawPublicKey]) -> InviteBuilder {
        InviteBuilder(groupId: groupId,
                      permission: permission,
                      groupKey: groupKey,
                      cryptoProvider: cryptoProvider,
                      groupKeyProvider: groupKeyProvider,
                      database: operationDatabase,
                      userPublicKeys: userPublicKeys)
    }
    
                @SharingActor
    private func createSharing(for content: SharingCreateContent,
                               recipients: [String],
                               userGroupIds: [Identifier],
                               permission: SharingPermission,
                               userPublicKeys: [String : RawPublicKey],
                               updateRequest: inout SharingUpdater.UpdateRequest) async throws {
        let groupKey = cryptoProvider.makeSymmetricKey()
        let itemKey = cryptoProvider.makeSymmetricKey()
        let groupId = Identifier()
                let encryptedItemKey = try itemKey.encrypt(using: cryptoProvider.cryptoEngine(using: groupKey))
        let encryptedContent = try content.transactionContent.encrypt(using: cryptoProvider.cryptoEngine(using: itemKey))
        
        let itemUpload = ItemUpload(id: content.id,
                                    encryptedContent: encryptedContent,
                                    type: content.metadata.type,
                                    encryptedKey: encryptedItemKey)
        
                let inviteBuilder = makeInviteBuilder(groupId: groupId, groupKey: groupKey, permission: permission, userPublicKeys: userPublicKeys)
        
        let author = try inviteBuilder.makeAuthorUpload(userId: userId, userKeyPair: try userKeyStore.get())
        let users = try inviteBuilder.makeUserUploads(recipients: recipients)
        let userGroupInvites = try inviteBuilder.makeUserGroupInvites(userGroupIds: userGroupIds)
        
                var updateRequestFromCreation = try await sharingClientAPI.createItemGroup(withId: groupId,
                                                                                   items: [itemUpload],
                                                                                   users: [author] + users,
                                                                                   userGroups: userGroupInvites.isEmpty ? nil : userGroupInvites,
                                                                                   emailsInfo: [EmailInfo(content.metadata)])
        
                try operationDatabase.save(updateRequestFromCreation.items)
        updateRequestFromCreation.items = []
        
                updateRequest += updateRequestFromCreation
    }
    
                    @SharingActor
    private func add(into group: ItemGroup,
                     recipients: [String],
                     userGroupIds: [Identifier],
                     permission: SharingPermission,
                     userPublicKeys: [UserId : RawPublicKey],
                     updateRequest: inout SharingUpdater.UpdateRequest) async throws {
        guard let groupKey = try groupKeyProvider.groupKey(for: group) else {
            return
        }
        
        let inviteBuilder = makeInviteBuilder(groupId: group.id, groupKey: groupKey, permission: permission, userPublicKeys: userPublicKeys)
        
                let existingUserIds = Set(group.users.map(\.id))
        let existingUserGroupId = Set(group.userGroupMembers.map(\.id))
        
        let users = try inviteBuilder.makeUserInvites(recipients: recipients)
            .filter { !existingUserIds.contains($0.userId) }
        
        let userGroupIds = Set(userGroupIds).subtracting(existingUserGroupId)
        let userGroupInvites = try inviteBuilder.makeUserGroupInvites(userGroupIds: Array(userGroupIds))
        
                guard !users.isEmpty || !userGroupInvites.isEmpty else {
            return
        }
        
        let emailInfos = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(EmailInfo.init)
        
        updateRequest += try await sharingClientAPI.inviteOnItemGroup(withId: group.id,
                                                                      users: users,
                                                                      userGroups: userGroupInvites.isEmpty ? nil : userGroupInvites,
                                                                      emailsInfo: emailInfos,
                                                                      revision: group.info.revision)
    }
}

extension ItemUpload {
    init(id: Identifier, encryptedContent: Data, type: SharingType, encryptedKey: Data) {
        self.init(itemId: id.rawValue,
                  itemKey: encryptedKey.base64EncodedString(),
                  content: encryptedContent.base64EncodedString(),
                  itemType: ItemType(type))
    }
}

extension ItemUpload.ItemType {
    public init(_ type: SharingType) {
        switch type {
        case .password:
            self = .authentifiant
        case .note:
            self = .securenote
        }
    }
}

extension UserUpload {
    init(userInvite: UserInvite) {
        self.init(userId: userInvite.userId,
                  alias: userInvite.alias,
                  permission: userInvite.permission,
                  proposeSignature: userInvite.proposeSignature,
                  acceptSignature: nil,
                  groupKey: userInvite.groupKey,
                  proposeSignatureUsingAlias: userInvite.proposeSignatureUsingAlias)
    }
}

fileprivate extension String {
                func sanitizedRecipients() -> String {
        self.lowercased()
            .trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
