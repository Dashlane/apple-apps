import DashTypes
import DashlaneAPI
import Foundation

public struct UserGroupMember<Group: SharingGroup>: Codable, Hashable, Identifiable,
  SharingGroupMember, Sendable
{
  public typealias Target = UserGroup

  public let id: Identifier
  public let parentGroupId: Identifier
  let itemGroupId: Identifier?
  let collectionId: Identifier?
  public let name: String
  public let status: SharingMemberStatus
  public let permission: SharingPermission
  public let encryptedGroupKey: String?
  public let proposeSignature: String?
  public let acceptSignature: String?

  public var signatureId: String {
    return id.rawValue
  }

  public init(
    id: Identifier,
    itemGroupId: Identifier,
    name: String,
    status: SharingMemberStatus,
    permission: SharingPermission,
    encryptedGroupKey: String? = nil,
    proposeSignature: String? = nil,
    acceptSignature: String? = nil
  ) {
    self.id = id
    self.parentGroupId = itemGroupId
    self.itemGroupId = itemGroupId
    self.collectionId = nil
    self.name = name
    self.status = status
    self.permission = permission
    self.encryptedGroupKey = encryptedGroupKey
    self.proposeSignature = proposeSignature
    self.acceptSignature = acceptSignature
  }

  init(
    id: Identifier,
    collectionId: Identifier,
    name: String,
    status: SharingMemberStatus,
    permission: SharingPermission,
    encryptedGroupKey: String? = nil,
    proposeSignature: String? = nil,
    acceptSignature: String? = nil
  ) {
    self.id = id
    self.parentGroupId = collectionId
    self.itemGroupId = nil
    self.collectionId = collectionId
    self.name = name
    self.status = status
    self.permission = permission
    self.encryptedGroupKey = encryptedGroupKey
    self.proposeSignature = proposeSignature
    self.acceptSignature = acceptSignature
  }
}

extension UserGroupMember {
  init(groupMember: ItemGroupDownload.GroupsElement, itemGroupId: Identifier) {
    self.init(
      id: .init(groupMember.groupId),
      itemGroupId: itemGroupId,
      name: groupMember.name,
      status: groupMember.status,
      permission: .init(groupMember.permission),
      encryptedGroupKey: groupMember.groupKey,
      proposeSignature: groupMember.proposeSignature,
      acceptSignature: groupMember.acceptSignature
    )
  }
}

extension UserGroupMember {
  init(groupMember: UserGroupCollectionDownload, collectionId: Identifier) {
    self.init(
      id: .init(groupMember.uuid),
      collectionId: collectionId,
      name: groupMember.name,
      status: groupMember.status,
      permission: .init(groupMember.permission),
      encryptedGroupKey: groupMember.collectionKey,
      proposeSignature: groupMember.proposeSignature,
      acceptSignature: groupMember.acceptSignature
    )
  }
}
