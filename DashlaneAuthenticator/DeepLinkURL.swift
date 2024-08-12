import Foundation
import UIKit

enum DeeplinkURL {
  case passwordApp
  case passwordAppSettings
  case appStorePasswordApp
  case dashlanepasswordAppAccountCreation
  case securitySettings
  case vaultItemEdition(String)

  var rawValue: String {
    switch self {
    case .passwordApp:
      return "dashlane:///"
    case .passwordAppSettings:
      return "dashlane:///settings"
    case .appStorePasswordApp:
      return "itms-apps://itunes.apple.com/app/id517914548"
    case .dashlanepasswordAppAccountCreation:
      return "dashlane:///accountCreationFromAuthenticator"
    case .securitySettings:
      return "dashlane:///settings/security"
    case let .vaultItemEdition(id):
      return "dashlane:///passwords/\(id)/edit"
    }
  }
}

extension UIApplication {
  func open(_ deeplink: DeeplinkURL) {
    guard let url = URL(string: deeplink.rawValue) else {
      assertionFailure()
      return
    }
    open(url)
  }
}
