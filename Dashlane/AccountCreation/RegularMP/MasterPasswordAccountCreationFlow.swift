import CoreLocalization
import CoreSession
import DashlaneAPI
import LoginKit
import SwiftUI
import UIComponents
import UIDelight

struct MasterPasswordAccountCreationFlow: View {
  @StateObject
  var model: MasterPasswordAccountCreationFlowViewModel

  init(model: @autoclosure @escaping () -> MasterPasswordAccountCreationFlowViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    StepBasedContentNavigationView(steps: $model.steps) { step in
      switch step {
      case .fastLocalSetup:
        FastLocalSetupView(model: model.makeFastLocalSetup())
      case let .userConsent(email, password):
        UserConsentView(model: model.makeUserContentViewModel()) {
          MasterPasswordCreationRecapSection(email: email, masterPassword: password)
        }
      }
    }
    .alert(using: $model.error) { (error: Error) in
      if case AccountCreationError.expiredVersion = error {
        return Alert(
          title: Text(CoreL10n.validityStatusExpiredVersionNoUpdateTitle),
          message: Text(CoreL10n.validityStatusExpiredVersionNoUpdateDesc),
          dismissButton: .cancel(Text(L10n.Localizable.validityStatusExpiredVersionNoUpdateClose)))
      } else {
        let title = CoreL10n.errorMessage(for: error)
        return Alert(
          title: Text(title),
          dismissButton: .cancel(
            Text(CoreL10n.kwButtonOk),
            action: {
              model.cancel()
            }))
      }
    }

  }
}
