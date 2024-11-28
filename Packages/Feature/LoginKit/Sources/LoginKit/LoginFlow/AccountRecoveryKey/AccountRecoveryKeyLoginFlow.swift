#if canImport(UIKit)
  import Foundation
  import SwiftUI
  import UIDelight
  import CoreLocalization

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
        } else if model.showError {
          errorView
        } else {
          mainView
        }
      }.animation(.default, value: model.inProgress)
    }

    var mainView: some View {
      StepBasedContentNavigationView(steps: $model.steps) { step in
        switch step {
        case let .verification(method, deviceInfo):
          AccountVerificationFlow(
            model: model.makeAccountVerificationFlowViewModel(
              method: method, deviceInfo: deviceInfo))
        case let .recoveryKeyInput(authTicket):
          AccountRecoveryKeyLoginView(
            model: model.makeAccountRecoveryKeyLoginViewModel(authTicket: authTicket),
            showNoMatchError: $model.showNoMatchError)
        case let .changeMasterPassword(masterKey, authTicket):
          NewMasterPasswordView(
            model: model.makeNewMasterPasswordViewModel(
              masterKey: masterKey, authTicket: authTicket),
            title: L10n.Core.accountRecoveryNavigationTitle)
        }
      }.navigationBarStyle(.alternate)
    }

    var errorView: some View {
      FeedbackView(
        title: L10n.Core.kwExtSomethingWentWrong,
        message: L10n.Core.recoveryKeyActivationFailureMessage,
        primaryButton: (
          L10n.Core.cancel,
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
#endif
