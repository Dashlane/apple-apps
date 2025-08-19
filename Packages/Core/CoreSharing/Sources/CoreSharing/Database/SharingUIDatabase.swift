import CoreTypes
import Foundation

public protocol SharingUIDatabase {
  associatedtype ItemSharingSequence: AsyncSequence
  where ItemSharingSequence.Element == ItemSharingMembers?
  associatedtype CollectionSharingSequence: AsyncSequence
  where CollectionSharingSequence.Element == CollectionSharingMembers?
  associatedtype SharingEntitiesUserGroupSequence: AsyncSequence
  where SharingEntitiesUserGroupSequence.Element == [SharingEntitiesUserGroup]
  associatedtype SharingEntitiesUserSequence: AsyncSequence
  where SharingEntitiesUserSequence.Element == [SharingEntitiesUser]
  associatedtype SharingCollectionsSequence: AsyncSequence
  where SharingCollectionsSequence.Element == [SharedCollectionItems]
  associatedtype PendingItemGroupsSequence: AsyncSequence
  where PendingItemGroupsSequence.Element == [PendingItemGroup]
  associatedtype PendingCollectionsSequence: AsyncSequence
  where PendingCollectionsSequence.Element == [PendingCollection]
  associatedtype PendingUserGroupsSequence: AsyncSequence
  where PendingUserGroupsSequence.Element == [PendingUserGroup]

  func sharingMembers(forItemId id: Identifier) -> ItemSharingSequence
  func sharingMembers(forCollectionId id: Identifier) -> CollectionSharingSequence
  func sharingUserGroups(for userId: UserId) -> SharingEntitiesUserGroupSequence
  func sharingUsers(for userId: UserId) -> SharingEntitiesUserSequence
  func sharingCollections(for userId: UserId) -> SharingCollectionsSequence
  func pendingItemGroups(for userId: UserId) -> PendingItemGroupsSequence
  func pendingCollections(for userId: UserId) -> PendingCollectionsSequence
  func pendingUserGroups(for userId: UserId) -> PendingUserGroupsSequence
}

public typealias UserId = String

public struct ItemSharingMembers: Decodable, Identifiable {
  public let itemGroupInfo: ItemGroupInfo
  public let users: [User<ItemGroup>]
  public let userGroupMembers: [UserGroupMember<ItemGroup>]
  public let collectionMembers: [CollectionMember]

  public var id: Identifier {
    return itemGroupInfo.id
  }

  public init(
    itemGroupInfo: ItemGroupInfo,
    users: [User<ItemGroup>],
    userGroupMembers: [UserGroupMember<ItemGroup>],
    collectionMembers: [CollectionMember]
  ) {
    self.itemGroupInfo = itemGroupInfo
    self.users = users
    self.userGroupMembers = userGroupMembers
    self.collectionMembers = collectionMembers
  }
}

public struct CollectionSharingMembers: Decodable, Identifiable {
  public let collectionInfo: CollectionInfo
  public let users: [User<SharingCollection>]
  public let userGroupMembers: [UserGroupMember<SharingCollection>]

  public var id: Identifier {
    collectionInfo.id
  }

  public init(
    collectionInfo: CollectionInfo,
    users: [User<SharingCollection>],
    userGroupMembers: [UserGroupMember<SharingCollection>]
  ) {
    self.collectionInfo = collectionInfo
    self.users = users
    self.userGroupMembers = userGroupMembers
  }
}

public struct SharedEntityInfo<Recipient: SharingGroupMember>: Identifiable {
  public let id: Identifier
  public let info: Recipient.Group.Info
  public let recipient: Recipient

  public init(
    id: Identifier,
    info: Recipient.Group.Info,
    recipient: Recipient
  ) {
    self.id = id
    self.info = info
    self.recipient = recipient
  }
}

extension SharedEntityInfo: Equatable where Recipient: Equatable, Recipient.Group.Info: Equatable {}
extension SharedEntityInfo: Hashable where Recipient: Hashable, Recipient.Group.Info: Hashable {}

public struct SharedCollectionItems: Identifiable, Hashable {
  public var id: Identifier {
    collection.id
  }
  public var collection: CollectionInfo
  public var itemIds: [Identifier]
  public var permission: SharingPermission

  public init(
    collection: CollectionInfo,
    itemIds: [Identifier],
    permission: SharingPermission
  ) {
    self.collection = collection
    self.itemIds = itemIds
    self.permission = permission
  }
}

public struct SharingEntitiesUserGroup: Identifiable, Hashable {
  public let id: Identifier
  public let name: String
  public let isMember: Bool
  public var collections: [SharedEntityInfo<UserGroupMember<SharingCollection>>]
  public var items: [SharedEntityInfo<UserGroupMember<ItemGroup>>]
  public let users: [User<UserGroup>]

  public init(
    id: Identifier,
    name: String,
    isMember: Bool,
    collections: [SharedEntityInfo<UserGroupMember<SharingCollection>>] = [],
    items: [SharedEntityInfo<UserGroupMember<ItemGroup>>] = [],
    users: [User<UserGroup>]
  ) {
    self.id = id
    self.name = name
    self.isMember = isMember
    self.collections = collections
    self.items = items
    self.users = users
  }
}

public struct SharingEntitiesUser: Identifiable, Hashable {
  public let id: UserId
  public var collections: [SharedEntityInfo<User<SharingCollection>>]
  public var items: [SharedEntityInfo<User<ItemGroup>>]

  public init(
    id: UserId,
    collections: [SharedEntityInfo<User<SharingCollection>>] = [],
    items: [SharedEntityInfo<User<ItemGroup>>] = []
  ) {
    self.id = id
    self.collections = collections
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

public struct PendingCollection: Identifiable {
  public enum CodingKeys: String, CodingKey {
    case collectionInfo
    case referrer
  }

  public let collectionInfo: CollectionInfo
  public let referrer: String?

  public var id: Identifier {
    collectionInfo.id
  }

  public init(collectionInfo: CollectionInfo, referrer: String) {
    self.collectionInfo = collectionInfo
    self.referrer = referrer
  }
}
