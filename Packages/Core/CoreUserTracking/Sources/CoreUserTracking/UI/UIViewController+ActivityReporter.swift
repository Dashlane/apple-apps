import Foundation
import DashTypes

#if canImport(UIKit)
import UIKit

extension UIViewController {
    public func reportPageAppearance(_ page: Page) {
        ReportActionKey.defaultValue?(page)
    }
}

#endif
