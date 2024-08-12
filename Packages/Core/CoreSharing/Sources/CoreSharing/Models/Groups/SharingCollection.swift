import DashTypes
import DashlaneAPI
import Foundation

public struct SharingCollection: Codable, Hashable, Identifiable, SharingGroup, Sendable {
  typealias ItemGroupMember = CollectionMember

  public var id: Identifier {
    info.id
  }
  public var info: CollectionInfo
  public var users: [User<SharingCollection>]
  public var userGroupMembers: [UserGroupMember<SharingCollection>]

  init(
    info: CollectionInfo,
    users: [User<SharingCollection>],
    userGroupMembers: [UserGroupMember<SharingCollection>]
  ) {
    self.info = info
    self.users = users
    self.userGroupMembers = userGroupMembers
  }

  init(_ collectionDownload: CollectionDownload) {
    let collectionId: Identifier = .init(collectionDownload.uuid)
    self.init(
      info: .init(collectionDownload),
      users: collectionDownload.users?.map {
        User<SharingCollection>(user: $0, groupIdentifier: .collection(collectionId))
      } ?? [],
      userGroupMembers: collectionDownload.userGroups?.map {
        UserGroupMember<SharingCollection>(groupMember: $0, collectionId: collectionId)
      } ?? []
    )
  }
}

extension Collection where Element == SharingCollection {
  func filter(forCollectionsIds ids: Set<Identifier>) -> [SharingCollection] {
    filter { ids.contains($0.id) }
  }
}

public struct CollectionInfo: Codable, Hashable, Identifiable, Sendable {
  public let id: Identifier
  public var name: String
  public var publicKey: String
  public var encryptedPrivateKey: String
  public var revision: SharingRevision

  public init(
    id: Identifier,
    name: String,
    publicKey: String,
    encryptedPrivateKey: String,
    revision: SharingRevision
  ) {
    self.id = id
    self.name = name
    self.publicKey = publicKey
    self.encryptedPrivateKey = encryptedPrivateKey
    self.revision = revision
  }

  init(_ collectionDownload: CollectionDownload) {
    self.init(
      id: .init(collectionDownload.uuid),
      name: collectionDownload.name,
      publicKey: collectionDownload.publicKey,
      encryptedPrivateKey: collectionDownload.privateKey,
      revision: collectionDownload.revision
    )
  }
}
