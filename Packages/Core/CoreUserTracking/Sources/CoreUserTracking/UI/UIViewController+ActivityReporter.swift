import DashTypes
import Foundation

#if canImport(UIKit)
  import UIKit

  extension UIViewController {
    public func reportPageAppearance(_ page: Page) {
      ReportActionKey.defaultValue?(page)
    }
  }

#endif
