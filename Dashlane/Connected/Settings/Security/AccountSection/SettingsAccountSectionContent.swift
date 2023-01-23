import SwiftUI

struct SettingsAccountSectionContent: View {

    @ObservedObject
    var viewModel: SettingsAccountSectionViewModel

    @Binding
    var masterPasswordChallengeItem: MasterPasswordChallengeAlertViewModel?

    @State
    private var displayMasterPasswordChanger = false

    init(viewModel: @autoclosure @escaping () -> SettingsAccountSectionViewModel, masterPasswordChallengeItem: Binding<MasterPasswordChallengeAlertViewModel?>) {
        _viewModel = .init(wrappedValue: viewModel())
        self._masterPasswordChallengeItem = masterPasswordChallengeItem
    }

    var body: some View {
        if viewModel.isResetMasterPasswordAvailable {
            MasterPasswordResetActivationView(viewModel: viewModel.masterPasswordResetActivationViewModel,
                                              masterPasswordChallengeItem: $masterPasswordChallengeItem)
        }
        if viewModel.isChangeMasterPasswordAvailable {
            Button(action: { masterPasswordChallengeItem = masterPasswordChallengeAlertViewModel }, label: {
                Text(L10n.Localizable.settingsMasterPassword)
                    .foregroundColor(.primary)
            })
        }

        Button(action: viewModel.goToPrivacySettings) {
            Text(L10n.Localizable.settingsDataPrivacy)
                .foregroundColor(.primary)
        }

        NavigationLink(L10n.Localizable.kwDeviceListTitle) {
            DevicesList(model: viewModel.deviceListViewModel())
        }

        Button(action: { viewModel.activeAlert = .logOut }, label: {
            Text(L10n.Localizable.kwSignOutFromDevice)
                .foregroundColor(Color(asset: FiberAsset.settingsWarningRed))
        })
        .alert(using: $viewModel.activeAlert) { alert in
            switch alert {
            case .privacyError:
                return Alert(title: Text(L10n.Localizable.kwNoInternet),
                             message: nil,
                             dismissButton: .default(Text(L10n.Localizable.kwButtonOk)))
            case .wrongMasterPassword:
                return Alert(title: Text(L10n.Localizable.kwWrongMasterPasswordMessage),
                             message: nil,
                             dismissButton: .default(Text(L10n.Localizable.kwButtonOk)))
            case .logOut:
                return Alert(title: Text(L10n.Localizable.askLogout),
                             message: Text(L10n.Localizable.signoutAskMasterPassword),
                             primaryButton: .destructive(Text(L10n.Localizable.kwSignOut), action: viewModel.logOut),
                             secondaryButton: .cancel())
            }
        }
        .fullScreenCover(isPresented: $displayMasterPasswordChanger) {
            ChangeMasterPasswordFlowView(viewModel: viewModel.changeMasterPasswordFlowViewModelFactory.make())
        }
        .onReceive(viewModel.deepLinkPublisher) { link in
            guard case let .security(request) = link else { return }
            switch request {
            case .enableResetMasterPassword:
                viewModel.enableResetMasterPassword()
            default: break
            }
        }
    }

    private var masterPasswordChallengeAlertViewModel: MasterPasswordChallengeAlertViewModel {
        MasterPasswordChallengeAlertViewModel(session: viewModel.session, intent: .changeMasterPassword) { completion in
            defer { masterPasswordChallengeItem = nil }

            switch completion {
            case .validated:
                displayMasterPasswordChanger = true
            case .failed:
                self.viewModel.activeAlert = .wrongMasterPassword
            case .cancelled:
                return
            }
        }
    }
}

struct SettingsAccountSectionContent_Previews: PreviewProvider {
    static var previews: some View {
        SettingsAccountSectionContent(viewModel: .mock, masterPasswordChallengeItem: .constant(nil))
    }
}
