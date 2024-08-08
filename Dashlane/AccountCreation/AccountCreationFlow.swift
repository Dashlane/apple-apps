import DashTypes
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

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

      case let .masterPassword(email, isB2BAccount):
        NewMasterPasswordView(model: model.makeNewPasswordModel(email: email), title: "") {
          if !isB2BAccount {
            Button(L10n.Localizable.NewMasterPassword.skipMasterPasswordButton) {
              model.startPasswordLess(email: email)
            }
            .buttonStyle(.designSystem(.titleOnly))
            .style(mood: .brand, intensity: .quiet)
            .controlSize(.large)
          }
        }

      case let .create(configuration):
        switch configuration.accountType {
        case .masterPassword:
          MasterPasswordAccountCreationFlow(
            model: model.makeMasterPasswordAccountCreationFlow(configuration: configuration))

        case .invisibleMasterPassword:
          PasswordLessAccountCreationFlow(
            model: model.makePasswordLessAccountCreationFlow(configuration: configuration))

        case .undecodable:
          EmptyView()
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
