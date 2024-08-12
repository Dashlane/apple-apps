import Foundation

extension Bundle {
  public func appVersion() -> String? {
    guard let infoPlist = infoDictionary,
      let shortVersion = infoPlist["CFBundleShortVersionString"] as? String,
      let version = infoPlist["CFBundleVersion"] as? String
    else {
      return nil
    }
    return shortVersion + "." + version
  }
}
