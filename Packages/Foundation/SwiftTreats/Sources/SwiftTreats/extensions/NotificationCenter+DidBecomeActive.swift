import Foundation
#if os(iOS)
import UIKit
#endif


extension NotificationCenter {
    public func didBecomeActiveNotificationPublisher() -> Publisher? {
        #if os(iOS)
        return NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
        #else
        return nil
        #endif
    }
}
