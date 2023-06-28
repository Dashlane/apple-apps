import Foundation
import SwiftUI
import Combine
import CryptoKit
import SwiftTreats
import CoreSession
import DashlaneAppKit
import CoreUserTracking
import CorePasswords
import DashTypes
import CoreNetworking
import CorePersonalData
import CoreFeature
import CorePremium

@MainActor
final class SecuritySettingsViewModel: ObservableObject, SessionServicesInjecting {
    typealias Confirmed = Bool

    enum Alert {
        case masterPasswordStoredInKeychain(completion: (Confirmed) -> Void)
    }

    let session: Session
    let teamSpacesService: TeamSpacesServiceProtocol
    let featureService: FeatureServiceProtocol
    let lockService: LockServiceProtocol

    @Published
    var activeAlert: Alert?

        private(set) lazy var accountSectionViewModel = makeAccountSectionViewModel()
    private(set) lazy var biometricToggleViewModel = makeBiometricToggleViewModel()
    private(set) lazy var pinCodeSettingsViewModel = makePinCodeSettingsViewModel()
    private(set) lazy var rememberMasterPasswordToggleViewModel = makeRememberMasterPasswordToggleViewModel()

    private(set) lazy var authenticationSectionViewModels: SettingsAuthenticationSectionContent.ViewModels = {
        .init(biometricToggleViewModel: biometricToggleViewModel,
              pinCodeViewModel: pinCodeSettingsViewModel,
              rememberMasterPasswordToggleViewModel: rememberMasterPasswordToggleViewModel)
    }()

    let settingsLockSectionViewModelFactory: SettingsLockSectionViewModel.Factory
    let settingsAccountSectionViewModelFactory: SettingsAccountSectionViewModel.Factory
    let settingsBiometricToggleViewModelFactory: SettingsBiometricToggleViewModel.Factory
    let masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory
    let pinCodeSettingsViewModelFactory: PinCodeSettingsViewModel.Factory
    let rememberMasterPasswordToggleViewModelFactory: RememberMasterPasswordToggleViewModel.Factory
    let twoFASettingsViewModelFactory: TwoFASettingsViewModel.Factory

    init(session: Session,
         teamSpacesService: TeamSpacesServiceProtocol,
         featureService: FeatureServiceProtocol,
         lockService: LockServiceProtocol,
         settingsLockSectionViewModelFactory: SettingsLockSectionViewModel.Factory,
         settingsAccountSectionViewModelFactory: SettingsAccountSectionViewModel.Factory,
         settingsBiometricToggleViewModelFactory: SettingsBiometricToggleViewModel.Factory,
         masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory,
         pinCodeSettingsViewModelFactory: PinCodeSettingsViewModel.Factory,
         rememberMasterPasswordToggleViewModelFactory: RememberMasterPasswordToggleViewModel.Factory,
         twoFASettingsViewModelFactory: TwoFASettingsViewModel.Factory) {
        self.session = session
        self.teamSpacesService = teamSpacesService
        self.featureService = featureService
        self.lockService = lockService

        self.settingsLockSectionViewModelFactory = settingsLockSectionViewModelFactory
        self.settingsAccountSectionViewModelFactory = settingsAccountSectionViewModelFactory
        self.settingsBiometricToggleViewModelFactory = settingsBiometricToggleViewModelFactory
        self.masterPasswordResetActivationViewModelFactory = masterPasswordResetActivationViewModelFactory
        self.pinCodeSettingsViewModelFactory = pinCodeSettingsViewModelFactory
        self.rememberMasterPasswordToggleViewModelFactory = rememberMasterPasswordToggleViewModelFactory
        self.twoFASettingsViewModelFactory = twoFASettingsViewModelFactory
    }

    var shouldDisplayOTP: Bool {
        session.configuration.info.accountType == .masterPassword && !Device.isMac && featureService.isEnabled(.twoFASettings)
    }

    var shouldDisplayAutoLockOptions: Bool {
        lockService.shouldDisplayAutoLockOptions == true
    }

    var isMasterPasswordAccount: Bool {
        return session.configuration.info.accountType == .masterPassword
    }

    var twoFASettingsMessage: String {
        if teamSpacesService.is2FAEnforced {
                        if session.configuration.info.loginOTPOption != nil {
                return L10n.Localizable.twofaSettingsEnforcedMessageOtp2
            } else {
                return L10n.Localizable.twofaSettingsEnforcedMessageOtp1
            }
        }
       return L10n.Localizable.twofaSettingsMessage
    }

        var derivationKey: String {
        session.cryptoEngine.displayedKeyDerivationInfo
    }

        func makeAccountSectionViewModel() -> SettingsAccountSectionViewModel {
        settingsAccountSectionViewModelFactory.make(actionHandler: handleMasterPasswordResetAction)
    }

    private func makeBiometricToggleViewModel() -> SettingsBiometricToggleViewModel {
        settingsBiometricToggleViewModelFactory.make(actionHandler: handleBiometricAction)
    }

    private func makeMasterPasswordResetActivationViewModel(masterPassword: String) -> MasterPasswordResetActivationViewModel {
        masterPasswordResetActivationViewModelFactory.make(masterPassword: masterPassword, actionHandler: handleMasterPasswordResetAction)
    }

    private func makePinCodeSettingsViewModel() -> PinCodeSettingsViewModel {
        pinCodeSettingsViewModelFactory.make(actionHandler: handlePinCodeAction)
    }

    private func makeRememberMasterPasswordToggleViewModel() -> RememberMasterPasswordToggleViewModel {
        rememberMasterPasswordToggleViewModelFactory.make(actionHandler: handleRememberMasterPasswordAction)
    }

    @MainActor
    func makeTwoFASettingsViewModel() -> TwoFASettingsViewModel {
        twoFASettingsViewModelFactory.make(login: session.login,
                                           loginOTPOption: session.configuration.info.loginOTPOption,
                                           isTwoFAEnforced: teamSpacesService.is2FAEnforced)
    }

        private func handlePinCodeAction(_ action: PinCodeSettingsViewModel.Action) {
        switch action {
        case let .deactivateMasterPasswordReset(masterPassword):
            accountSectionViewModel.makeMasterPasswordResetActivationViewModel(masterPassword: masterPassword).deactivateMasterPasswordReset()
        case .disableBiometry:
            biometricToggleViewModel.useBiometry(false)
        case .disableRememberMasterPassword:
            rememberMasterPasswordToggleViewModel.useRememberMasterPassword(false)
        }
    }

    private func handleBiometricAction(_ action: SettingsBiometricToggleViewModel.Action) {
        switch action {
        case let .enableMasterPasswordReset(masterPassword):
            accountSectionViewModel.makeMasterPasswordResetActivationViewModel(masterPassword: masterPassword).startMasterPasswordChallenge()
        case let .disableResetMasterPassword(masterPassword):
            accountSectionViewModel.makeMasterPasswordResetActivationViewModel(masterPassword: masterPassword).deactivateMasterPasswordReset()
        case .disableRememberMasterPassword:
            rememberMasterPasswordToggleViewModel.useRememberMasterPassword(false)
        case .disablePinCode:
            pinCodeSettingsViewModel.enablePinCode(false)
        }
    }

    private func handleMasterPasswordResetAction(_ action: MasterPasswordResetActivationViewModel.Action) {
        switch action {
        case .activateBiometry:
            do {
                try biometricToggleViewModel.enableBiometry()
            } catch {
                assertionFailure("Couldn't activate biometry [\(error.localizedDescription)]")
            }
        }
    }

    private func handleRememberMasterPasswordAction(_ action: RememberMasterPasswordToggleViewModel.Action) {
        switch action {
        case .disableBiometricsAndPincode:
            biometricToggleViewModel.useBiometry(false)
            pinCodeSettingsViewModel.enablePinCode(false)
        }
    }

        static var mock: SecuritySettingsViewModel {
        .init(session: .mock,
              teamSpacesService: .mock(),
              featureService: .mock(),
              lockService: LockServiceMock(),
              settingsLockSectionViewModelFactory: .init({ .mock }),
              settingsAccountSectionViewModelFactory: .init({ _ in .mock }),
              settingsBiometricToggleViewModelFactory: .init({ _ in .mock }),
              masterPasswordResetActivationViewModelFactory: .init({ _, _  in .mock }),
              pinCodeSettingsViewModelFactory: .init({ _ in .mock }),
              rememberMasterPasswordToggleViewModelFactory: .init({ _ in .mock }),
              twoFASettingsViewModelFactory: .init({ _, _, _ in .mock }))
    }
}

fileprivate extension LockServiceProtocol {
    var shouldDisplayAutoLockOptions: Bool {
        locker.screenLocker != nil
    }
}
