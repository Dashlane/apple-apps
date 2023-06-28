import SwiftUI
import UIDelight
import DashlaneAPI
import CoreLocalization
import CoreSession
import UIComponents

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
            case .userConsent:
                UserConsentView(model: model.makeUserContentViewModel()) {
                    MasterPasswordCreationRecapSection(email: model.configuration.email.address, masterPassword: model.configuration.password)
                }
            }
        }
        .alert(using: $model.error) { (error: Error) in
            if case AccountCreationError.expiredVersion = error {
                return VersionValidityAlert.errorAlert()
            } else {
                let title = CoreLocalization.L10n.errorMessage(for: error)
                return Alert(title: Text(title), dismissButton: .cancel(Text(CoreLocalization.L10n.Core.kwButtonOk), action: {
                    model.cancel()
                }))
            }
        }

    }
}

extension MasterPasswordAccountCreationFlow: NavigationBarStyleProvider {
    var navigationBarStyle: UIComponents.NavigationBarStyle {
        .transparent(tintColor: .ds.text.neutral.standard, statusBarStyle: .default)
    }
}
