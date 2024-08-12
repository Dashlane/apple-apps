import Foundation

enum SharingGroupError: Error {
  enum SignatureKind {
    case propose
    case accept
  }
  enum SignatureReason {
    case unknown
    case emptyOrInvalidBase64
    case notValid
  }

  enum Key {
    case itemKey
    case groupKey
    case privateKey
    case publicKey
  }

  case invalidStatus(SharingMemberStatus, expected: [SharingMemberStatus])
  case invalidSignature(SignatureKind, reason: SignatureReason)
  case invalidRSAStatus(RSAStatus)
  case missingKey(Key)
  case missingItemContent
  case unknown
}
