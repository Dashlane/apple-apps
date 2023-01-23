import UIKit
import SwiftTreats

extension UIModalPresentationStyle {
    static var adaptiveFormSheetOrFullscreen: UIModalPresentationStyle {
        Device.isIpadOrMac ? .formSheet : .overFullScreen
    }
}
