import CoreLocalization
import CorePasswords
import DesignSystem
import SwiftUI

extension Color {
  public init(passwordStrength: PasswordStrength) {
    switch passwordStrength.score {
    case 0..<2:
      self = .ds.text.danger.standard
    case 2..<3:
      self = .ds.text.warning.standard
    default:
      self = .ds.text.positive.standard
    }
  }
}

extension CoreL10n {
  public static func passwordDetailText(for passwordStrength: PasswordStrength) -> String {
    switch passwordStrength {
    case .tooGuessable:
      return CoreL10n.securityDashboardStrengthTrivial
    case .veryGuessable:
      return CoreL10n.securityDashboardStrengthWeak
    case .somewhatGuessable:
      return CoreL10n.kwPasswordNotSoSafe
    case .safelyUnguessable:
      return CoreL10n.kwPasswordSafe
    case .veryUnguessable:
      return CoreL10n.kwPasswordSuperSafe
    }
  }
}

extension ProgressBarView {
  init(
    passwordStrength: PasswordStrength,
    backgroundColor: Color = .ds.text.inverse.standard
  ) {
    self.init(
      progress: CGFloat(passwordStrength.score) + 1,
      total: 5,
      fillColor: Color(passwordStrength: passwordStrength),
      backgroundColor: backgroundColor)
  }
}

extension PrideProgressBarView {
  init(
    passwordStrength: PasswordStrength,
    backgroundColor: Color = .ds.text.inverse.standard
  ) {
    self.init(
      progress: CGFloat(passwordStrength.score) + 1,
      total: 5,
      fillColor: Color(passwordStrength: passwordStrength),
      backgroundColor: backgroundColor)
  }
}
