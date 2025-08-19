import CoreFeature
import CoreLocalization
import CorePasswords
import DesignSystem
import SwiftUI
import UIDelight

public struct PasswordSlotMachine: View {
  let passwordStrength: PasswordStrength
  let password: String
  let refreshAction: () -> Void

  @FeatureState(.prideColors)
  private var isPrideColorsEnabled: Bool

  public var body: some View {
    VStack(spacing: 0) {
      HStack(alignment: .center, spacing: 22) {
        SlotMachineText(password: password)
          .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
          .accessibilityLabel(CoreL10n.generatedPassword)
          .accessibility(identifier: password)

        RefreshButton(action: refreshAction)
          .accessibility(label: Text(CoreL10n.kwPadExtensionGeneratorRefresh))
          .foregroundStyle(Color.ds.text.brand.standard)

      }.frame(maxHeight: .infinity)

      TextInputPasswordStrengthFeedback(
        strength: passwordStrength.textFieldPasswordStrengthFeedbackStrength,
        colorful: isPrideColorsEnabled
      )
      .animation(.default, value: passwordStrength)
    }
    .buttonStyle(PlainButtonStyle())
  }
}

extension PasswordSlotMachine {
  public init(viewModel: PasswordGeneratorViewModel) {
    password = viewModel.password
    passwordStrength = viewModel.passwordStrength
    refreshAction = viewModel.refresh
  }
}

extension PasswordStrength {
  fileprivate var textFieldPasswordStrengthFeedbackStrength:
    TextInputPasswordStrengthFeedback.Strength
  {
    switch self {
    case .tooGuessable:
      return .weakest
    case .veryGuessable:
      return .weak
    case .somewhatGuessable:
      return .acceptable
    case .safelyUnguessable:
      return .good
    case .veryUnguessable:
      return .strong
    }
  }
}

struct PasswordGeneratorGeneratedCredentialView_Previews: PreviewProvider {
  static var previews: some View {
    PasswordSlotMachine(viewModel: .mock)
  }
}
