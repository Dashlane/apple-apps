#if os(iOS)
import UIKit

public extension UIUserInterfaceIdiom {
    var isIpadOrMac: Bool {
        switch self {
            case .mac, .pad:
                return true
            default:
                return false
        }
    }
}

#endif
