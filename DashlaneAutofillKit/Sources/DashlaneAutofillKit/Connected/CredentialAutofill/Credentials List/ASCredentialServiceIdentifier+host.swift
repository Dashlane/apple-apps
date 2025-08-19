import AuthenticationServices
import Foundation

extension ASCredentialServiceIdentifier {

  var host: String? {
    switch self.type {
    case .URL:
      return URL(string: self.identifier)?.host
    case .domain:
      return self.identifier
    @unknown default:
      assertionFailure("A new Identifier type has been introduced, please implement this")
      return nil
    }
  }
}
