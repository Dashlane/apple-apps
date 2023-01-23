import SwiftUI
import SwiftTreats

struct SettingsBiometricToggle: View {
    typealias Confirmed = Bool

    @ObservedObject
    var viewModel: SettingsBiometricToggleViewModel

    var body: some View {
        Toggle(L10n.Localizable.kwUseBiometryType(Device.currentBiometryDisplayableName), isOn: $viewModel.isToggleOn)
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .alert(using: $viewModel.activeAlert) { alert in
                switch alert {
                case .pinCodeReplacementWarning(let completion):
                    return makePinCodeReplacementWarningAlert(completion: completion)
                case .masterPasswordResetDeactivationWarning(let completion):
                    return makeMasterPasswordResetDeactivationWarningAlert(completion: completion)
                case .masterPasswordResetActivationSuggestion(let completion):
                    return makeMasterPasswordResetActivationSuggestionAlert(completion: completion)
                case .keychainStoredMasterPassword(let completion):
                    return makeKeychainStoredMasterPasswordAlert(completion: completion)
                }
            }
            .onChange(of: viewModel.isToggleOn, perform: viewModel.useBiometry)
    }

        private func makePinCodeReplacementWarningAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
        let title = L10n.Localizable.kwReplacePinConfirmMsg(Device.currentBiometryDisplayableName)
        return Alert(title: Text(title),
              message: nil,
              primaryButton: .cancel(Text(L10n.Localizable.kwReplaceTouchidCancel), action: { completion(false) }),
              secondaryButton: .default(Text(L10n.Localizable.kwReplaceTouchidOk), action: { completion(true) }))
    }

    private func makeMasterPasswordResetDeactivationWarningAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
        let title = L10n.Localizable.resetMasterPasswordBiometricsDeactivationDialogTitle(Device.currentBiometryDisplayableName)
        return Alert(title: Text(title),
                     message: nil,
                     primaryButton: .destructive(Text(L10n.Localizable.resetMasterPasswordBiometricsDeactivationDialogDisable),
                                                 action: { completion(true) }),
                     secondaryButton: .cancel(Text(L10n.Localizable.resetMasterPasswordBiometricsDeactivationDialogCancel),
                                              action: { completion(false) }))
    }

    private func makeMasterPasswordResetActivationSuggestionAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
        let title = L10n.Localizable.resetMasterPasswordResetSuggestedDialogTitle
        let message = L10n.Localizable.resetMasterPasswordResetSuggestedRequiredDialogDescription
        let acceptActionTitle = L10n.Localizable.resetMasterPasswordResetSuggestedRequiredDialogAccept

        return Alert(title: Text(title),
                     message: Text(message),
                     primaryButton: .default(Text(acceptActionTitle), action: { completion(true) }),
                     secondaryButton: .cancel({ completion(false) }))
    }

    private func makeKeychainStoredMasterPasswordAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
        let title = Device.biometryType == nil ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
        return Alert(title: Text(title),
                           message: nil,
                           primaryButton: .cancel({ completion(false) }),
                           secondaryButton: .default(Text(L10n.Localizable.kwButtonOk)) { completion(true) })
    }
}

struct SettingsBiometricToggle_Previews: PreviewProvider {
    static var previews: some View {
        SettingsBiometricToggle(viewModel: SettingsBiometricToggleViewModel.mock)
    }
}
