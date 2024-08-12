import DashTypes
import DashlaneAPI
import Foundation

public struct CollectionMember: Codable, Hashable, Identifiable, SharingGroupMember, Sendable {
  public typealias Group = ItemGroup
  public typealias Target = SharingCollection

  public let id: Identifier
  public let itemGroupId: Identifier
  public let name: String
  public let permission: SharingPermission
  public let status: SharingMemberStatus
  public let encryptedGroupKey: String?
  public let proposeSignature: String?
  public let acceptSignature: String?

  public var parentGroupId: Identifier {
    return itemGroupId
  }

  public var signatureId: String {
    return id.rawValue
  }

  public init(
    id: Identifier,
    itemGroupId: Identifier,
    name: String,
    permission: SharingPermission,
    status: SharingMemberStatus,
    encryptedGroupKey: String?,
    proposeSignature: String?,
    acceptSignature: String?
  ) {
    self.id = id
    self.itemGroupId = itemGroupId
    self.name = name
    self.permission = permission
    self.status = status
    self.encryptedGroupKey = encryptedGroupKey
    self.proposeSignature = proposeSignature
    self.acceptSignature = acceptSignature
  }
}

extension CollectionMember {
  init(_ collectionMember: ItemGroupDownload.CollectionsElement, itemGroupId: Identifier) {
    self.init(
      id: .init(collectionMember.uuid),
      itemGroupId: itemGroupId,
      name: collectionMember.name,
      permission: .init(collectionMember.permission),
      status: collectionMember.status,
      encryptedGroupKey: collectionMember.itemGroupKey,
      proposeSignature: collectionMember.proposeSignature,
      acceptSignature: collectionMember.acceptSignature
    )
  }
}
