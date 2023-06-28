import Foundation
import DashTypes
import DashlaneAPI

public extension SharingEngine {
    func revoke(in group: ItemGroupInfo, users: [User]?, userGroupMembers: [UserGroupMember]?, userAuditLogDetails: AuditLogDetails?) async throws {
        try await execute { updateRequest in
            guard let group = try operationDatabase.fetchItemGroup(withId: group.id), (users?.isEmpty == false || userGroupMembers?.isEmpty == false) else {
                return
            }

            updateRequest += try await sharingClientAPI.revokeOnItemGroup(withId: group.id,
                                                                          userIds: users?.map(\.id),
                                                                          userGroupIds: userGroupMembers?.map(\.id),
                                                                          userAuditLogDetails: userAuditLogDetails,
                                                                          origin: .manual,
                                                                          revision: group.info.revision)
        }
    }
}

public extension SharingEngine {
    func updatePermission(_ permission: SharingPermission, of user: User, in group: ItemGroupInfo, userAuditLogDetails: AuditLogDetails?)  async throws {
        try await execute { updateRequest in
            guard let group = try operationDatabase.fetchItemGroup(withId: group.id) else {
                return
            }

            let update = UserUpdate(userId: user.id,
                                    groupKey: nil,
                                    permission: .init(permission),
                                    proposeSignature: nil)
            updateRequest += try await sharingClientAPI.updateOnItemGroup(withId: group.id,
                                                                          users: [update],
                                                                          userGroups: nil,
                                                                          userAuditLogDetails: userAuditLogDetails,
                                                                          revision: group.info.revision)
        }
    }

    func updatePermission(_ permission: SharingPermission, of userGroupMember: UserGroupMember, in group: ItemGroupInfo, userAuditLogDetails: AuditLogDetails?) async throws {
        try await execute { updateRequest in
            guard let group = try operationDatabase.fetchItemGroup(withId: group.id) else {
                return
            }

            let update = UserGroupUpdate(groupId: userGroupMember.id.rawValue, permission: .init(permission))
            updateRequest += try await sharingClientAPI.updateOnItemGroup(withId: group.id,
                                                                          users: nil,
                                                                          userGroups: [update],
                                                                          userAuditLogDetails: userAuditLogDetails,
                                                                          revision: group.info.revision)
        }

    }
}

public extension SharingEngine {
    func resendInvites(to users: [User], in group: ItemGroupInfo) async throws {
        try await execute { _ in
            guard let group = try operationDatabase.fetchItemGroup(withId: group.id) else {
                return
            }

            let emailsInfo = try await personalDataDB.metadata(for: group.itemKeyPairs.map(\.id)).map(EmailInfo.init)

            try await sharingClientAPI.resendInvite(to: users.map { UserInviteResend(userId: $0.id, alias: $0.id) },
                                                                     forGroupId: group.id,
                                                                     emailsInfo: emailsInfo,
                                                                     revision: group.info.revision)
        }
    }
}
