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

extension L10n.Core {
  public static func passwordDetailText(for passwordStrength: PasswordStrength) -> String {
    switch passwordStrength {
    case .tooGuessable:
      return L10n.Core.securityDashboardStrengthTrivial
    case .veryGuessable:
      return L10n.Core.securityDashboardStrengthWeak
    case .somewhatGuessable:
      return L10n.Core.kwPasswordNotSoSafe
    case .safelyUnguessable:
      return L10n.Core.kwPasswordSafe
    case .veryUnguessable:
      return L10n.Core.kwPasswordSuperSafe
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
