import CoreFeature
import CorePasswords
import SwiftUI
import UIDelight

struct PasswordStrengthDetailField: View {
  let passwordStrength: PasswordStrength

  @FeatureState(.prideColors)
  var isPrideColorsEnabled: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      if isPrideColorsEnabled {
        PrideProgressBarView(passwordStrength: passwordStrength)
      } else {
        ProgressBarView(passwordStrength: passwordStrength)
      }

      Text(passwordStrength.funFact)
        .foregroundColor(.ds.text.inverse.standard)
        .font(passwordStrengthFont)
        .transition(AnyTransition.scale(scale: 1.1).combined(with: .opacity))
        .id(passwordStrength.funFact)
    }.animation(.easeOut(duration: 0.5), value: passwordStrength)
  }

  var passwordStrengthFont: Font {
    return Font.caption
  }
}

struct PasswordStrengthDetailField_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      PasswordStrengthDetailField(passwordStrength: .safelyUnguessable)
      PasswordStrengthDetailField(passwordStrength: .somewhatGuessable)
      PasswordStrengthDetailField(passwordStrength: .tooGuessable)
      PasswordStrengthDetailField(passwordStrength: .veryGuessable)
      PasswordStrengthDetailField(passwordStrength: .veryUnguessable)

    }.previewLayout(.sizeThatFits)
  }
}
