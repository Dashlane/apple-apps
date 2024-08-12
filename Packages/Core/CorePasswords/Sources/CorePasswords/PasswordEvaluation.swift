import Foundation
import ZXCVBN

public typealias PasswordStrength = PasswordStrengthScore

extension PasswordStrengthScore {
  public var score: Int {
    return self.rawValue
  }

  public var percentScore: Int {
    return self.rawValue * 25
  }

  public var isWeak: Bool {
    return self < .somewhatGuessable
  }
}
