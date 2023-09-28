import Foundation
import DashTypes
import DashlaneAPI

public extension SharingEngine {
    func accept(_ itemGroupInfo: ItemGroupInfo, userAuditLogDetails: AuditLogDetails?) async throws {
        try await execute { updateRequest in
            guard let group = try operationDatabase.fetchItemGroup(withId: itemGroupInfo.id),
                  let user = group.user(with: userId),
                  user.status == .pending,
                  let groupKey = try groupKeyProvider.groupKey(for: group) else {
                return
            }

            let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(EmailInfo.init)
            let signer = cryptoProvider.acceptMessageSigner(using: try userKeyStore.get().privateKey)
            let acceptSignature = try user.createAcceptSignature(using: signer, groupKey: groupKey)

            updateRequest += try await sharingClientAPI.acceptItemGroup(withId: group.id,
                                                                        userGroupId: nil,
                                                                        acceptSignature: acceptSignature,
                                                                        autoAccept: false,
                                                                        emailsInfo: emailsInfo,
                                                                        userAuditLogDetails: userAuditLogDetails,
                                                                        revision: group.info.revision)
        }
    }

    func refuse(_ itemGroupInfo: ItemGroupInfo, userAuditLogDetails: AuditLogDetails? = nil) async throws {
        guard let group = try operationDatabase.fetchItemGroup(withId: itemGroupInfo.id) else {
            return
        }

        try await refuse(group, userAuditLogDetails: userAuditLogDetails)
    }

    private func refuse(_ group: ItemGroup, userAuditLogDetails: AuditLogDetails?) async throws {
        try await execute { updateRequest in
            let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(EmailInfo.init)

            updateRequest += try await sharingClientAPI.refuseItemGroup(withId: group.id,
                                                                        userGroupId: nil,
                                                                        emailsInfo: emailsInfo,
                                                                        userAuditLogDetails: userAuditLogDetails,
                                                                        revision: group.info.revision)
        }
    }

    func refuseItem(with id: Identifier, userAuditLogDetails: AuditLogDetails?) async throws {
        guard let itemGroup = try operationDatabase.fetchItemGroup(withItemId: id) else {
            return
        }

        try await refuse(itemGroup, userAuditLogDetails: userAuditLogDetails)
    }
}

public extension SharingEngine {
    func accept(_ groupInfo: UserGroupInfo) async throws {
        try await execute { updateRequest in
            guard let group = try operationDatabase.fetchUserGroup(withId: groupInfo.id),
                  let user = group.user(with: userId),
                  user.status == .pending,
                  let groupKey = try groupKeyProvider.groupKey(for: group) else {
                return
            }

            let signer = cryptoProvider.acceptMessageSigner(using: try userKeyStore.get().privateKey)
            let acceptSignature = try user.createAcceptSignature(using: signer, groupKey: groupKey)

            updateRequest += try await sharingClientAPI.acceptUserGroup(withId: group.id,
                                                                        acceptSignature: acceptSignature,
                                                                        revision: group.info.revision)
        }
    }

    func refuse(_ groupInfo: UserGroupInfo) async throws {
        try await execute { updateRequest in
            guard let group = try operationDatabase.fetchUserGroup(withId: groupInfo.id) else {
                return
            }

            updateRequest += try await sharingClientAPI.refuseUserGroup(withId: group.id, revision: group.info.revision)
        }
    }
}
