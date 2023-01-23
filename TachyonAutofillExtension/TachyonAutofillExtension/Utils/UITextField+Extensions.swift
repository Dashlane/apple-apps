import Foundation
import UIKit

extension UITextField {
    @IBInspectable var placeholderLocalizationKey: String? {
        get { return nil }
        set {
            guard let localizationKey = newValue else { return }
            self.placeholder = NSLocalizedString(localizationKey, comment: "")
        }
    }
}
