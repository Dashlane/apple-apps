import SwiftUI
import SwiftTreats
import UIDelight
import CoreSession
import DashlaneAppKit
import CoreNetworking
import CoreUserTracking
import CorePasswords
import CorePersonalData

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
            return L10n.Localizable.kwSettingsPinBiometryTypeFooter(biometryType.displayableName)
        } else {
            return L10n.Localizable.kwSettingsPinTypeFooter
        }
    }

    var body: some View {
        List {
            Section(footer: Text(authenticationSectionFooter)) {
                SettingsAuthenticationSectionContent(viewModels: viewModel.authenticationSectionViewModels)
            }
            if viewModel.shouldDisplayOTP {
                Section(footer: Text(viewModel.twoFASettingsMessage)) {
                    TwoFASettingsView(model: viewModel.makeTwoFASettingsViewModel())
                }
            }
            if viewModel.shouldDisplayAutoLockOptions {
                Section {
                    SettingsLockSectionContent(viewModel: viewModel.settingsLockSectionViewModelFactory.make())
                }
            }
            Section(header: Text(L10n.Localizable.kwAccount)) {
                SettingsAccountSectionContent(viewModel: viewModel.accountSectionViewModel, masterPasswordChallengeItem: $masterPasswordChallengeItem)
            }
            Section {
                SettingsCryptographySectionContent(derivationKey: viewModel.derivationKey)
            } header: {
                Text(L10n.Localizable.kwCryptography)
            } footer: {
                Text(L10n.Localizable.kwCryptoDescription)
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
                             primaryButton: .default(Text(L10n.Localizable.kwButtonOk), action: { completion(true) }),
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
