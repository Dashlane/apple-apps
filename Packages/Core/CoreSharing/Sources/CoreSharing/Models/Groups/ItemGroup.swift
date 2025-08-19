import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation
import LogFoundation

@Loggable
public struct ItemGroup: Codable, Hashable, Identifiable, SharingGroup, Sendable {
  public var info: ItemGroupInfo
  public var itemKeyPairs: [ItemKeyPair]
  public var users: [User<ItemGroup>]
  public var userGroupMembers: [UserGroupMember<ItemGroup>]
  public var collectionMembers: [CollectionMember]

  public var id: Identifier {
    info.id
  }

  public init(
    info: ItemGroupInfo,
    itemKeyPairs: [ItemKeyPair],
    users: [User<ItemGroup>],
    userGroupMembers: [UserGroupMember<ItemGroup>],
    collectionMembers: [CollectionMember]
  ) {
    self.info = info
    self.itemKeyPairs = itemKeyPairs
    self.users = users
    self.userGroupMembers = userGroupMembers
    self.collectionMembers = collectionMembers
  }

  public init(_ itemGroupDownload: ItemGroupDownload) {
    let info = ItemGroupInfo(itemGroupDownload)
    self.info = info
    itemKeyPairs = itemGroupDownload.items?.map { ItemKeyPair($0, itemGroupId: info.id) } ?? []
    users =
      itemGroupDownload.users?.map {
        User<ItemGroup>(user: $0, groupIdentifier: .itemGroup(info.id))
      } ?? []
    userGroupMembers =
      itemGroupDownload.groups?.map {
        UserGroupMember<ItemGroup>(groupMember: $0, itemGroupId: .init(itemGroupDownload.groupId))
      } ?? []
    collectionMembers =
      itemGroupDownload.collections?.map {
        CollectionMember($0, itemGroupId: .init(itemGroupDownload.groupId))
      } ?? []
  }
}

extension ItemGroup {
  func userGroupMember(withId id: Identifier) -> UserGroupMember<ItemGroup>? {
    return userGroupMembers.first { $0.id == id }
  }
}

extension Collection where Element == ItemGroup {
  func filter(forItemIds ids: Set<Identifier>) -> [ItemGroup] {
    filter {
      $0.itemKeyPairs.contains { ids.contains($0.id) }
    }
  }

  func union(_ groups: [ItemGroup]) -> [ItemGroup] {
    return Array(
      Dictionary(values: self).merging(Dictionary(values: groups)) { group, _ in
        group
      }.values)
  }
}

@Loggable
public struct ItemGroupInfo: Codable, Hashable, Identifiable, Sendable {
  public let id: Identifier
  public var revision: SharingRevision
  public var teamId: Int?

  public init(id: Identifier = Identifier(), revision: Int = 1, teamId: Int? = nil) {
    self.id = id
    self.revision = revision
    self.teamId = teamId
  }
}

extension ItemGroupInfo {
  init(_ group: ItemGroupDownload) {
    id = .init(group.groupId)
    revision = group.revision
    teamId = group.teamId
  }
}

public struct ItemKeyPair: Codable, Hashable, Identifiable, Sendable {
  public let id: Identifier
  public let itemGroupId: Identifier
  public var encryptedKey: String
}

extension ItemKeyPair {
  init(_ itemKey: ItemGroupDownload.ItemsElement, itemGroupId: Identifier) {
    id = .init(itemKey.itemId)
    encryptedKey = itemKey.itemKey
    self.itemGroupId = itemGroupId
  }
}
