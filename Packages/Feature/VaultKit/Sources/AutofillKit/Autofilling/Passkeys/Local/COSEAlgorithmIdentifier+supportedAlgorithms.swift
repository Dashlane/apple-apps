import AuthenticationServices
import Foundation
import WebAuthn

extension COSEAlgorithmIdentifier {
  static let supportedAlgorithms: Set<COSEAlgorithmIdentifier> = [
    .es256
  ]
}

extension [ASCOSEAlgorithmIdentifier] {
  public func firstSupportedAlgorithm() -> COSEAlgorithmIdentifier {
    self
      .compactMap({ $0.algorithm })
      .first(where: { COSEAlgorithmIdentifier.allCases.contains($0) }) ?? .es256
  }
}

extension ASCOSEAlgorithmIdentifier {
  fileprivate var algorithm: COSEAlgorithmIdentifier? {
    switch self {
    case .ES256:
      return .es256
    default:
      return nil
    }
  }
}
