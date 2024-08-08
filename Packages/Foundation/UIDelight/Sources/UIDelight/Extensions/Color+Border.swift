#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIKit

  extension UIColor {
    public func isBorderRequired() -> Bool {
      cgColor.isBorderRequired()
    }
  }

  extension CGColor {
    fileprivate func isBorderRequired() -> Bool {
      guard let components = components else {
        return false
      }

      let brightness =
        ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
      return brightness > 0.85
    }
  }
#endif
