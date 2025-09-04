import CoreLocalization
import Foundation
import SwiftUI
import UIDelight

struct AccountRecoveryKeyLoginFlow: View {

  @StateObject
  var model: AccountRecoveryKeyLoginFlowModel

  @Environment(\.dismiss)
  var dismiss

  init(model: @escaping @autoclosure () -> AccountRecoveryKeyLoginFlowModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack {
      if model.inProgress {
        ProgressView()
          .progressViewStyle(.indeterminate)
      } else if model.showError {
        errorView
      } else {
        mainView
      }
    }
    .animation(.default, value: model.inProgress)
    .loginAppearance()
  }

  var mainView: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case let .verification(method, deviceInfo):
        AccountVerificationFlow(
          model: model.makeAccountVerificationFlowViewModel(method: method, deviceInfo: deviceInfo))
      case let .recoveryKeyInput(authTicket, accountType):
        AccountRecoveryKeyLoginView(
          model: model.makeAccountRecoveryKeyLoginViewModel(
            authTicket: authTicket, accountType: accountType),
          showNoMatchError: $model.showNoMatchError)
      case let .changeMasterPassword(masterKey, authTicket):
        NewMasterPasswordView(
          model: model.makeNewMasterPasswordViewModel(masterKey: masterKey, authTicket: authTicket),
          title: CoreL10n.accountRecoveryNavigationTitle)
      }
    }
  }

  var errorView: some View {
    FeedbackView(
      title: CoreL10n.kwExtSomethingWentWrong,
      message: CoreL10n.recoveryKeyActivationFailureMessage,
      primaryButton: (
        CoreL10n.cancel,
        {
          dismiss()
          model.cancel()
        }
      ))
  }
}

struct AccountRecoveryKeyLoginFlow_Previews: PreviewProvider {
  static var previews: some View {
    NavigationView {
      AccountRecoveryKeyLoginFlow(model: .mock)
    }
  }
}
