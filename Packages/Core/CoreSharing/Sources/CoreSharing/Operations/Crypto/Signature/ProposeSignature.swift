import CyrilKit
import Foundation

struct ProposeSignatureProducer<Group: SharingGroup> {
  let codeProducer: AuthenticationCodeProducer

  fileprivate func create(forSignatureId signatureId: String) throws -> String {
    guard let data = signatureId.data(using: .utf8) else {
      throw SharingGroupError.invalidSignature(.propose, reason: .unknown)
    }

    return codeProducer.authenticationCode(for: data)
      .base64EncodedString()
  }
}

extension SharingCryptoProvider {
  func proposeSignatureProducer<Group: SharingGroup>(using groupKey: SharingSymmetricKey<Group>)
    -> ProposeSignatureProducer<Group>
  {
    return ProposeSignatureProducer(codeProducer: authenticationCodeProducer(using: groupKey.raw))
  }
}

extension SharingGroupMember {
  static func createProposeSignature(
    using producer: ProposeSignatureProducer<Group>, signatureId: String
  ) throws -> String {
    return try producer.create(forSignatureId: signatureId)
  }

  func createProposeSignature(using producer: ProposeSignatureProducer<Group>) throws -> String {
    return try producer.create(forSignatureId: signatureId)
  }

  func verifyProposeSignature(using producer: ProposeSignatureProducer<Group>) throws {
    guard status.isAcceptedOrPending else {
      return
    }

    guard let signature = proposeSignature else {
      throw SharingGroupError.invalidSignature(.propose, reason: .emptyOrInvalidBase64)
    }

    let expected = try createProposeSignature(using: producer)
    guard expected == signature else {
      throw SharingGroupError.invalidSignature(.propose, reason: .notValid)
    }
  }
}

extension Collection where Element: SharingGroupMember {
  func verifyProposeSignatures(using producer: ProposeSignatureProducer<Element.Group>) throws {
    for item in self {
      try item.verifyProposeSignature(using: producer)
    }
  }
}
