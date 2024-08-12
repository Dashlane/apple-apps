import Foundation

struct AuthenticatorRegistrationInfo {
  let identityProvider: String
  let user: String
  let registrationToken: String

  init?(qrCode: URL) {
    guard let components = URLComponents(url: qrCode, resolvingAgainstBaseURL: false),
      let identityProvider = components.queryItems?["identityProvider"],
      let user = components.queryItems?["user"],
      let registrationToken = components.queryItems?["registrationToken"]
    else {
      return nil
    }

    self.identityProvider = identityProvider
    self.user = user
    self.registrationToken = registrationToken
  }
}

extension Sequence where Iterator.Element == URLQueryItem {
  subscript(name: String) -> String? {
    return self.first { $0.name == name }?.value
  }
}
