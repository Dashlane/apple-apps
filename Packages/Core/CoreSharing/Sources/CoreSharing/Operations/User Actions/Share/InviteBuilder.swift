import Foundation
import DashTypes
import CyrilKit
import DashlaneAPI

@SharingActor
struct InviteBuilder {
    let groupId: Identifier
    let permission: SharingPermission
    let groupKey: SymmetricKey
    let proposeSignatureProducer: ProposeSignatureProducer
    let cryptoProvider: SharingCryptoProvider
    let groupKeyProvider: GroupKeyProvider
    let database: SharingOperationsDatabase
    let userPublicKeys: [UserId: RawPublicKey]

    init(groupId: Identifier,
         permission: SharingPermission,
         groupKey: SymmetricKey,
         cryptoProvider: SharingCryptoProvider,
         groupKeyProvider: GroupKeyProvider,
         database: SharingOperationsDatabase,
         userPublicKeys: [UserId: RawPublicKey]) {
        self.groupId = groupId
        self.permission = permission
        self.groupKey = groupKey
        self.proposeSignatureProducer = cryptoProvider.proposeSignatureProducer(using: groupKey)
        self.cryptoProvider = cryptoProvider
        self.groupKeyProvider = groupKeyProvider
        self.database = database
        self.userPublicKeys = userPublicKeys
    }

                func makeAuthorUpload(userId: String, userKeyPair: AsymmetricKeyPair) throws -> UserUpload {
        let encryptedGroupKey = try cryptoProvider.encrypter(using: userKeyPair.publicKey)
            .encrypt(groupKey)
            .base64EncodedString()
        let proposeSignature = try proposeSignatureProducer.create(forId: userId)
        let acceptMessageSigner = cryptoProvider.acceptMessageSigner(using: userKeyPair.privateKey)
        let acceptSignature = try acceptMessageSigner.create(forGroupId: groupId, groupKey: groupKey)

        return UserUpload(userId: userId,
                          alias: userId,
                          permission: .init(.admin),
                          proposeSignature: proposeSignature,
                          acceptSignature: acceptSignature,
                          groupKey: encryptedGroupKey,
                          proposeSignatureUsingAlias: false)
    }

    func makeUserUploads(recipients: [String]) throws -> [UserUpload] {
        try makeUserInvites(recipients: recipients).map(UserUpload.init)
    }

                func makeUserInvites(recipients: [String]) throws -> [UserInvite] {
        return try recipients.map { recipient in
                        if let publicKey = userPublicKeys[recipient] {
                let encryptedGroupKey = try cryptoProvider.encrypt(groupKey, withPublicPemString: publicKey)
                let proposeSignature = try proposeSignatureProducer.create(forId: recipient)

                return UserInvite(userId: recipient,
                                  alias: recipient,
                                  permission: .init(permission),
                                  proposeSignature: proposeSignature,
                                  groupKey: encryptedGroupKey,
                                  proposeSignatureUsingAlias: false)

            }
                        else {
                let proposeSignature = try proposeSignatureProducer.create(forId: recipient)

                return UserInvite(userId: recipient,
                                  alias: recipient,
                                  permission: .init(permission),
                                  proposeSignature: proposeSignature,
                                  groupKey: nil,
                                  proposeSignatureUsingAlias: true)
            }
        }
    }

                func makeUserGroupInvites(userGroupIds: [Identifier]) throws -> [UserGroupInvite] {
        let userGroups = try database.fetchUserGroups(withIds: userGroupIds)

        return try userGroups.map { userGroup in
            let encryptedGroupKey = try cryptoProvider.encrypt(groupKey, withPublicPemString: userGroup.info.publicKey)
            let proposeSignature = try proposeSignatureProducer.create(forId: userGroup.id.rawValue)
            let acceptSignature: String?

                        if let privateKey = try groupKeyProvider.privateKey(for: userGroup) {
                let acceptMessageSigner = cryptoProvider.acceptMessageSigner(using: privateKey)
                acceptSignature = try acceptMessageSigner.create(forGroupId: groupId, groupKey: groupKey)

            } else {
                acceptSignature = nil
            }

            return UserGroupInvite(groupId: userGroup.id.rawValue,
                                   permission: .init(permission),
                                   groupKey: encryptedGroupKey,
                                   proposeSignature: proposeSignature,
                                   acceptSignature: acceptSignature)
        }
    }
}
