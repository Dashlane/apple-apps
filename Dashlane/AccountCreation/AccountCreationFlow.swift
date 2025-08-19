import CoreTypes
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

      case let .create(type):
        switch type {
        case let .masterPassword(email, isB2BAccount):
          RegularAccountCreationFlow(
            model: model.makeRegularAccountCreationFlowViewModel(
              email: email, isB2BAccount: isB2BAccount))

        case let .sso(email, info):
          SSOAccountCreationFlow(
            viewModel: model.makeSSOAccountCreationFlowViewModel(email: email, info: info))

        }

      }
    }
  }

}
