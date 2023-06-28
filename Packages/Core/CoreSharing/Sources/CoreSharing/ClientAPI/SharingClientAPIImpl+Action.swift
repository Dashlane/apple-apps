import Foundation
import DashTypes
import DashlaneAPI

public extension SharingClientAPIImpl {
        fileprivate func catchInvalid<Response>(forId id: Identifier, _ action: () async throws -> Response) async throws -> Response {
        do {
            return try await action()
        } catch let error as DashlaneAPI.APIError where error.hasSharingUserdeviceCode(.invalidItemGroupRevision) {
            throw SharingInvalidActionError(id: id, type: .itemGroup)
        } catch let error as DashlaneAPI.APIError where error.hasSharingUserdeviceCode(.invalidItemTimestamp) {
            throw SharingInvalidActionError(id: id, type: .item)
        } catch let error as DashlaneAPI.APIError where error.hasSharingUserdeviceCode(.invalidUserGroupRevision) {
            throw SharingInvalidActionError(id: id, type: .userGroup)
        }
    }
}

public extension SharingClientAPIImpl {
    func acceptItemGroup(withId groupId: Identifier,
                         userGroupId: Identifier?,
                         acceptSignature: String,
                         autoAccept: Bool?,
                         emailsInfo: [EmailInfo],
                         userAuditLogDetails: AuditLogDetails?,
                         revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.acceptItemGroup(revision: revision,
                                                groupId: groupId.rawValue,
                                                acceptSignature: acceptSignature,
                                                auditLogDetails: userAuditLogDetails,
                                                autoAccept: autoAccept,
                                                itemsForEmailing: emailsInfo,
                                                userGroupId: userGroupId?.rawValue)
        }.parsed()
    }

    func refuseItemGroup(withId groupId: Identifier,
                         userGroupId: Identifier?,
                         emailsInfo: [EmailInfo],
                         userAuditLogDetails: AuditLogDetails?,
                         revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.refuseItemGroup(revision: revision,
                                                groupId: groupId.rawValue,
                                                auditLogDetails: userAuditLogDetails,
                                                itemsForEmailing: emailsInfo,
                                                userGroupId: userGroupId?.rawValue)
        }.parsed()
    }

    func createItemGroup(withId groupId: Identifier,
                         items: [ItemUpload],
                         users: [UserUpload],
                         userGroups: [UserGroupInvite]?,
                         emailsInfo: [EmailInfo],
                         userAuditLogDetails: AuditLogDetails?) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.createItemGroup(groupId: groupId.rawValue,
                                                users: users,
                                                items: items,
                                                auditLogDetails: userAuditLogDetails,
                                                groups: userGroups,
                                                itemsForEmailing: emailsInfo)
        }.parsed()
    }

    func deleteItemGroup(withId groupId: Identifier, revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.deleteItemGroup(groupId: groupId.rawValue, revision: revision)
        }.parsed()
    }

    func updateOnItemGroup(withId groupId: Identifier,
                           users: [UserUpdate]?,
                           userGroups: [UserGroupUpdate]?,
                           userAuditLogDetails: AuditLogDetails?,
                           revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.updateItemGroupMembers(revision: revision,
                                                       groupId: groupId.rawValue,
                                                       groups: userGroups,
                                                       users: users)
        }.parsed()
    }

    func inviteOnItemGroup(withId groupId: Identifier,
                           users: [UserInvite]?,
                           userGroups: [UserGroupInvite]?,
                           emailsInfo: [EmailInfo],
                           userAuditLogDetails: AuditLogDetails?,
                           revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.inviteItemGroupMembers(revision: revision,
                                                       groupId: groupId.rawValue,
                                                       auditLogDetails: userAuditLogDetails,
                                                       groups: userGroups,
                                                       itemsForEmailing: emailsInfo,
                                                       users: users)
        }.parsed()
    }

    func revokeOnItemGroup(withId groupId: Identifier,
                           userIds: [UserId]?,
                           userGroupIds: [Identifier]?,
                           userAuditLogDetails: AuditLogDetails?,
                           origin: UserDeviceAPIClient.SharingUserdevice.RevokeItemGroupMembers.Origin,
                           revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.revokeItemGroupMembers(revision: revision,
                                                       groupId: groupId.rawValue,
                                                       auditLogDetails: userAuditLogDetails,
                                                       groups: userGroupIds?.map(\.rawValue),
                                                       origin: origin,
                                                       users: userIds)
        }.parsed()
    }
}

public extension SharingClientAPIImpl {
    func updateItem(with itemId: Identifier, encryptedContent: String, timestamp: SharingTimestamp)  async throws -> ParsedServerResponse {
        try await catchInvalid(forId: itemId) {
            try await apiClient.updateItem(itemId: itemId.rawValue,
                                           content: encryptedContent,
                                           timestamp: timestamp)
        }.parsed()
    }
}

public extension SharingClientAPIImpl {
    func acceptUserGroup(withId groupId: Identifier,
                         acceptSignature: String,
                         revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.acceptUserGroup(provisioningMethod: .user,
                                                revision: revision,
                                                groupId: groupId.rawValue,
                                                acceptSignature: acceptSignature)
        }.parsed()
    }

    func refuseUserGroup(withId groupId: Identifier, revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.refuseUserGroup(provisioningMethod: .user,
                                                revision: revision,
                                                groupId: groupId.rawValue)
        }.parsed()
    }

    func updateOnUserGroup(withId groupId: Identifier,
                           users: [UserUpdate],
                           revision: SharingRevision) async throws -> ParsedServerResponse {
        try await catchInvalid(forId: groupId) {
            try await apiClient.updateUserGroupUsers(revision: revision,
                                                     groupId: groupId.rawValue,
                                                     users: users)
        }.parsed()
    }
}

public extension SharingClientAPIImpl {
    func resendInvite(to users: [UserInviteResend],
                      forGroupId groupId: Identifier,
                      emailsInfo: [EmailInfo],
                      revision: SharingRevision) async throws {
        try await catchInvalid(forId: groupId) {
            _ = try await apiClient.resendItemGroupInvites(revision: revision,
                                                               groupId: groupId.rawValue,
                                                               users: users,
                                                               itemsForEmailing: emailsInfo)
        }
    }
}
