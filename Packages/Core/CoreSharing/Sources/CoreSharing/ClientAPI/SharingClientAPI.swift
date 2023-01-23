import Foundation
import DashTypes
import DashlaneAPI

public protocol SharingClientAPI {
            func fetch(_ request: FetchRequest) async throws -> ParsedServerResponse
        func findPublicKeys(for userIds: [UserId]) async throws -> [UserId: RawPublicKey]
    
        func acceptItemGroup(withId groupId: Identifier,
                         userGroupId: Identifier?,
                         acceptSignature: String,
                         autoAccept: Bool?,
                         emailsInfo: [EmailInfo],
                         revision: SharingRevision) async throws -> ParsedServerResponse
    
    func refuseItemGroup(withId groupId: Identifier,
                         userGroupId: Identifier?,
                         emailsInfo: [EmailInfo],
                         revision: SharingRevision) async throws -> ParsedServerResponse
    
    func createItemGroup(withId groupId: Identifier,
                         items: [ItemUpload],
                         users: [UserUpload],
                         userGroups: [UserGroupInvite]?,
                         emailsInfo: [EmailInfo]) async throws -> ParsedServerResponse
    
    func deleteItemGroup(withId groupId: Identifier, revision: Int) async throws -> ParsedServerResponse

    func updateOnItemGroup(withId groupId: Identifier,
                           users: [UserUpdate]?,
                           userGroups: [UserGroupUpdate]?,
                           revision: SharingRevision) async throws -> ParsedServerResponse
    func inviteOnItemGroup(withId groupId: Identifier,
                           users: [UserInvite]?,
                           userGroups: [UserGroupInvite]?,
                           emailsInfo: [EmailInfo],
                           revision: SharingRevision) async throws -> ParsedServerResponse
    func revokeOnItemGroup(withId groupId: Identifier,
                           userIds: [UserId]?,
                           userGroupIds: [Identifier]?,
                           revision: SharingRevision) async throws -> ParsedServerResponse
    
                    func updateItem(with itemId: Identifier, encryptedContent: String, timestamp: SharingTimestamp) async throws -> ParsedServerResponse
    
        func acceptUserGroup(withId groupId: Identifier,
                         acceptSignature: String,
                         revision: SharingRevision) async throws -> ParsedServerResponse
    
    func refuseUserGroup(withId groupId: Identifier, revision: SharingRevision) async throws -> ParsedServerResponse
    
    func resendInvite(to users: [UserInviteResend],
                      forGroupId groupId: Identifier,
                      emailsInfo: [EmailInfo],
                      revision: SharingRevision)  async throws
    
    func updateOnUserGroup(withId groupId: Identifier,
                           users: [UserUpdate],
                           revision: SharingRevision) async throws -> ParsedServerResponse
}

public struct FetchRequest: Equatable {
    static let sliceSize = 100
    
    var itemGroupIds: [[Identifier]]
    var itemIds: [[Identifier]]
    var userGroupIds: [[Identifier]]
    var isEmpty: Bool {
        return itemGroupIds.isEmpty && itemIds.isEmpty && userGroupIds.isEmpty
    }
    
    public init(itemGroupIds: [Identifier], itemIds: [Identifier], userGroupIds: [Identifier]) {
        self.itemGroupIds = itemGroupIds.chunked(into: FetchRequest.sliceSize)
        self.itemIds = itemIds.chunked(into: FetchRequest.sliceSize)
        self.userGroupIds = userGroupIds.chunked(into: FetchRequest.sliceSize)
    }
}

public typealias RawPublicKey = String

public struct SharingInvalidActionError: Error {
    public enum InvalidType {
        case item
        case itemGroup
        case userGroup
    }

    let id: Identifier
    let `type`: InvalidType
}
