import AuthenticationServices
import AutofillKit
import Foundation

enum CredentialsListRequest {
  case legacy([ASCredentialServiceIdentifier])
  case servicesAndPasskey(
    servicesIdentifiers: [ASCredentialServiceIdentifier],
    passkeyAssertionRequest: PasskeyAssertionRequest)

  var services: [ASCredentialServiceIdentifier] {
    switch self {
    case let .legacy(identifiers):
      return identifiers
    case let .servicesAndPasskey(identifiers, _):
      return identifiers
    }
  }
}
