#if canImport(UIKit)
import UIKit
#endif
import DashTypes

public struct Authenticator {
    public static var isOnDevice: Bool {
        #if canImport(UIKit)
        return UIApplication.shared.canOpenURL(URLScheme.authenticator.url)
        #else
        return false
        #endif
    }
}
