import SwiftUI
import UIComponents
import DesignSystem
import UIDelight
import LoginKit
import SwiftTreats

struct PasswordLessAccountCreationFlow: View {
    @StateObject
    var model: PasswordLessAccountCreationFlowViewModel

    init(model: @autoclosure @escaping () -> PasswordLessAccountCreationFlowViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        StepBasedContentNavigationView(steps: $model.steps) { step in
            switch step {
            case .intro:
                PasswordLessAccountCreationIntroView {
                    model.startCreation()
                }
                .navigationBarHidden(false) 

            case .pinCode:
                PinCodeSelection(model: .init(completion: { pin in
                    if let pin = pin {
                        model.setupPin(pin)
                    } else {

                    }
                }))
                .navigationBarHidden(true)

            case  let .biometry(biometry):
                BiometricQuickSetupView(biometry: biometry) { result in
                    switch result {
                    case .useBiometry:
                        model.enableBiometry()
                    case .skip:
                        model.skipBiometry()
                    }
                }
                .navigationBarHidden(false) 
            case .userConsent:
                UserConsentView(model: model.makeUserContentViewModel()) {
                    PasswordLessCreationRecapSection()
                }
                .navigationTitle("Create account")
                .navigationBarHidden(false) 

            case let .complete(sessionServices):
                PasswordLessCompletionView(model: sessionServices.makePasswordLessCompletionViewModel {
                    model.finish(with: sessionServices)
                })
            }
        }
    }
}
