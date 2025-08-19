import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation

@SharingActor
struct InviteItemGroupInCollectionBuilder {
  let cryptoProvider: SharingCryptoProvider
  let collectionId: String
  let collectionPublicKey: SharingPublicKey<SharingCollection>
  let collectionPrivateKey: SharingPrivateKey<SharingCollection>

  init(
    cryptoProvider: SharingCryptoProvider,
    collectionId: Identifier,
    collectionKeys: (
      publicKey: SharingPublicKey<SharingCollection>,
      privateKey: SharingPrivateKey<SharingCollection>
    )
  ) {
    self.cryptoProvider = cryptoProvider
    self.collectionId = collectionId.rawValue
    self.collectionPublicKey = collectionKeys.publicKey
    self.collectionPrivateKey = collectionKeys.privateKey
  }

  func makeItemGroups(
    itemGroupIdKeyPairs: [(groupId: Identifier, groupKey: SharingSymmetricKey<ItemGroup>)],
    auditLogDetails: [Identifier: AuditLogDetails]
  ) throws -> [UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection.Body
    .ItemGroupsElement]
  {
    try itemGroupIdKeyPairs.map {
      try makeItemGroup(withIdKeyPair: $0, auditLogDetails: auditLogDetails[$0.groupId])
    }
  }

  private func makeItemGroup(
    withIdKeyPair pair: (groupId: Identifier, groupKey: SharingSymmetricKey<ItemGroup>),
    auditLogDetails: AuditLogDetails?
  ) throws -> UserDeviceAPIClient.SharingUserdevice.AddItemGroupsToCollection.Body.ItemGroupsElement
  {
    let groupKey = pair.groupKey
    let proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
    let encryptedGroupKey = try cryptoProvider.encrypter(using: collectionPublicKey.raw)
      .encrypt(groupKey.raw)
      .base64EncodedString()
    let proposeSignature = try CollectionMember.createProposeSignature(
      using: proposeSignatureProducer,
      signatureId: collectionId
    )
    let acceptSignature = try CollectionMember.createAcceptSignature(
      using: collectionPrivateKey,
      groupInfo: (id: pair.groupId, key: groupKey),
      cryptoProvider: cryptoProvider
    )

    return .init(
      uuid: pair.groupId.rawValue,
      permission: .admin,
      itemGroupKey: encryptedGroupKey,
      proposeSignature: proposeSignature,
      acceptSignature: acceptSignature,
      auditLogDetails: auditLogDetails
    )
  }
}
