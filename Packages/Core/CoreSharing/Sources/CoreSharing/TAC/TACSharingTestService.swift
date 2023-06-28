import Foundation
import DashTypes
import CyrilKit
import DashlaneAPI

@SharingActor
public struct TACSharingTestService<UIDatabase: SharingUIDatabase> {
        struct Invite: Codable, Equatable {
        public let alias: String
        public let permission: SharingPermission
        public let proposeSignature: String
        public let acceptSignature: String?
        public let groupKey: String?
        public let proposeSignatureUsingAlias: Bool?
        public let userId: String?
    }

        struct CreateUserGroupRequest: Encodable {
        enum ProvisioningMethodSchema: String, Codable, Equatable, CaseIterable {
            case user = "USER"
            case tac = "TAC"
            case ad = "AD"
            case scim = "SCIM"
        }

        public let provisioningMethod: ProvisioningMethodSchema
        public let groupId: String
        public let teamId: Int
        public let name: String
        public let publicKey: String
        public let privateKey: String
        public let users: [Invite]
    }

    let apiClient: DeprecatedCustomAPIClient
    let teamId: Int
    let engine: SharingEngine<UIDatabase>

    public init(apiClient: DeprecatedCustomAPIClient, teamId: Int, sharingEngine: SharingEngine<UIDatabase>) {
        self.apiClient = apiClient
        self.teamId = teamId
        self.engine = sharingEngine
    }

    public func createUserGroup(withName name: String, members: [UserId], permission: SharingPermission = .admin) async throws -> Identifier {
        let groupId = Identifier()
        let groupKey = engine.cryptoProvider.makeSymmetricKey()
        let cryptoEngine = engine.cryptoProvider.cryptoEngine(using: groupKey)
        let publicKeys = try await engine.sharingClientAPI.findPublicKeys(for: members)

        let groupKeyPair = try AsymmetricKeyPair(keySize: .rsa2048)
        let privateKey = try groupKeyPair.privateKey.rsaPemString()
            .data(using: .utf8)!
            .encrypt(using: cryptoEngine)

        let inviteBuilder = InviteBuilder(groupId: groupId,
                                          permission: permission,
                                          groupKey: groupKey,
                                          cryptoProvider: engine.cryptoProvider,
                                          groupKeyProvider: engine.groupKeyProvider,
                                          database: engine.operationDatabase,
                                          userPublicKeys: publicKeys)

        let users = try inviteBuilder.makeUserUploads(recipients: members)
        let author = try inviteBuilder.makeAuthorUpload(userId: engine.userId, userKeyPair: engine.userKeyStore.get())

        let createRequest = CreateUserGroupRequest(provisioningMethod: .tac,
                                                   groupId: groupId.rawValue,
                                                   teamId: teamId,
                                                   name: name,
                                                   publicKey: try groupKeyPair.publicKey.rsaPemString(),
                                                   privateKey: privateKey.base64EncodedString(),
                                                   users: (users + [author]).map(Invite.init))

        let _: Empty =  try await apiClient.sendRequest(to: "v1/sharing-userdevice/CreateUserGroup",
                                                                 using: .post,
                                                                 input: createRequest)

        return groupId
    }
}

private struct Empty: Decodable {}

extension TACSharingTestService.Invite {
    init(_ invite: UserUpload) {
        self.init(alias: invite.alias,
                  permission: .init(invite.permission),
                  proposeSignature: invite.proposeSignature,
                  acceptSignature: invite.acceptSignature,
                  groupKey: invite.groupKey,
                  proposeSignatureUsingAlias: nil,
                  userId: invite.userId)
    }
}
