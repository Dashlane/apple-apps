#if canImport(UIKit)

import Foundation
import UIKit

public extension UIApplication {
                    static var applicationWillResignActiveNotification: Notification.Name {
#if targetEnvironment(macCatalyst)
        return .macOSDidResignActive
#else
        return UIApplication.willResignActiveNotification
#endif

    }

                    static var applicationWillEnterForegroundNotification: Notification.Name {
#if targetEnvironment(macCatalyst)
        return .macOSDidBecomeActive
#else
        return UIApplication.willEnterForegroundNotification
#endif
    }
}

public extension Notification.Name {

    static var macOSDidResignActive: Self {
        return .init("NSApplicationDidResignActiveNotification")
    }

    static var macOSDidBecomeActive: Self {
        return .init("NSApplicationDidBecomeActiveNotification")
    }
}
#endif
