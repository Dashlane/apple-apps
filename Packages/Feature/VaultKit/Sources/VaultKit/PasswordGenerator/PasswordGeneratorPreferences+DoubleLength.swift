import Foundation
import CoreSettings

public extension PasswordGeneratorPreferences {
    var doubleLength: Double {
        get {
            Double(length)
        }
        set {
            length = Int(newValue)
        }
    }
}
