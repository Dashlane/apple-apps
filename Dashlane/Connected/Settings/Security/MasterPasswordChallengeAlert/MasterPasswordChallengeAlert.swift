import SwiftUI
import UIDelight
import UIComponents
import CoreUserTracking
import DashTypes
import CoreLocalization

struct MasterPasswordChallengeAlert: View {

    @Environment(\.colorScheme) private var colorScheme
    @GlobalEnvironment(\.report) private var report

    @ObservedObject
    var viewModel: MasterPasswordChallengeAlertViewModel

    @State
    private var masterPasswordInput = ""

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(colorScheme == .dark ? 0.48 : 0.2))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            AlertTextFieldView(title: title,
                               message: message,
                               placeholder: CoreLocalization.L10n.Core.kwEnterYourMasterPassword,
                               isSecure: true,
                               textFieldInput: $masterPasswordInput,
                               onSubmit: buttonAction) {
                HStack {
                    Button(CoreLocalization.L10n.Core.cancel) {
                        viewModel.completion(.cancelled)
                    }
                    Divider()
                        .frame(maxHeight: 44)
                    Button(secondaryButtonTitle, action: buttonAction)
                    .buttonStyle(AlertButtonStyle(mainButton: false))
                }
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            report?(UserEvent.AskAuthentication(mode: .masterPassword, reason: .changeMasterPassword))
        }
    }

    private func buttonAction() {
        if viewModel.masterPassword == masterPasswordInput {
            viewModel.completion(.validated)
        } else {
            viewModel.completion(.failed)
        }
    }

    private var title: String {
        switch viewModel.intent {
        case .changeMasterPassword:
            return L10n.Localizable.settingsMasterPasswordPrompt
        case .enableMasterPasswordReset:
            return L10n.Localizable.resetMasterPasswordActivationMasterPasswordChallengeTitle
        }
    }

    private var message: String? {
        switch viewModel.intent {
        case .changeMasterPassword:
            return nil
        case .enableMasterPasswordReset:
            return L10n.Localizable.resetMasterPasswordActivationMasterPasswordChallengeMessage
        }
    }

    private var secondaryButtonTitle: String {
        switch viewModel.intent {
        case .changeMasterPassword:
            return CoreLocalization.L10n.Core.kwButtonOk
        case .enableMasterPasswordReset:
            return L10n.Localizable.resetMasterPasswordActivationMasterPasswordChallengeEnable
        }
    }
}

struct MasterPasswordChallengeAlert_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            MasterPasswordChallengeAlert(viewModel: .mock(intent: .changeMasterPassword))
            MasterPasswordChallengeAlert(viewModel: .mock(intent: .enableMasterPasswordReset))
        }
    }
}
