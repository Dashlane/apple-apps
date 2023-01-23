import Foundation
import UIKit

extension UIButton {
    @IBInspectable var localizationKey: String? {
        get { return nil }
        set {
            guard let localizationKey = newValue else { return }
            self.setTitle(NSLocalizedString(localizationKey, comment: ""), for: .normal)
        }
    }
}
