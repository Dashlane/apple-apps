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
  case authenticator
  case darkWebMonitoring
  case otherTool(OtherToolDeepLinkComponent)
  case unresolvedAlert(TrayAlertProtocol)

  init?(components: [String]) {
    if components[0] == Self.identityDashboard.rawDeeplink || components[0] == "password-health" {
      self = .identityDashboard
    } else if let otherToolDeeplinkComponent = OtherToolDeepLinkComponent(rawValue: components[0]) {
      self = .otherTool(otherToolDeeplinkComponent)
    } else if components[0] == Self.darkWebMonitoring.rawDeeplink {
      self = .darkWebMonitoring
    } else if components[0] == Self.authenticator.rawDeeplink {
      self = .authenticator
    } else {
      return nil
    }
  }
}

extension ToolDeepLinkComponent {
  var rawDeeplink: String {
    switch self {
    case .identityDashboard:
      return "security-dashboard"
    case let .otherTool(component):
      return component.rawDeeplink
    case .unresolvedAlert:
      return "unresolved-alert"
    case .darkWebMonitoring:
      return "dark-web-monitoring"
    case .authenticator: return "authenticator"

    }
  }
}
