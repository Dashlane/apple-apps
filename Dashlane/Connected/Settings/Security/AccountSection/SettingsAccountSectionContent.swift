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
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.standard.regular)
        })
    }

    Button(
      action: { viewModel.goToPrivacySettings() },
      label: {
        Text(L10n.Localizable.settingsDataPrivacy)
          .foregroundStyle(Color.ds.text.neutral.standard)
          .textStyle(.body.standard.regular)
      }
    )
    .accessibilityAddTraits(.isLink)

    NavigationLink(
      destination: { DevicesList(model: viewModel.deviceListViewModel()) },
      label: {
        Text(L10n.Localizable.kwDeviceListTitle)
          .textStyle(.body.standard.regular)
          .foregroundStyle(Color.ds.text.neutral.standard)
      })

    Button(
      action: { viewModel.activeAlert = .logOut },
      label: {
        Text(L10n.Localizable.kwSignOutFromDevice)
          .foregroundStyle(Color.ds.text.danger.standard)
          .textStyle(.body.standard.regular)
      }
    )
    .alert(using: $viewModel.activeAlert) { alert in
      switch alert {
      case .privacyError:
        return Alert(
          title: Text(CoreL10n.kwNoInternet),
          message: nil,
          dismissButton: .default(Text(CoreL10n.kwButtonOk)))
      case .wrongMasterPassword:
        return Alert(
          title: Text(L10n.Localizable.kwWrongMasterPasswordMessage),
          message: nil,
          dismissButton: .default(Text(CoreL10n.kwButtonOk)))
      case .logOut:
        return logoutAlert
      }
    }
    .fullScreenCover(isPresented: $displayMasterPasswordChanger) {
      MP2MPAccountMigrationFlowView(
        viewModel: viewModel.makeChangeMasterPasswordViewModel {
          displayMasterPasswordChanger = false
        }
      )
      .reportPageAppearance(.settingsSecurityChangeMasterPassword)
      .containerContext(nil)
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
        title: Text(CoreL10n.askLogout),
        message: Text(CoreL10n.signoutAskMasterPassword),
        primaryButton: .destructive(Text(CoreL10n.kwSignOut), action: viewModel.logOut),
        secondaryButton: .cancel())
    case .sso:
      return Alert(
        title: Text(CoreL10n.askLogout),
        message: Text(CoreL10n.signoutAskMasterPassword),
        primaryButton: .destructive(Text(CoreL10n.kwSignOut), action: viewModel.logOut),
        secondaryButton: .cancel())
    case .invisibleMasterPassword:
      return Alert(
        title: Text(L10n.Localizable.mplessLogoutAlertTitle),
        message: Text(L10n.Localizable.mplessLogoutAlertMessage),
        primaryButton: .destructive(Text(CoreL10n.kwSignOut), action: viewModel.logOut),
        secondaryButton: .cancel())
    }
  }
}

#Preview {
  List {
    Section {
      SettingsAccountSectionContent(viewModel: .mock, masterPasswordChallengeItem: .constant(nil))
    }
  }
}
