import SwiftTreats
import UIKit

extension UIModalPresentationStyle {
  static var adaptiveFormSheetOrFullscreen: UIModalPresentationStyle {
    Device.isIpadOrMac ? .formSheet : .overFullScreen
  }
}
