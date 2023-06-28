import SwiftUI
import UIDelight
import UIComponents
import DesignSystem
import DashTypes
import SwiftTreats
import LoginKit

struct AccountCreationFlow: View {
    @StateObject
    var model: AccountCreationFlowViewModel

    init(model: @autoclosure @escaping () -> AccountCreationFlowViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $model.steps) { step in
            switch step {
            case .email:
                AccountEmailView(model: model.makeEmailViewModel())

            case let .masterPassword(email):
                NewMasterPasswordView(model: model.makeNewPasswordModel(email: email), title: "") {
                    if (BuildEnvironment.current.isNightly || BuildEnvironment.current == .debug) && !Device.isMac {
                        RoundedButton(L10n.Localizable.NewMasterPassword.skipMasterPasswordButton) {
                            model.startPasswordLess(email: email)
                        }
                        .roundedButtonLayout(.fill)
                        .style(mood: .brand, intensity: .quiet)
                        .controlSize(.large)
                    }
                }

            case let .create(configuration):
                switch configuration.accountType {
                case .masterPassword:
                    MasterPasswordAccountCreationFlow(model: model.makeMasterPasswordAccountCreationFlow(configuration: configuration))

                case .invisibleMasterPassword:
                    PasswordLessAccountCreationFlow(model: model.makePasswordLessAccountCreationFlow(configuration: configuration))
                }

            }
        }
    }

}

extension AccountCreationFlow: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        .transparent(tintColor: .ds.text.neutral.standard, statusBarStyle: .default)
    }
}
