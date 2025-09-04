#if canImport(UIKit)
  import UIKit

  extension UIApplication {
    public static var applicationWillResignActiveNotification: Notification.Name {
      #if targetEnvironment(macCatalyst)
        return .macOSDidResignActive
      #else
        return UIApplication.willResignActiveNotification
      #endif

    }

    public static var applicationWillEnterForegroundNotification: Notification.Name {
      #if targetEnvironment(macCatalyst)
        return .macOSDidBecomeActive
      #else
        return UIApplication.willEnterForegroundNotification
      #endif
    }
  }

  extension Notification.Name {

    public static var macOSDidResignActive: Self {
      return .init("NSApplicationDidResignActiveNotification")
    }

    public static var macOSDidBecomeActive: Self {
      return .init("NSApplicationDidBecomeActiveNotification")
    }
  }
#endif
