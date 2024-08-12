import CorePersonalData
import CorePremium
import DashTypes
import Foundation
import LoginKit
import PremiumKit
import VaultKit

enum DeepLink {
  enum Parameter: String {
    case origin
    case search = "query"
  }

  case vault(VaultDeeplink)
  case tool(ToolDeepLinkComponent, origin: String? = nil)
  case premium(PremiumDeepLinkComponent)
  case search(String)
  case prefilledCredential(password: GeneratedPassword)
  case other(OtherDeepLinkComponent, origin: String? = nil)
  case token(String? = nil)
  case userNotConnected(UserNotConnectedDeepLink)
  case importMethod(ImportMethodDeeplink)
  case notifications(NotificationCategory?)
  case settings(SettingsDeepLinkComponent)
  case mplessLogin(qrCode: String)

  init?(pathComponents: [String], queryParameters: [String: String]? = nil, origin: String?) {
    let pathComponent = pathComponents[0]
    if let otherSection = OtherDeepLinkComponent(rawValue: pathComponent) {
      self = .other(otherSection, origin: origin)
    } else if let passwordTool = ToolDeepLinkComponent(components: pathComponents) {
      self = .tool(passwordTool, origin: origin)
    } else if let premium = PremiumDeepLinkComponent(
      pathComponents: pathComponents, queryParameters: queryParameters)
    {
      self = .premium(premium)
    } else if let vaultItemComponent = VaultDeepLinkComponent(rawValue: pathComponent) {

      switch pathComponents.count {
      case 1:
        self = .vault(.list(vaultItemComponent.category))

      case 2:
        if let action = ItemActionDeepLinkComponent(rawValue: pathComponents[1]) {
          guard action == .create else {
            return nil
          }
          self = .vault(.create(vaultItemComponent))
        } else {
          self = .vault(
            .fetchAndShow(
              .init(rawIdentifier: pathComponents[1], component: vaultItemComponent),
              useEditMode: false))
        }
      case 3:
        guard let action = ItemActionDeepLinkComponent(rawValue: pathComponents[2]), action == .edit
        else {
          return nil
        }

        self = .vault(
          .fetchAndShow(
            .init(rawIdentifier: pathComponents[1], component: vaultItemComponent),
            useEditMode: true))
      default:
        return nil
      }
    } else if let settings = SettingsDeepLinkComponent(
      pathComponents: pathComponents, queryParameters: queryParameters)
    {
      self = .settings(settings)
    } else if let userNotConnected = UserNotConnectedDeepLink(
      pathComponents: pathComponents, queryParameters: queryParameters)
    {
      self = .userNotConnected(userNotConnected)
    } else if let importMethod = ImportMethodDeeplink(
      pathComponents: pathComponents, queryParameters: queryParameters)
    {
      self = .importMethod(importMethod)
    } else {
      return nil
    }
  }

  init?(url: URL) {
    if let query = url.queryParameters?.first(where: { $0.key == Parameter.search.rawValue }) {
      self = .search(query.value)
      return
    }

    if url.absoluteString.contains("mplesslogin") {
      self = .mplessLogin(qrCode: url.absoluteString)
      return
    }
    let components = url.pathComponents.filter {
      return $0 != "/" && !DashTypes.Email($0).isValid
    }

    guard components.count > 0 else {
      return nil
    }

    let origin = url.queryParameters?.first { $0.key == Parameter.origin.rawValue }?.value

    self.init(pathComponents: components, queryParameters: url.queryParameters, origin: origin)
  }

  init?(userActivityDeepLink: String) {
    let pathComponents = userActivityDeepLink.split(separator: "/").map(String.init)
    self.init(pathComponents: pathComponents, origin: nil)
  }
}

enum OtherDeepLinkComponent: String {
  case gettingStarted = "getting-started"
  case contacts = "contacts"
  case sharing = "sharing"
  case devices
  case dashboard
  case m2wOnboarding = "m2d-onboarding"
}

enum PremiumDeepLinkComponent {
  case getPremium
  case planPurchase(initialView: PlanPurchaseInitialViewRequest)

  init?(pathComponents: [String], queryParameters: [String: String]?) {
    var components = pathComponents
    guard !components.isEmpty, components.removeFirst() == "getpremium" else { return nil }
    if let paywallValue = queryParameters?["paywall"],
      let capability = CapabilityKey(rawValue: paywallValue)
    {
      self = .planPurchase(initialView: .paywall(trigger: .capability(key: capability)))
    } else {
      self = .getPremium
    }
  }
}

enum SettingsDeepLinkComponent {
  case root
  case security(SecurityComponent?)

  enum SecurityComponent {
    case enableResetMasterPassword
    case recoveryKey
  }

  init?(pathComponents: [String], queryParameters: [String: String]?) {
    var components = pathComponents
    guard !components.isEmpty, components.removeFirst() == "settings" else { return nil }
    guard let firstComponent = components.first else {
      self = .root
      return
    }
    switch firstComponent {
    case "security":
      _ = components.removeFirst()
      switch components.first {
      case "master-password-reset":
        self = .security(.enableResetMasterPassword)
      default:
        self = .security(nil)
      }
    default:
      return nil
    }
  }

  var rawValue: String {
    let base = "settings"
    switch self {
    case .root:
      return base
    case let .security(component):
      let security = "security"
      switch component {
      case .enableResetMasterPassword:
        return "master-password-reset"
      default:
        return security
      }

    }
  }
}

extension URL {
  fileprivate var queryParameters: [String: String]? {
    guard
      let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
      let queryItems = components.queryItems
    else { return nil }
    return queryItems.reduce(into: [String: String]()) { (result, item) in
      result[item.name] = item.value
    }
  }
}

extension DeepLink {

  var urlRepresentation: URL? {
    let link: String?
    switch self {
    case let .vault(vaultLink):
      link = vaultLink.rawDeeplink
    case let .search(search):
      link = "search?query=\(search)"
    case .token:
      assertionFailure("No representation")
      link = nil
    case let .tool(component, origin):
      if let origin = origin {
        link = "\(component.rawDeeplink)/?\(Parameter.origin.rawValue)=\(origin)"
      } else {
        link = component.rawDeeplink
      }
    case .premium:
      link = "getpremium"
    case .prefilledCredential:
      assertionFailure("No representation")
      link = nil
    case let .other(component, origin):
      if let origin = origin {
        link = "\(component.rawValue)?\(Parameter.origin.rawValue)=\(origin)"
      } else {
        link = component.rawValue
      }
    case let .userNotConnected(component):
      link = component.rawValue
    case let .importMethod(component):
      link = component.rawValue
    case let .notifications(category):
      if let category = category {
        link = "notifications/\(category.rawValue)"
      } else {
        link = "notifications"
      }
    case let .settings(component):
      link = component.rawValue
    case let .mplessLogin(info):
      link = info.replacingOccurrences(of: "dashlane:///", with: "")
    }

    guard let unwrapped = link else { return nil }
    return URL(string: "dashlane:///\(unwrapped)")
  }
}
