import Foundation
import SwiftUI

#if os(macOS)
import Cocoa

public extension NSColor {
    func isBorderRequired() -> Bool {
        cgColor.isBorderRequired()
    }
}

#else
import UIKit

public extension UIColor {
    func isBorderRequired() -> Bool {
        cgColor.isBorderRequired()
    }
}
#endif

private extension CGColor {
    func isBorderRequired() -> Bool {
        guard let components = components else {
            return false
        }
        
                let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000
        return brightness > 0.85
    }
}
