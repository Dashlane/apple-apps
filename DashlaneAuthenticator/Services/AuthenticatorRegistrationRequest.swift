import Foundation

public struct AuthenticatorRegistrationRequest {
  let identityProvider: String
  let user: String
  let registrationToken: String
}
