import Foundation
import UIKit

extension UIBarButtonItem {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set {
            guard let localizationKey = newValue else { return }
            self.title = NSLocalizedString(localizationKey, comment: "")
        }
    }
}
