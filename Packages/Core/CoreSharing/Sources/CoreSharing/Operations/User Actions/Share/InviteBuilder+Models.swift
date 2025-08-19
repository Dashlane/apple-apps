import CoreTypes
import DashlaneAPI
import Foundation

protocol UserUploadModel {
  init(
    userId: String,
    permission: SharingPermission,
    proposeSignature: String,
    acceptSignature: String,
    groupKey: String,
    proposeSignatureUsingAlias: Bool
  )
}

extension UserUpload {
  init(userInvite: UserInvite) {
    self.init(
      userId: userInvite.userId,
      alias: userInvite.alias,
      permission: userInvite.permission,
      proposeSignature: userInvite.proposeSignature,
      acceptSignature: nil,
      groupKey: userInvite.groupKey,
      proposeSignatureUsingAlias: userInvite.proposeSignatureUsingAlias
    )
  }
}

extension UserUpload: UserUploadModel {
  init(
    userId: String,
    permission: SharingPermission,
    proposeSignature: String,
    acceptSignature: String,
    groupKey: String,
    proposeSignatureUsingAlias: Bool
  ) {
    self.init(
      userId: userId,
      alias: userId,
      permission: .init(permission),
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature,
      groupKey: groupKey,
      proposeSignatureUsingAlias: proposeSignatureUsingAlias
    )
  }
}

extension UserCollectionUpload: UserUploadModel {
  init(
    userId: String,
    permission: SharingPermission,
    proposeSignature: String,
    acceptSignature: String,
    groupKey: String,
    proposeSignatureUsingAlias: Bool
  ) {
    self.init(
      login: userId,
      alias: userId,
      permission: .init(permission),
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature,
      collectionKey: groupKey,
      proposeSignatureUsingAlias: proposeSignatureUsingAlias
    )
  }
}

protocol UserInviteModel {
  init(
    recipient: String,
    permission: SharingPermission,
    proposeSignature: String,
    groupKey: String?,
    proposeSignatureUsingAlias: Bool
  )
}

extension UserInvite: UserInviteModel {
  init(
    recipient: String,
    permission: SharingPermission,
    proposeSignature: String,
    groupKey: String?,
    proposeSignatureUsingAlias: Bool
  ) {
    self.init(
      userId: recipient,
      alias: recipient,
      permission: .init(permission),
      proposeSignature: proposeSignature,
      groupKey: groupKey,
      proposeSignatureUsingAlias: proposeSignatureUsingAlias
    )
  }
}

extension UserCollectionUpload: UserInviteModel {
  init(
    recipient: String,
    permission: SharingPermission,
    proposeSignature: String,
    groupKey: String?,
    proposeSignatureUsingAlias: Bool
  ) {
    self.init(
      login: recipient,
      alias: recipient,
      permission: .init(permission),
      proposeSignature: proposeSignature,
      collectionKey: groupKey,
      proposeSignatureUsingAlias: proposeSignatureUsingAlias
    )
  }
}

protocol UserGroupInviteModel {
  init(
    groupId: Identifier,
    permission: SharingPermission,
    groupKey: String,
    proposeSignature: String,
    acceptSignature: String?
  )
}

extension UserGroupInvite: UserGroupInviteModel {
  init(
    groupId: Identifier,
    permission: SharingPermission,
    groupKey: String,
    proposeSignature: String,
    acceptSignature: String?
  ) {
    self.init(
      groupId: groupId.rawValue,
      permission: .init(permission),
      groupKey: groupKey,
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature
    )
  }
}

extension UserGroupCollectionInvite: UserGroupInviteModel {
  init(
    groupId: Identifier,
    permission: SharingPermission,
    groupKey: String,
    proposeSignature: String,
    acceptSignature: String?
  ) {
    self.init(
      groupUUID: groupId.rawValue,
      permission: .init(permission),
      collectionKey: groupKey,
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature
    )
  }
}
