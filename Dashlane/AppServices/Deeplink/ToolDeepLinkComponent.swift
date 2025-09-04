import CorePasswords
import Foundation
import SecurityDashboard

enum ToolDeepLinkComponent {
  enum OtherToolDeepLinkComponent: String {
    case generator = "password-generator"
    case history = "password-history"
    case tools
    case vpn
    case contacts

    var rawDeeplink: String {
      return rawValue
    }
  }

  case identityDashboard
  case authenticator(URL? = nil)
  case darkWebMonitoring
  case otherTool(OtherToolDeepLinkComponent)

  init?(components: [String]) {
    if components[0] == Self.identityDashboard.rawDeeplink {
      self = .identityDashboard
    } else if let otherToolDeeplinkComponent = OtherToolDeepLinkComponent(rawValue: components[0]) {
      self = .otherTool(otherToolDeeplinkComponent)
    } else if components[0] == Self.darkWebMonitoring.rawDeeplink
      || components[0] == "security-dashboard"
    {
      self = .darkWebMonitoring
    } else if components[0] == Self.authenticator().rawDeeplink {
      self = .authenticator()
    } else {
      return nil
    }
  }
}

extension ToolDeepLinkComponent {
  var rawDeeplink: String {
    switch self {
    case .identityDashboard:
      return "password-health"
    case let .otherTool(component):
      return component.rawDeeplink
    case .darkWebMonitoring:
      return "dark-web-monitoring"
    case .authenticator: return "authenticator"

    }
  }
}
