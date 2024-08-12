import Foundation

#if canImport(UIKit)
  import UIKit
#endif

public struct System {

  public static var language: String {
    NSLocale.current.language.languageCode?.identifier ?? "en"
  }

  public static var country: String {
    NSLocale.current.language.region?.identifier ?? "US"
  }

  public static var languageCountry: String {
    return "\(language)-\(country)"
  }

  public static var version: String {
    let osVersion = ProcessInfo.processInfo.operatingSystemVersion
    var versionComponents = [osVersion.majorVersion, osVersion.minorVersion]
    if osVersion.patchVersion != 0 {
      versionComponents.append(osVersion.patchVersion)
    }
    return versionComponents.map(String.init).joined(separator: ".")
  }

  public static var systemName: String {
    #if targetEnvironment(macCatalyst)
      return "macOS"
    #else
      return UIDevice.current.systemName
    #endif
  }
}
