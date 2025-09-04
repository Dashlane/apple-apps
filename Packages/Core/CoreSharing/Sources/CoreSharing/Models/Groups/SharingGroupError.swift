import Foundation
import LogFoundation

@Loggable
enum SharingGroupError: Error {
  @Loggable
  enum SignatureKind {
    case propose
    case accept
  }

  @Loggable
  enum SignatureReason {
    case unknown
    case empty
    case invalidBase64
    case notValid
  }

  @Loggable
  enum Key {
    case itemKey
    case groupKey
    case privateKey
    case publicKey
  }

  @LogPublicPrivacy
  case invalidStatus(SharingMemberStatus, expected: [SharingMemberStatus])
  case invalidSignature(SignatureKind, reason: SignatureReason)
  @LogPublicPrivacy
  case invalidRSAStatus(RSAStatus)
  case missingKey(Key)
  case missingItemContent
  case unknown
}
