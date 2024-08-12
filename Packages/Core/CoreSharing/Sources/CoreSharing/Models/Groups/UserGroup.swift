import DashTypes
import DashlaneAPI
import Foundation

public struct UserGroup: Codable, Equatable, Identifiable, SharingGroup, Sendable {
  public var info: UserGroupInfo
  public var users: [User<UserGroup>]

  public var id: Identifier {
    info.id
  }

  public init(info: UserGroupInfo, users: [User<UserGroup>]) {
    self.info = info
    self.users = users
  }

  public init(_ userGroupDownload: UserGroupDownload) {
    info = UserGroupInfo(userGroupDownload)
    users = userGroupDownload.users.map {
      User<UserGroup>(user: $0, groupIdentifier: .userGroup(Identifier(userGroupDownload.groupId)))
    }
  }
}

public struct UserGroupInfo: Codable, Equatable, Identifiable, Sendable {
  public let id: Identifier
  public var name: String
  public var publicKey: String
  public var encryptedPrivateKey: String
  public var revision: SharingRevision

  public init(
    id: Identifier = Identifier(), name: String, publicKey: String, encryptedPrivateKey: String,
    revision: Int = 1
  ) {
    self.id = id
    self.name = name
    self.publicKey = publicKey
    self.encryptedPrivateKey = encryptedPrivateKey
    self.revision = revision
  }
}

extension UserGroupInfo {
  init(_ group: UserGroupDownload) {
    id = .init(group.groupId)
    name = group.name
    publicKey = group.publicKey
    encryptedPrivateKey = group.privateKey
    revision = group.revision
  }
}
