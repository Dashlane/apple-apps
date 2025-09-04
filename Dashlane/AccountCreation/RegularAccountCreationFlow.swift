import CoreTypes
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct RegularAccountCreationFlow: View {

  @StateObject
  var model: RegularAccountCreationFlowViewModel

  init(model: @autoclosure @escaping () -> RegularAccountCreationFlowViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {

      case let .masterPassword(email, isB2BAccount):
        NewMasterPasswordView(model: model.makeNewPasswordModel(email: email), title: "") {
          if !isB2BAccount {
            Button(L10n.Localizable.NewMasterPassword.skipMasterPasswordButton) {
              Task {
                await model.startPasswordLess(email: email)
              }
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

        case .securityKey, .undecodable:
          fatalError("Unsupported account type")
        }

      }
    }
  }

}
