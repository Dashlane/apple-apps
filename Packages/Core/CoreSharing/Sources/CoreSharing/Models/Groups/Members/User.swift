import DashTypes
import DashlaneAPI
import Foundation

public struct User<Group: SharingGroup>: Codable, Hashable, Identifiable, SharingGroupMember,
  Sendable
{
  public typealias Target = UserId

  public let id: String
  public let parentGroupId: Identifier
  let userGroupId: Identifier?
  let itemGroupId: Identifier?
  let collectionId: Identifier?
  public let referrer: String
  public var status: SharingMemberStatus
  public var encryptedGroupKey: String?
  public var permission: SharingPermission
  public var proposeSignature: String?
  public var acceptSignature: String?
  public var rsaStatus: RSAStatus

  public var signatureId: String {
    return id
  }

  public var email: String {
    return id
  }

  public init(
    id: String,
    parentGroupId: Identifier,
    userGroupId: Identifier? = nil,
    itemGroupId: Identifier? = nil,
    collectionId: Identifier? = nil,
    referrer: String,
    status: SharingMemberStatus,
    encryptedGroupKey: String? = nil,
    permission: SharingPermission,
    proposeSignature: String? = nil,
    acceptSignature: String? = nil,
    rsaStatus: RSAStatus
  ) {
    self.id = id
    self.parentGroupId = parentGroupId
    self.userGroupId = userGroupId
    self.itemGroupId = itemGroupId
    self.collectionId = collectionId
    self.referrer = referrer
    self.status = status
    self.encryptedGroupKey = encryptedGroupKey
    self.permission = permission
    self.proposeSignature = proposeSignature
    self.acceptSignature = acceptSignature
    self.rsaStatus = rsaStatus
  }
}

extension User {
  init(user: UserDownload, groupIdentifier: GroupIdentifier) {
    id = user.userId
    parentGroupId = groupIdentifier.id
    itemGroupId = groupIdentifier.itemGroupId
    userGroupId = groupIdentifier.userGroupId
    collectionId = groupIdentifier.collectionId
    encryptedGroupKey = user.groupKey
    permission = .init(user.permission)
    proposeSignature = user.proposeSignature
    acceptSignature = user.acceptSignature
    referrer = user.referrer
    rsaStatus = user.rsaStatus ?? .noKey
    status = user.status ?? .pending
  }
}

extension User {
  init(user: UserCollectionDownload, groupIdentifier: GroupIdentifier) {
    self.init(
      id: user.login,
      parentGroupId: groupIdentifier.id,
      userGroupId: groupIdentifier.userGroupId,
      itemGroupId: groupIdentifier.itemGroupId,
      collectionId: groupIdentifier.collectionId,
      referrer: user.referrer,
      status: user.status,
      encryptedGroupKey: user.collectionKey,
      permission: .init(user.permission),
      proposeSignature: user.proposeSignature,
      acceptSignature: user.acceptSignature,
      rsaStatus: .init(user.rsaStatus ?? .noKey)
    )
  }
}

extension RSAStatus {
  fileprivate init(_ rsaStatus: UserCollectionDownload.RsaStatus) {
    switch rsaStatus {
    case .noKey:
      self = .noKey
    case .publicKey:
      self = .publicKey
    case .sharingKeys:
      self = .sharingKeys
    case .undecodable:
      self = .noKey
    }
  }
}

extension SharingPermission {
  init(_ permission: Permission) {
    switch permission {
    case .admin:
      self = .admin
    case .limited:
      self = .limited
    case .undecodable:
      self = .limited
    }
  }
}

extension Permission {
  init(_ permission: SharingPermission) {
    switch permission {
    case .admin:
      self = .admin
    case .limited:
      self = .limited
    }
  }
}
