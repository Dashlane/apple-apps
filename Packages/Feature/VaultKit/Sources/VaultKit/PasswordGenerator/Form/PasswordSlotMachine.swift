import SwiftUI
import CorePasswords
import UIDelight
import DesignSystem
import CoreLocalization
import CoreFeature

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
                    .fiberAccessibilityLabel(Text(L10n.Core.kwPadExtensionGeneratorSymbolsAccessibility))
                    .accessibility(identifier: password)
                RefreshButton(action: refreshAction)
                    .accessibility(label: Text(L10n.Core.kwPadExtensionGeneratorRefresh))
                    .foregroundColor(.ds.text.brand.standard)

            }.frame(maxHeight: .infinity)

            TextFieldPasswordStrengthFeedback(strength: passwordStrength.textFieldPasswordStrengthFeedbackStrength,
                                              colorful: isPrideColorsEnabled)
                .animation(.default, value: passwordStrength)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

public extension PasswordSlotMachine {
    init(viewModel: PasswordGeneratorViewModel) {
        password = viewModel.password
        passwordStrength = viewModel.passwordStrength
        refreshAction =  viewModel.refresh
    }
}

private extension PasswordStrength {
    var textFieldPasswordStrengthFeedbackStrength: TextFieldPasswordStrengthFeedback.Strength {
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
