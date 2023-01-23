import SwiftUI
import CorePasswords
import UIDelight

struct PasswordSlotMachine: View {
    let passwordStrength: PasswordStrength
    let password: String
    let refreshAction: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 22) {
                SlotMachineText(password: password)
                    .frame(maxWidth: .infinity, minHeight: 110, alignment: .leading)
                    .fiberAccessibilityLabel(Text(L10n.Localizable.kwPadExtensionGeneratorGeneratedAccessibility))
                    .accessibility(identifier: password)
                RefreshButton(action: refreshAction)
                    .accessibility(label: Text(L10n.Localizable.kwPadExtensionGeneratorRefresh))
                    .foregroundColor(Color(asset: SharedAsset.passwordGeneratorRefreshButtonColor))

                
            }.frame(maxHeight: .infinity)
            
            PasswordStrengthDetailField(passwordStrength: passwordStrength)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

extension PasswordSlotMachine {
    init(viewModel: PasswordGeneratorViewModel) {
        password = viewModel.password
        passwordStrength = viewModel.passwordStrength
        refreshAction =  viewModel.refresh
    }
}

struct PasswordGeneratorGeneratedCredentialView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordSlotMachine(viewModel: .mock)
    }
}
