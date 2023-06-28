import Foundation
import SwiftUI
import UIComponents
import CoreSession
import DashlaneAPI
import DashTypes
import UIDelight

#if canImport(UIKit)
struct DeviceToDeviceLoginFlow: View {

    @Environment(\.dismiss)
    var dismiss

    @StateObject
    var model: DeviceToDeviceLoginFlowViewModel

    public init(model: @autoclosure @escaping () -> DeviceToDeviceLoginFlowViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
       navigationContent
            .onReceive(model.dismissPublisher) {
                dismiss()
            }
            .animation(.default, value: model.isInProgress)
    }

    var navigationContent: some View {
        StepBasedContentNavigationView(steps: $model.steps) { step in
            ZStack {
                switch step {
                case .secretTransfer:
                    DeviceToDeviceLoginQrCodeView(model: model.makeDeviceToDeviceLoginQrCodeViewModel())
                case let .verifyLogin(loginData):
                    DeviceToDeviceVerifyLoginView(model: model.makeDeviceToDeviceVerifyLoginViewModel(loginData: loginData), progressState: $model.progressState)
                case let .otp(validator):
                    DeviceToDeviceOTPLoginView(viewModel: model.makeDeviceToDeviceOTPLoginViewModel(validator: validator), progressState: $model.progressState)
                case let .pinSetup(registerData):
                    PinCodeSetupView(model: model.makePinCodeSetupViewModel(registerData: registerData))
                case  let .biometry(biometry, registerData):
                    BiometricQuickSetupView(biometry: biometry) { result in
                        switch result {
                        case .useBiometry:
                            model.enableBiometry(with: registerData)
                        case .skip:
                            model.skipBiometry(with: registerData)
                        }
                    }
                }
                if model.isInProgress {
                    ProgressionView(state: $model.progressState)
                }
            }
        }
    }
}

struct DeviceToDeviceLoginFlow_Previews: PreviewProvider {
    static var previews: some View {
        DeviceToDeviceLoginFlow(model: .mock)
    }
}
#endif
