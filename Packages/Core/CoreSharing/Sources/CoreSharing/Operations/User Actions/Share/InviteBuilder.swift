import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation

@SharingActor
struct InviteBuilder<Group: SharingGroup> {
  let groupId: Identifier
  let permission: SharingPermission
  let groupKey: SharingSymmetricKey<Group>
  let proposeSignatureProducer: ProposeSignatureProducer<Group>
  let cryptoProvider: SharingCryptoProvider
  let groupKeyProvider: GroupKeyProvider
  let database: SharingOperationsDatabase
  let userPublicKeys: [UserId: RawPublicKey]

  init(
    groupId: Identifier,
    permission: SharingPermission,
    groupKey: SharingSymmetricKey<Group>,
    cryptoProvider: SharingCryptoProvider,
    groupKeyProvider: GroupKeyProvider,
    database: SharingOperationsDatabase,
    userPublicKeys: [UserId: RawPublicKey]
  ) {
    self.groupId = groupId
    self.permission = permission
    self.groupKey = groupKey
    self.proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
    self.cryptoProvider = cryptoProvider
    self.groupKeyProvider = groupKeyProvider
    self.database = database
    self.userPublicKeys = userPublicKeys
  }
}

extension InviteBuilder {

  func makeAuthorUpload<Invite: UserUploadModel>(
    userId: String,
    userKeyPair: SharingAsymmetricKey<UserId>
  ) throws -> Invite {
    let encryptedGroupKey = try User<Group>.encrypt(
      groupKey, with: userKeyPair.publicKey, cryptoProvider: cryptoProvider)

    let proposeSignature = try User<Group>.createProposeSignature(
      using: proposeSignatureProducer, signatureId: userId)

    let acceptSignature = try User<Group>.createAcceptSignature(
      using: userKeyPair.privateKey,
      groupInfo: (id: groupId, key: groupKey),
      cryptoProvider: cryptoProvider
    )

    return Invite(
      userId: userId,
      permission: .init(.admin),
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature,
      groupKey: encryptedGroupKey,
      proposeSignatureUsingAlias: false
    )
  }

  func makeUserInvites<Invite: UserInviteModel>(recipients: [String]) throws -> [Invite] {
    return try recipients.map { recipient in
      if let publicKeyPEM = userPublicKeys[recipient] {
        let publicKey = try cryptoProvider.userPublicKey(fromPemString: publicKeyPEM)
        let encryptedGroupKey = try User<Group>.encrypt(
          groupKey, with: publicKey, cryptoProvider: cryptoProvider)
        let proposeSignature = try User<Group>.createProposeSignature(
          using: proposeSignatureProducer, signatureId: recipient)

        return Invite(
          recipient: recipient,
          permission: permission,
          proposeSignature: proposeSignature,
          groupKey: encryptedGroupKey,
          proposeSignatureUsingAlias: false
        )
      } else {
        let proposeSignature = try User<Group>.createProposeSignature(
          using: proposeSignatureProducer, signatureId: recipient)

        return Invite(
          recipient: recipient,
          permission: permission,
          proposeSignature: proposeSignature,
          groupKey: nil,
          proposeSignatureUsingAlias: true
        )
      }
    }
  }

  func makeUserGroupInvites<Invite: UserGroupInviteModel>(userGroupIds: [Identifier]) throws
    -> [Invite]
  {
    let userGroups = try database.fetchUserGroups(withIds: userGroupIds)

    return try userGroups.map { userGroup in
      let publicKey = try userGroup.publicKey(using: cryptoProvider)
      let encryptedGroupKey = try UserGroupMember<Group>.encrypt(
        groupKey, with: publicKey, cryptoProvider: cryptoProvider)
      let proposeSignature = try UserGroupMember<Group>.createProposeSignature(
        using: proposeSignatureProducer, signatureId: userGroup.id.rawValue)

      let acceptSignature: String?

      if let privateKey = try groupKeyProvider.privateKey(for: userGroup) {
        acceptSignature = try UserGroupMember<Group>.createAcceptSignature(
          using: privateKey,
          groupInfo: (id: groupId, key: groupKey),
          cryptoProvider: cryptoProvider
        )
      } else {
        acceptSignature = nil
      }

      return Invite(
        groupId: userGroup.id,
        permission: permission,
        groupKey: encryptedGroupKey,
        proposeSignature: proposeSignature,
        acceptSignature: acceptSignature
      )
    }
  }
}

extension InviteBuilder where Group == ItemGroup {
  func makeUserUploads(recipients: [String]) throws -> [UserUpload] {
    try makeUserInvites(recipients: recipients).map(UserUpload.init)
  }
}

extension InviteBuilder where Group == SharingCollection {
  func makeUserUploads(recipients: [String]) throws -> [UserCollectionUpload] {
    try makeUserInvites(recipients: recipients)
  }
}
