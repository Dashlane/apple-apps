import AuthenticationServices
import AutofillKit
import Foundation
import VaultKit

struct CredentialsListRequest {
  enum RequestType {
    case passwords
    case passkeysAndPasswords(request: PasskeyAssertionRequest)
    case otps
  }

  let servicesIdentifiers: [ASCredentialServiceIdentifier]
  let type: RequestType
}
