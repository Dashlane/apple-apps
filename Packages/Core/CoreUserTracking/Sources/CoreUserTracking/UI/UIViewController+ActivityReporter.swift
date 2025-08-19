import CoreTypes
import Foundation
import UIKit
import UserTrackingFoundation

extension UIViewController {
  public func reportPageAppearance(_ page: Page) {
    ReportActionKey.defaultValue?(page)
  }
}
