import Foundation
import DashlaneAppKit
import CoreSettings

extension PasswordGeneratorPreferences {
    var doubleLength: Double {
        set {
            length = Int(newValue)
        }
        get {
            Double(length)
        }
    }
}
