import Foundation
import CyrilKit
import DashTypes

struct AcceptSignatureMessage {
    let id: String
    let groupKey: SymmetricKey

    func data() throws -> Data {
        guard case let message = id + "-accepted-" + groupKey.base64EncodedString(),
              let messageData = message.data(using: .utf8) else {
            throw SharingGroupError.invalidSignature(.accept, reason: .unknown)
        }

        return messageData
    }
}

struct AcceptSignature {
    let groupId: Identifier
    let groupKey: SymmetricKey
    let messageSigner: MessageSigner

        func base64EncodedString() throws -> String {
        let message = try AcceptSignatureMessage(id: groupId.rawValue, groupKey: groupKey).data()
        let signature = try messageSigner.sign(message)
        return signature.data.base64EncodedString()
    }
}

extension MessageSigner {
    func create(forGroupId id: Identifier, groupKey: SymmetricKey) throws -> String {
        try AcceptSignature(groupId: id,
                            groupKey: groupKey,
                            messageSigner: self).base64EncodedString()
    }
}

extension SharingGroupMember {
                func verifyAcceptSignature(using verifier: SignatureVerifier, groupKey: SymmetricKey) throws {
        guard let base64Encoded = acceptSignature,
              let signature = Signature(base64Encoded: base64Encoded) else {
            throw SharingGroupError.invalidSignature(.accept, reason: .emptyOrInvalidBase64)
        }
        let expectedMessageData = try AcceptSignatureMessage(id: parentGroupId.rawValue, groupKey: groupKey).data()

        guard verifier.verify(expectedMessageData, with: signature) else {
            throw SharingGroupError.invalidSignature(.accept, reason: .notValid)
        }
    }

        func createAcceptSignature(using signer: MessageSigner, groupKey: SymmetricKey) throws -> String {
        try signer.create(forGroupId: parentGroupId, groupKey: groupKey)
    }
}
