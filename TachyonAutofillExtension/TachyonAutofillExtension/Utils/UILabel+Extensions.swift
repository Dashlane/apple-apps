import Foundation
import UIKit

extension UILabel {
  @IBInspectable var localizationKey: String? {
    get { return nil }
    set {
      guard let localizationKey = newValue else { return }
      self.text = NSLocalizedString(localizationKey, comment: "")
    }
  }
}
