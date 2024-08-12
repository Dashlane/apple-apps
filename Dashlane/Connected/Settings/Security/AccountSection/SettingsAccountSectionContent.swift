import CoreLocalization
import DesignSystem
import SwiftUI

struct SettingsAccountSectionContent: View {

  @ObservedObject
  var viewModel: SettingsAccountSectionViewModel

  @Binding
  var masterPasswordChallengeItem: MasterPasswordChallengeAlertViewModel?

  @State
  private var displayMasterPasswordChanger = false

  init(
    viewModel: @autoclosure @escaping () -> SettingsAccountSectionViewModel,
    masterPasswordChallengeItem: Binding<MasterPasswordChallengeAlertViewModel?>
  ) {
    _viewModel = .init(wrappedValue: viewModel())
    self._masterPasswordChallengeItem = masterPasswordChallengeItem
  }

  var body: some View {

    if viewModel.canShowAccountRecovery {
      AccountRecoveryKeyStatusView(model: viewModel.makeAccountRecoveryKeyStatusViewModel())
    }
    if let password = viewModel.masterPassword {
      MasterPasswordResetActivationView(
        viewModel: viewModel.makeMasterPasswordResetActivationViewModel(masterPassword: password),
        masterPasswordChallengeItem: $masterPasswordChallengeItem)
    }
    if let password = viewModel.isChangeMasterPasswordAvailable {
      Button(
        action: {
          masterPasswordChallengeItem = masterPasswordChallengeAlertViewModel(
            masterPassword: password)
        },
        label: {
          Text(L10n.Localizable.settingsMasterPassword)
            .foregroundColor(.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        })
    }

    Button(
      action: { viewModel.goToPrivacySettings() },
      label: {
        Text(L10n.Localizable.settingsDataPrivacy)
          .foregroundColor(.ds.text.neutral.standard)
          .textStyle(.body.standard.regular)
      }
    )
    .accessibilityAddTraits(.isLink)

    NavigationLink(
      destination: { DevicesList(model: viewModel.deviceListViewModel()) },
      label: {
        Text(L10n.Localizable.kwDeviceListTitle)
          .textStyle(.body.standard.regular)
          .foregroundColor(.ds.text.neutral.standard)
      })

    Button(
      action: { viewModel.activeAlert = .logOut },
      label: {
        Text(L10n.Localizable.kwSignOutFromDevice)
          .foregroundColor(.ds.text.danger.standard)
          .textStyle(.body.standard.regular)
      }
    )
    .alert(using: $viewModel.activeAlert) { alert in
      switch alert {
      case .privacyError:
        return Alert(
          title: Text(CoreLocalization.L10n.Core.kwNoInternet),
          message: nil,
          dismissButton: .default(Text(CoreLocalization.L10n.Core.kwButtonOk)))
      case .wrongMasterPassword:
        return Alert(
          title: Text(L10n.Localizable.kwWrongMasterPasswordMessage),
          message: nil,
          dismissButton: .default(Text(CoreLocalization.L10n.Core.kwButtonOk)))
      case .logOut:
        return logoutAlert
      }
    }
    .fullScreenCover(isPresented: $displayMasterPasswordChanger) {
      ChangeMasterPasswordFlowView(
        viewModel: viewModel.changeMasterPasswordFlowViewModelFactory.make())
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

  private func masterPasswordChallengeAlertViewModel(masterPassword: String)
    -> MasterPasswordChallengeAlertViewModel
  {
    viewModel.makeMasterPasswordChallengeAlertViewModel(masterPassword: masterPassword) {
      completion in
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

  var logoutAlert: Alert {
    switch viewModel.session.authenticationMethod {
    case .masterPassword:
      return Alert(
        title: Text(CoreLocalization.L10n.Core.askLogout),
        message: Text(CoreLocalization.L10n.Core.signoutAskMasterPassword),
        primaryButton: .destructive(
          Text(CoreLocalization.L10n.Core.kwSignOut), action: viewModel.logOut),
        secondaryButton: .cancel())
    case .sso:
      return Alert(
        title: Text(CoreLocalization.L10n.Core.askLogout),
        message: Text(CoreLocalization.L10n.Core.signoutAskMasterPassword),
        primaryButton: .destructive(
          Text(CoreLocalization.L10n.Core.kwSignOut), action: viewModel.logOut),
        secondaryButton: .cancel())
    case .invisibleMasterPassword:
      return Alert(
        title: Text(L10n.Localizable.mplessLogoutAlertTitle),
        message: Text(L10n.Localizable.mplessLogoutAlertMessage),
        primaryButton: .destructive(
          Text(CoreLocalization.L10n.Core.kwSignOut), action: viewModel.logOut),
        secondaryButton: .cancel())
    }
  }
}

struct SettingsAccountSectionContent_Previews: PreviewProvider {
  static var previews: some View {
    SettingsAccountSectionContent(viewModel: .mock, masterPasswordChallengeItem: .constant(nil))
  }
}
