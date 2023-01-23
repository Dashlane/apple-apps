import Foundation
import DashTypes

public protocol SharingUIDatabase {
    associatedtype ItemSharingSequence: AsyncSequence where ItemSharingSequence.Element == ItemSharingMembers?
    associatedtype SharingItemsUserGroupSequence: AsyncSequence where SharingItemsUserGroupSequence.Element == [SharingItemsUserGroup]
    associatedtype SharingItemsUserSequence: AsyncSequence where SharingItemsUserSequence.Element == [SharingItemsUser]
    associatedtype PendingItemGroupsSequence: AsyncSequence where PendingItemGroupsSequence.Element == [PendingItemGroup]
    associatedtype PendingUserGroupsSequence: AsyncSequence where PendingUserGroupsSequence.Element == [PendingUserGroup]

        func sharingMembers(forItemId id: Identifier) -> ItemSharingSequence
        func sharingUserGroups(for userId: UserId) -> SharingItemsUserGroupSequence
        func sharingUsers(for userId: UserId) -> SharingItemsUserSequence
        func pendingItemGroups(for userId: UserId) -> PendingItemGroupsSequence
        func pendingUserGroups(for userId: UserId) -> PendingUserGroupsSequence
}

public typealias UserId = String

public struct ItemSharingMembers: Decodable, Identifiable {
    public let itemGroupInfo: ItemGroupInfo
    public let users: [User]
    public let userGroupMembers: [UserGroupMember]
    
    public var id: Identifier {
        return itemGroupInfo.id
    }
    
    public init(itemGroupInfo: ItemGroupInfo, users: [User], userGroupMembers: [UserGroupMember]) {
        self.itemGroupInfo = itemGroupInfo
        self.users = users
        self.userGroupMembers = userGroupMembers
    }
}

public struct SharedItemInfo<Recipient: SharingGroupMember>: Identifiable {
    public let id: Identifier
    public let group: ItemGroupInfo
    public let recipient: Recipient

    public init(id: Identifier,
                group: ItemGroupInfo,
                recipient: Recipient) {
        self.id = id
        self.group = group
        self.recipient = recipient
    }
}

extension SharedItemInfo: Equatable where Recipient: Equatable { }
extension SharedItemInfo: Hashable where Recipient: Hashable { }

public struct SharingItemsUserGroup: Identifiable, Hashable {
    public let id: Identifier
    public let name: String
    public let isMember: Bool
    public var items: [SharedItemInfo<UserGroupMember>] = []
    public let users: [User]

    public init(id: Identifier,
                name: String,
                isMember: Bool,
                items: [SharedItemInfo<UserGroupMember>] = [],
                users: [User]) {
        self.id = id
        self.name = name
        self.isMember = isMember
        self.items = items
        self.users = users
    }
}

public struct SharingItemsUser: Identifiable, Hashable {
    public let id:  UserId
    public var items: [SharedItemInfo<User>] = []
    
    public init(id: UserId, items: [SharedItemInfo<User>] = []) {
        self.id = id
        self.items = items
    }
}

public struct PendingUserGroup: Identifiable {
    public enum CodingKeys: String, CodingKey {
        case userGroupInfo
        case referrer
    }

    public let userGroupInfo: UserGroupInfo
    public let referrer: String?

    public var id: Identifier {
        return userGroupInfo.id
    }

    public init(userGroupInfo: UserGroupInfo, referrer: String) {
        self.userGroupInfo = userGroupInfo
        self.referrer = referrer
    }
}
public struct PendingItemGroup: Identifiable {
    public enum CodingKeys: String, CodingKey {
        case itemGroupInfo
        case itemIds
        case referrer
    }
    
    public let itemGroupInfo: ItemGroupInfo
    public let itemIds: Set<Identifier>
    public let referrer: String?
    
    public var id: Identifier {
        return itemGroupInfo.id
    }
    
    public init(itemGroupInfo: ItemGroupInfo, itemIds: Set<Identifier>, referrer: String) {
        self.itemGroupInfo = itemGroupInfo
        self.itemIds = itemIds
        self.referrer = referrer
    }
}

