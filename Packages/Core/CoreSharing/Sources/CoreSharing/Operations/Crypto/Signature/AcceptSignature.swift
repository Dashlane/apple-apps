import CyrilKit
import DashTypes
import Foundation

struct AcceptSignatureMessage {
  let id: String
  let groupKey: SymmetricKey

  func data() throws -> Data {
    guard case let message = id + "-accepted-" + groupKey.base64EncodedString(),
      let messageData = message.data(using: .utf8)
    else {
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

extension SharingGroupMember {
  func verifyAcceptSignature(
    using publicKey: SharingPublicKey<Target>, groupKey: SharingSymmetricKey<Group>,
    cryptoProvider: SharingCryptoProvider
  ) throws {
    let verifier = cryptoProvider.acceptSignatureVerifier(using: publicKey.raw)
    try verifyAcceptSignature(using: verifier, groupKey: groupKey)
  }

  private func verifyAcceptSignature(
    using verifier: SignatureVerifier, groupKey: SharingSymmetricKey<Group>
  ) throws {
    guard let base64Encoded = acceptSignature,
      let signature = Signature(base64Encoded: base64Encoded)
    else {
      throw SharingGroupError.invalidSignature(.accept, reason: .emptyOrInvalidBase64)
    }
    let expectedMessageData = try AcceptSignatureMessage(
      id: parentGroupId.rawValue, groupKey: groupKey.raw
    ).data()

    guard verifier.verify(expectedMessageData, with: signature) else {
      throw SharingGroupError.invalidSignature(.accept, reason: .notValid)
    }
  }
}

extension SharingGroupMember {
  static func createAcceptSignature(
    using privateKey: SharingPrivateKey<Target>,
    groupInfo: (id: Identifier, key: SharingSymmetricKey<Group>),
    cryptoProvider: SharingCryptoProvider
  ) throws -> String {

    let signer = cryptoProvider.acceptMessageSigner(using: privateKey.raw)

    return try AcceptSignature(
      groupId: groupInfo.id,
      groupKey: groupInfo.key.raw,
      messageSigner: signer
    ).base64EncodedString()
  }

  func createAcceptSignature(
    using privateKey: SharingPrivateKey<Target>, groupKey: SharingSymmetricKey<Group>,
    cryptoProvider: SharingCryptoProvider
  ) throws -> String {
    return try Self.createAcceptSignature(
      using: privateKey, groupInfo: (id: parentGroupId, key: groupKey),
      cryptoProvider: cryptoProvider)
  }
}
