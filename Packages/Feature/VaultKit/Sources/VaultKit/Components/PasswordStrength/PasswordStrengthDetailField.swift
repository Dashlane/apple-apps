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
        .foregroundStyle(Color.ds.text.inverse.standard)
        .font(passwordStrengthFont)
        .transition(AnyTransition.scale(scale: 1.1).combined(with: .opacity))
        .id(passwordStrength.funFact)
    }.animation(.easeOut(duration: 0.5), value: passwordStrength)
  }

  var passwordStrengthFont: Font {
    return Font.caption
  }
}

#Preview("Safely Unguessable", traits: .sizeThatFitsLayout) {
  PasswordStrengthDetailField(passwordStrength: .safelyUnguessable)
}

#Preview("Somewhat Guessable", traits: .sizeThatFitsLayout) {
  PasswordStrengthDetailField(passwordStrength: .somewhatGuessable)
}

#Preview("Too Guessable", traits: .sizeThatFitsLayout) {
  PasswordStrengthDetailField(passwordStrength: .tooGuessable)
}

#Preview("Very Guessable", traits: .sizeThatFitsLayout) {
  PasswordStrengthDetailField(passwordStrength: .veryGuessable)
}

#Preview("Very Unguessable", traits: .sizeThatFitsLayout) {
  PasswordStrengthDetailField(passwordStrength: .veryUnguessable)
}
