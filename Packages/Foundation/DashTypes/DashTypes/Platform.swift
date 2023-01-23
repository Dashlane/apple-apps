import Foundation

#if canImport(UIKit)
import UIKit
#endif

public enum Platform: String, Encodable {
    case passwordManagerIphone = "server_iphone"
    case passwordManagerIpad = "server_ipad"
    case passwordManagerMac = "server_catalyst"
    case authenticatorIOS = "authenticator_ios"
    
    public static var passwordManager: Platform {
#if os(macOS) || targetEnvironment(macCatalyst)
        return .passwordManagerMac
#else
        let isIpad = UIDevice.current.userInterfaceIdiom == .pad
        return isIpad ? .passwordManagerIpad : .passwordManagerIphone
#endif
    }

    public static var authenticator: Platform {
        return .authenticatorIOS
    }
}
