import SwiftUI
import CoreSession
import CoreNetworking
import DashTypes
import CoreLocalization
import UIComponents
import UIDelight

struct TwoFAActivationView: View {

    @Environment(\.dismiss)
    private var dismiss

    @StateObject
    var model: TwoFAActivationViewModel

    init(model: @autoclosure @escaping () -> TwoFAActivationViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        StepBasedNavigationView(steps: $model.steps) { step in
            switch step {
            case .twoFAOption:
                TwoFATypeSelectionView { option in
                    model.steps.append(.recoverySetup(option))
                }
            case let .recoverySetup(option):
                TwoFARecoverySetupView(completion: {
                    model.steps.append(.phoneNumber(model.makeTwoFAPhoneNumberSetupViewModel(option: option)))
                })
            case let .phoneNumber(viewModel):
                TwoFAPhoneNumberSetupView(model: viewModel)
            case let .recoveryCode(viewModel):
                RecoveryCodesView(model: viewModel)
            case let .completion(viewModel):
                TwoFACompletionView(model: viewModel)
            }
        }.onReceive(model.dismissPublisher) {
            dismiss()
        }
    }
}

 struct TwoFAActivationView_Previews: PreviewProvider {
    static var previews: some View {
        TwoFAActivationView(model: .mock)
    }
 }
