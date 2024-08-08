import Foundation

public struct PrefilledCredentials {

  private static let baseList: [PrefilledCredential] = [
    PrefilledCredential(title: "Facebook", url: "_"),
    PrefilledCredential(title: "Amazon", url: "_"),
    PrefilledCredential(title: "Linkedin", url: "_"),
    PrefilledCredential(title: "Outlook", url: "_"),
    PrefilledCredential(title: "Pinterest", url: "_"),
    PrefilledCredential(title: "Gmail", url: "_"),
    PrefilledCredential(title: "Twitter", url: "_"),
    PrefilledCredential(title: "Yahoo", url: "_"),
    PrefilledCredential(title: "Dropbox", url: "_"),
    PrefilledCredential(title: "Instagram", url: "_"),
  ]

  private static var englishList: [PrefilledCredential] {
    baseList + [
      PrefilledCredential(title: "CHASE Bank", url: "_"),
      PrefilledCredential(title: "American Express", url: "_"),
    ]
  }

  private static var frenchList: [PrefilledCredential] {
    baseList + [
      PrefilledCredential(title: "Vente Privée", url: "_"),
      PrefilledCredential(title: "Cdiscount", url: "_"),
    ]
  }

  public static func all() -> [PrefilledCredential] {
    switch Locale.current.language.languageCode?.identifier {
    case "fr":
      return frenchList
    default:
      return englishList
    }
  }
}

extension PrefilledCredential {
  init(title: String, url: String) {
    self.init(
      title: title,
      url: url,
      category: "")
  }
}
