import Foundation
#if canImport(UIKit)
import UIKit
#endif

public struct System {

    public static var language: String {
        return NSLocale.current.languageCode ?? "en"
    }

    public static var country: String {
        return NSLocale.current.regionCode ?? "US"
    }
    
        public static var languageCountry: String {
        return "\(language)-\(country)"
    }
    
    public static var version: String {
        let os = ProcessInfo.processInfo.operatingSystemVersion
        var versionComponents = [os.majorVersion, os.minorVersion]
        if os.patchVersion != 0 {
            versionComponents.append(os.patchVersion)
        }
        return versionComponents.map(String.init).joined(separator: ".")
    }
    
        public static var systemName: String {
        #if os(macOS) || targetEnvironment(macCatalyst)
        return "macOS"
        #else
        return UIDevice.current.systemName
        #endif
    }
}
