import CoreLocalization
import CoreNetworking
import CorePasswords
import CorePersonalData
import CoreSession
import DesignSystem
import SwiftTreats
import SwiftUI
import UIDelight
import UserTrackingFoundation

struct SecuritySettingsView: View {

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.spacesConfiguration) private var spacesConfiguration

  @StateObject
  var viewModel: SecuritySettingsViewModel

  @State
  private var masterPasswordChallengeItem: MasterPasswordChallengeAlertViewModel?

  init(viewModel: @autoclosure @escaping () -> SecuritySettingsViewModel) {
    _viewModel = .init(wrappedValue: viewModel())
  }

  var authenticationSectionFooter: String {
    if let biometryType = Device.biometryType {
      return viewModel.isMasterPasswordAccount
        ? L10n.Localizable.kwSettingsPinBiometryTypeFooter(biometryType.displayableName)
        : L10n.Localizable.mplessPinBiometryLockSettingsFooter(biometryType.displayableName)
    } else {
      return viewModel.isMasterPasswordAccount
        ? L10n.Localizable.kwSettingsPinTypeFooter : L10n.Localizable.mplessPinLockSettingsFooter
    }
  }

  var body: some View {
    List {
      Section(footer: Text(authenticationSectionFooter).textStyle(.body.helper.regular)) {
        SettingsAuthenticationSectionContent(viewModels: viewModel.authenticationSectionViewModels)
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      TwoFASettingsView(model: viewModel.makeTwoFASettingsViewModel())

      if viewModel.shouldDisplayAutoLockOptions {
        Section {
          SettingsLockSectionContent(
            viewModel: viewModel.settingsLockSectionViewModelFactory.make())
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      if spacesConfiguration.currentTeam?.isRichIconsDisabled != true {
        Section {
          DS.Toggle(isOn: $viewModel.richIconsEnabled) {
            Text(L10n.Localizable.Settings.Security.richIconsToggle)
          }
        } footer: {
          Text(L10n.Localizable.Settings.Security.richIconsDescription)
            .textStyle(.body.helper.regular)
        }
        .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
      }

      Section(header: Text(L10n.Localizable.kwAccount).textStyle(.title.supporting.small)) {
        SettingsAccountSectionContent(
          viewModel: viewModel.accountSectionViewModel,
          masterPasswordChallengeItem: $masterPasswordChallengeItem)
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)

      Section {
        SettingsCryptographySectionContent(derivationKey: viewModel.derivationKey)
      } header: {
        Text(L10n.Localizable.kwCryptography)
          .textStyle(.title.supporting.small)
          .foregroundStyle(Color.ds.text.neutral.standard)
      } footer: {
        Text(viewModel.userKind.cryptoKeyDescription)
          .textStyle(.body.helper.regular)
      }
      .listRowBackground(Color.ds.container.agnostic.neutral.supershy)
    }
    .listStyle(.ds.insetGrouped)
    .navigationTitle(L10n.Localizable.kwSecurity)
    .navigationBarTitleDisplayMode(.inline)
    .alert(using: $viewModel.activeAlert) { alert in
      switch alert {
      case .masterPasswordStoredInKeychain(let completion):
        let biometricTitle = L10n.Localizable.kwKeychainPasswordMsg(
          Device.currentBiometryDisplayableName)
        let title =
          Device.biometryType == nil
          ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : biometricTitle
        return Alert(
          title: Text(title),
          message: nil,
          primaryButton: .default(Text(CoreL10n.kwButtonOk), action: { completion(true) }),
          secondaryButton: .cancel({ completion(false) }))
      }
    }
    .overFullScreen(item: $masterPasswordChallengeItem) { viewModel in
      MasterPasswordChallengeAlert(viewModel: viewModel)
    }
    .reportPageAppearance(.settingsSecurity)
    .toolbar(.hidden, for: .tabBar)
  }
}

struct SecuritySettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SecuritySettingsView(viewModel: .mock)
  }
}

extension SecuritySettingsViewModel.UserKind {
  fileprivate var cryptoKeyDescription: String {
    switch self {
    case .businessAdmin:
      return L10n.Localizable.cryptoDescriptionForBusinessAdmins
    case .businessUser:
      return L10n.Localizable.cryptoDescriptionForBusinessUsers
    case .regular:
      return L10n.Localizable.kwCryptoDescription
    }
  }
}
