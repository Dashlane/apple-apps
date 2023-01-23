import Foundation
import DashTypes
import CyrilKit
import DashlaneAPI

extension SharingUpdater {
                    func autoAcceptUserGroupsAndSendKeyToNewUsers(in groups: [ItemGroup], nextRequest: inout UpdateRequest) async throws {
        for group in groups {
            do {
                try await sendGroupKeyAndSignatureForUsersIfNeeded(in: group, nextRequest: &nextRequest)
                try await autoAcceptUserGroupIfNeeded(in: group, nextRequest: &nextRequest)
            } catch let error as SharingInvalidActionError {
                nextRequest += UpdateRequest(error: error)
                logger.error("item group not up to date")
            } catch {
                logger.error("updating item group failed", error: error)
            }
        }
    }
    
                    func sendKeyToNewUsers(in groups: [UserGroup], nextRequest: inout UpdateRequest) async throws {
        for group in groups {
            do {
                try await sendGroupKeyAndSignatureForUsersIfNeeded(in: group, nextRequest: &nextRequest)
            } catch let error as SharingInvalidActionError {
                nextRequest += UpdateRequest(error: error)
                logger.error("user group not up to date")
            } catch {
                logger.error("updating user group failed", error: error)
            }
        }
    }
}

extension SharingUpdater {
                                private func sendGroupKeyAndSignatureForUsersIfNeeded(in group: ItemGroup, nextRequest: inout UpdateRequest) async throws {
        let users = group.users.filter { $0.needKeyUpdate }
        
        guard !users.isEmpty,
              let groupKey = try? groupKeyProvider.groupKey(for: group) else {
            return
        }
        
        let userUpdates = try await makeUserUpdates(users: users, groupKey: groupKey)
        
        nextRequest += try await sharingClientAPI.updateOnItemGroup(withId: group.id,
                                                                    users: userUpdates,
                                                                    userGroups: nil,
                                                                    revision: group.info.revision)
    }
    
                                private func sendGroupKeyAndSignatureForUsersIfNeeded(in group: UserGroup, nextRequest: inout UpdateRequest) async throws {
        let users = group.users.filter { $0.needKeyUpdate }
        
        guard !users.isEmpty,
              let groupKey = try? groupKeyProvider.groupKey(for: group) else {
            return
        }
        
        let userUpdates = try await makeUserUpdates(users: users, groupKey: groupKey)
        
        nextRequest += try await sharingClientAPI.updateOnUserGroup(withId: group.id,
                                                                    users: userUpdates,
                                                                    revision: group.info.revision)
    }
    
    private func makeUserUpdates(users: [User], groupKey: SymmetricKey) async throws -> [UserUpdate] {
        let userPublicKeys = try await sharingClientAPI.findPublicKeys(for: users.map(\.id))
        let signatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)

        return try users.compactMap { user -> UserUpdate? in
           guard let publicKey = userPublicKeys[user.id] else {
               return nil
           }
           
           let groupKey = try cryptoProvider.encrypt(groupKey, withPublicPemString: publicKey)
           let signature = try user.createProposeSignature(using: signatureProducer)
           
            return UserUpdate(userId: user.id,
                              groupKey: groupKey,
                              permission: nil,
                              proposeSignature: signature)
       }
    }
}

    
 
extension SharingUpdater {
                            private func autoAcceptUserGroupIfNeeded(in group: ItemGroup, nextRequest: inout UpdateRequest) async throws {
        guard !group.userGroupMembers.isEmpty,
              let groupKey = try? groupKeyProvider.groupKey(for: group) else {
            return
        }
        
     
        for userGroupMember in group.userGroupMembers {
            guard userGroupMember.status == .pending,
                  let keys = try groupKeyProvider.keys(for: userGroupMember) else {
                continue
            }
            
            let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(EmailInfo.init)
            let signer = cryptoProvider.acceptMessageSigner(using: keys.privateKey)
            let acceptSignature = try userGroupMember.createAcceptSignature(using: signer, groupKey: groupKey)
            
            nextRequest += try await sharingClientAPI.acceptItemGroup(withId: group.id,
                                                                      userGroupId: userGroupMember.id,
                                                                      acceptSignature: acceptSignature,
                                                                      autoAccept: true,
                                                                      emailsInfo: emailsInfo,
                                                                      revision: group.info.revision)
        }
    }
}

fileprivate extension User {
        var needKeyUpdate: Bool {
        return rsaStatus == .publicKey
    }
}



