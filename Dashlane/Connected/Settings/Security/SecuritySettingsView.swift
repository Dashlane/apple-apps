import SwiftUI
import SwiftTreats
import UIDelight
import CoreSession
import DashlaneAppKit
import CoreNetworking
import CoreUserTracking
import CorePasswords
import CorePersonalData
import DesignSystem
import CoreLocalization

struct SecuritySettingsView: View {

    @Environment(\.colorScheme) private var colorScheme

    @StateObject
    var viewModel: SecuritySettingsViewModel

    @State
    private var masterPasswordChallengeItem: MasterPasswordChallengeAlertViewModel?

    init(viewModel: @autoclosure @escaping () -> SecuritySettingsViewModel) {
        _viewModel = .init(wrappedValue: viewModel())
    }

    var authenticationSectionFooter: String {
        if let biometryType = Device.biometryType {
            return viewModel.isMasterPasswordAccount ? L10n.Localizable.kwSettingsPinBiometryTypeFooter(biometryType.displayableName) : L10n.Localizable.mplessPinBiometryLockSettingsFooter(biometryType.displayableName)
        } else {
            return viewModel.isMasterPasswordAccount ? L10n.Localizable.kwSettingsPinTypeFooter : L10n.Localizable.mplessPinLockSettingsFooter
        }
    }

    var body: some View {
        List {
            Section(footer: Text(authenticationSectionFooter).textStyle(.body.helper.regular)) {
                SettingsAuthenticationSectionContent(viewModels: viewModel.authenticationSectionViewModels)
            }
            if viewModel.shouldDisplayOTP {
                Section(footer: Text(viewModel.twoFASettingsMessage).textStyle(.body.helper.regular)) {
                    TwoFASettingsView(model: viewModel.makeTwoFASettingsViewModel())
                }
            }
            if viewModel.shouldDisplayAutoLockOptions {
                Section {
                    SettingsLockSectionContent(viewModel: viewModel.settingsLockSectionViewModelFactory.make())
                }
            }
            Section(header: Text(L10n.Localizable.kwAccount).textStyle(.title.supporting.small)) {
                SettingsAccountSectionContent(viewModel: viewModel.accountSectionViewModel, masterPasswordChallengeItem: $masterPasswordChallengeItem)
            }
            Section {
                SettingsCryptographySectionContent(derivationKey: viewModel.derivationKey)
            } header: {
                Text(L10n.Localizable.kwCryptography)
                    .textStyle(.title.supporting.small)
                    .foregroundColor(.ds.text.neutral.standard)
            } footer: {
                Text(L10n.Localizable.kwCryptoDescription)
                    .textStyle(.body.helper.regular)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(L10n.Localizable.kwSecurity)
        .navigationBarTitleDisplayMode(.inline)
        .alert(using: $viewModel.activeAlert) { alert in
            switch alert {
            case .masterPasswordStoredInKeychain(let completion):
                let biometricTitle = L10n.Localizable.kwKeychainPasswordMsg(Device.currentBiometryDisplayableName)
                let title = Device.biometryType == nil ? L10n.Localizable.kwKeychainPasswordMsgPinOnly : biometricTitle
                return Alert(title: Text(title),
                             message: nil,
                             primaryButton: .default(Text(CoreLocalization.L10n.Core.kwButtonOk), action: { completion(true) }),
                             secondaryButton: .cancel({ completion(false) }))
            }
        }
        .overFullScreen(item: $masterPasswordChallengeItem) { viewModel in
            MasterPasswordChallengeAlert(viewModel: viewModel)
        }
        .reportPageAppearance(.settingsSecurity)
        .hideTabBar()
    }
}

struct SecuritySettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SecuritySettingsView(viewModel: .mock)
    }
}
