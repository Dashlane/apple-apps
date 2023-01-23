#if !os(macOS) && !EXTENSION

import UIKit

public extension UIApplication {
    func openSettings(completion: ((Bool) -> Void)? = nil) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        open(url, completionHandler: completion)
    }
}

#endif
