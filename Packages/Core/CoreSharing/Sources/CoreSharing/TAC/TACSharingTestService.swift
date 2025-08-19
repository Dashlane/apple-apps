import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation

@SharingActor
public struct TACSharingTestService<UIDatabase: SharingUIDatabase> {
  let apiClient: UserDeviceAPIClient
  let teamId: Int
  let engine: SharingEngine<UIDatabase>

  public init(apiClient: UserDeviceAPIClient, teamId: Int, sharingEngine: SharingEngine<UIDatabase>)
  {
    self.apiClient = apiClient
    self.teamId = teamId
    self.engine = sharingEngine
  }

  public func createUserGroup(
    withName name: String, members: [UserId], permission: SharingPermission = .admin
  ) async throws -> Identifier {
    let groupId = Identifier()
    let groupKey = engine.cryptoProvider.makeSymmetricKey()
    let cryptoEngine = try engine.cryptoProvider.cryptoEngine(using: groupKey)
    let publicKeys = try await engine.sharingClientAPI.findPublicKeys(for: members)

    let groupKeyPair = try AsymmetricKeyPair(keySize: .rsa2048)
    let privateKey = try groupKeyPair.privateKey.pemString()
      .data(using: .utf8)!
      .encrypt(using: cryptoEngine)

    let inviteBuilder = InviteBuilder<ItemGroup>(
      groupId: groupId,
      permission: permission,
      groupKey: .init(raw: groupKey),
      cryptoProvider: engine.cryptoProvider,
      groupKeyProvider: engine.groupKeyProvider,
      database: engine.operationDatabase,
      userPublicKeys: publicKeys
    )

    let users = try inviteBuilder.makeUserUploads(recipients: members)
    let author: UserUpload = try inviteBuilder.makeAuthorUpload(
      userId: engine.userId, userKeyPair: engine.userKeyStore.get())

    _ = try await apiClient.sharingUserdevice.createUserGroup(
      provisioningMethod: .tac,
      groupId: groupId.rawValue,
      teamId: teamId,
      name: name,
      publicKey: try groupKeyPair.publicKey.pemString(),
      privateKey: privateKey.base64EncodedString(),
      users: (users + [author]).map(InviteUserGroupUserUpload.init))

    return groupId
  }
}

extension InviteUserGroupUserUpload {
  init(_ invite: UserUpload) {
    self.init(
      alias: invite.alias,
      permission: invite.permission,
      proposeSignature: invite.proposeSignature,
      acceptSignature: invite.acceptSignature,
      groupKey: invite.groupKey,
      proposeSignatureUsingAlias: nil,
      userId: invite.userId)
  }
}
