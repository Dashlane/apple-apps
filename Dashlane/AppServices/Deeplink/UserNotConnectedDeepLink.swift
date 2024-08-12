enum UserNotConnectedDeepLink {
  case accountCreationFromAuthenticator
  case accountAuthenticationToken(String)

  var rawValue: String {
    switch self {
    case .accountCreationFromAuthenticator:
      return "accountCreationFromAuthenticator"
    case .accountAuthenticationToken(let token):
      return "login?token=\(token)"
    }
  }

  init?(pathComponents: [String], queryParameters: [String: String]?) {
    if pathComponents.contains("accountCreationFromAuthenticator") {
      self = .accountCreationFromAuthenticator
      return
    }

    if pathComponents.contains("login"), let token = queryParameters?["token"] {
      self = .accountAuthenticationToken(token)
      return
    }

    return nil
  }
}
