import AuthenticationServices
import CryptoKit
import Foundation
import UserTrackingFoundation

extension ASCredentialServiceIdentifier {
  func hashedDomainForLogs() -> Definition.Domain {
    guard let data = self.identifier.data(using: .utf8) else {
      return .init(id: "", type: .web)
    }
    let hashedCredential = Data(SHA256.hash(data: data))
    return Definition.Domain(
      id: hashedCredential.hexadecimalString,
      type: .web)
  }
}
