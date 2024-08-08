import AuthenticationServices
import CoreUserTracking
import CryptoKit
import Foundation

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
