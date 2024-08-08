#if canImport(UIKit)
  import UIKit

  extension UIApplication {
    public func openSettings(completion: ((Bool) -> Void)? = nil) {
      guard let url = URL(string: UIApplication.openSettingsURLString) else {
        return
      }
      open(url, completionHandler: completion)
    }
  }
#endif
