import CoreSettings
import Foundation

extension PasswordGeneratorPreferences {
  public var doubleLength: Double {
    get {
      Double(length)
    }
    set {
      length = Int(newValue)
    }
  }
}
