import Foundation

public extension Bundle {
    func appVersion() -> String? {
        guard let infoPlist = infoDictionary,
            let shortVersion = infoPlist["CFBundleShortVersionString"] as? String,
            let version = infoPlist["CFBundleVersion"] as? String else {
                return nil
        }
        return shortVersion + "." + version
    }
}
