import SwiftTreats
import UIKit

extension UIModalPresentationStyle {
  static var adaptiveFormSheetOrFullscreen: UIModalPresentationStyle {
    Device.is(.pad, .mac, .vision) ? .formSheet : .overFullScreen
  }
}
