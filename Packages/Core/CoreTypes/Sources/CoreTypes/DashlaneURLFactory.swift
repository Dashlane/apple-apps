import Foundation

public struct DashlaneURLFactory {

  public static let websiteRootURL = URL(string: "_\(Self.language)")!

  public enum Endpoint: String {
    case getPremium = "/getpremium"
    case tos = "/terms"
    case privacy = "/privacy"
    case privacySettings = "/privacy/settings"
    case gettingStarted = "/gettingstartedv2"

    public var url: URL { websiteRootURL.appendingPathComponent(self.rawValue) }
  }

  private static let websiteSupportedLanguages = [
    "en",
    "fr",
    "es",
    "de",
    "pt-br",
    "pt-pt",
    "it",
    "nl",
    "sv",
    "ja",
    "zh",
    "ko",
  ]

  public static var cannotLogin: URL {
    return URL(string: "_")!
  }

  public static var forgotPassword: URL {
    return URL(string: "_")!
  }

  public static var ssoEnabled: URL {
    return URL(string: "_")!
  }

  public static var aboutAuthenticator: URL {
    return URL(string: "_")!
  }

  public static var twoFARecovery: URL {
    return URL(string: "_")!
  }

  public static var request: URL {
    return URL(string: "_")!
  }

  public static var resetAccountInfo: URL {
    return URL(string: "_")!
  }

  public static var accountRecoveryInfo: URL {
    return URL(string: "_")!
  }

  public static var learnMoreAboutFrozenAccounts: URL {
    return URL(string: "_")!
  }

  public static var cantAccessPasswordlessAccount: URL {
    return URL(string: "_")!
  }

  private static var language: String {
    if websiteSupportedLanguages.contains(NSLocale.current.identifier) {
      return NSLocale.current.identifier
    } else if websiteSupportedLanguages.contains(System.language) {
      return System.language
    } else {
      return "en"
    }
  }
}
