import SwiftUI
import SwiftTreats
import DesignSystem

struct PinCodeSettingsView: View {

    @ObservedObject
    var viewModel: PinCodeSettingsViewModel

    var body: some View {
        Toggle(L10n.Localizable.kwUsePinCode, isOn: $viewModel.isToggleOn.animation())
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .alert(using: $viewModel.activeAlert) { activeAlert in
                switch activeAlert {
                case .deviceNotProtected(let completion):
                    return makeDeviceNotProtectedAlert(completion: completion)
                case .keychainStoredMasterPassword(let newPinCode, let completion):
                    return makeKeychainStoredMasterPasswordAlert(forPinCode: newPinCode, completion: completion)
                case .biometryReplacement(let completion):
                    return makeBiometryReplacementAlert(completion: completion)
                }
            }
            .overFullScreen(isPresented: $viewModel.displayPinCodeSelection) {
                PinCodeSelection(model: viewModel.makePinCodeSelectionViewModel())
            }
            .onChange(of: viewModel.isToggleOn, perform: viewModel.handleToggleValueChange)

        if viewModel.canChangePinCode {
            Button(action: {
                DispatchQueue.main.async { viewModel.displayPinCodeSelection = true }
            }, label: {
                Text(L10n.Localizable.kwChangePinCode)
                    .foregroundColor(.primary)
            })
        }
    }

        private func makeDeviceNotProtectedAlert(completion: @escaping () -> Void) -> Alert {
        Alert(title: Text(L10n.Localizable.kwDeviceNotProtectedAlertTitle),
              message: Text(L10n.Localizable.kwDeviceNotProtectedAlertBody),
              dismissButton: .cancel(Text(L10n.Localizable.kwButtonOk), action: completion))
    }

    private func makeKeychainStoredMasterPasswordAlert(forPinCode pinCode: String, completion: @escaping (Bool) -> Void) -> Alert {
        let title = Device.biometryType == nil ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
        return Alert(title: Text(title),
                           message: nil,
                           primaryButton: .cancel({ completion(false) }),
                           secondaryButton: .default(Text(L10n.Localizable.kwButtonOk)) { completion(true) })
    }

    private func makeBiometryReplacementAlert(completion: @escaping (Bool) -> Void) -> Alert {
        let title = L10n.Localizable.kwReplaceBiometryTypeConfirmMsg(Device.currentBiometryDisplayableName)
        return Alert(title: Text(title),
                           message: nil,
                           primaryButton: .cancel(Text(L10n.Localizable.kwReplaceTouchidCancel), action: { completion(false) }),
                           secondaryButton: .default(Text(L10n.Localizable.kwReplaceTouchidOk), action: { completion(true) }))
    }
}

struct PinCodeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        PinCodeSettingsView(viewModel: PinCodeSettingsViewModel(lockService: LockServiceMock(),
                                                                teamSpaceService: .mock(),
                                                                usageLogService: UsageLogService.fakeService,
                                                                actionHandler: { _ in }))
    }
}
