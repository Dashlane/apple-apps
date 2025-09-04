import CoreLocalization
import DesignSystem
import LoginKit
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct PasswordLessAccountCreationFlow: View {
  @StateObject
  var model: PasswordLessAccountCreationFlowViewModel

  init(model: @autoclosure @escaping () -> PasswordLessAccountCreationFlowViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: model.steps) { step in
      switch step {
      case .intro:
        PasswordLessAccountCreationIntroView {
          model.startCreation()
        }
        .navigationBarVisible()
        .navigationBarBackButton {
          model.cancel()
        }

      case .pinCode:
        PinCodeSelection(model: model.makePinViewModel())
          .navigationBarHidden(true)

      case let .biometry(biometry):
        BiometricQuickSetupView(
          biometry: biometry,
          completion: model.completeBiometrySetup
        )
        .navigationBarVisible()
      case .userConsent:
        UserConsentView(model: model.makeUserContentViewModel()) {
          PasswordLessCreationRecapSection()
        }
        .navigationTitle(L10n.Localizable.kwTitle)
        .navigationBarVisible()

      case let .complete(sessionServices):
        PasswordLessCompletionView(
          model: sessionServices.makePasswordLessCompletionViewModel {
            model.finish(with: sessionServices)
          })
      }
    }
    .alert(using: $model.error) { error in
      let title = CoreL10n.errorMessage(for: error)
      return Alert(
        title: Text(title),
        dismissButton: .cancel(
          Text(CoreL10n.kwButtonOk),
          action: model.cancel)
      )
    }
  }
}
