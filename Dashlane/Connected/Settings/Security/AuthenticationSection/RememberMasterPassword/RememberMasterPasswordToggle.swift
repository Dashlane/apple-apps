import SwiftUI
import SwiftTreats

struct RememberMasterPasswordToggle: View {
    typealias Confirmed = Bool

    @ObservedObject
    var viewModel: RememberMasterPasswordToggleViewModel

    var body: some View {
        Toggle(L10n.Localizable.rememberMpSettings, isOn: $viewModel.isToggleOn)
            .toggleStyle(SwitchToggleStyle(tint: .green))
            .alert(using: $viewModel.activeAlert) { alert in
                switch alert {
                case .keychainStoredMasterPassword(let completion):
                    return makeKeychainStoredMasterPasswordAlert(completion: completion)
                }
            }
            .onChange(of: viewModel.isToggleOn, perform: viewModel.useRememberMasterPassword)
    }

    private func makeKeychainStoredMasterPasswordAlert(completion: @escaping (Confirmed) -> Void) -> Alert {
        let title = Device.biometryType == nil ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
        return Alert(title: Text(title),
                           message: nil,
                           primaryButton: .cancel({ completion(false) }),
                           secondaryButton: .default(Text(L10n.Localizable.kwButtonOk)) { completion(true) })
    }
}

struct RememberMasterPasswordToggle_Previews: PreviewProvider {
    static var previews: some View {
        RememberMasterPasswordToggle(viewModel: .mock)
    }
}
