import Foundation

public struct Application {
  static let defaultAppVersion: String = {
    let date = Date()
    let week = Calendar.current.component(.weekOfYear, from: date)
    let year = Calendar.current.component(.year, from: date) - 2000
    return "6.\(year)\(String(format: "%02d", week)).0"
  }()

  public static func version() -> String {
    #if DEBUG
      if let version = ProcessInfo.processInfo.environment["appVersion"] {
        return version
      }

      let bundle: Bundle = Bundle(for: BundleClass.self)
    #else
      let bundle: Bundle = .main
    #endif

    return bundle.appVersion() ?? defaultAppVersion
  }

  public static func versionBuildOriginInformation() -> String? {

    guard let infoPlist = Bundle.main.infoDictionary,
      let info = infoPlist["DLBuildInformationDetails"] as? String
    else {
      return nil
    }
    return info
  }
}

private class BundleClass {}
