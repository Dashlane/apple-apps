import Combine
import CoreFeature
import CoreNetworking
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreUserTracking
import CryptoKit
import DashTypes
import Foundation
import SwiftTreats
import SwiftUI

@MainActor
final class SecuritySettingsViewModel: ObservableObject, SessionServicesInjecting {
  typealias Confirmed = Bool

  enum Alert {
    case masterPasswordStoredInKeychain(completion: (Confirmed) -> Void)
  }

  enum UserKind {
    case regular
    case businessUser
    case businessAdmin
  }

  let session: Session
  let featureService: FeatureServiceProtocol
  let lockService: LockServiceProtocol
  let syncedSettings: SyncedSettingsService

  @Published
  var is2FAEnabled: Bool = false

  @Published
  var activeAlert: Alert?

  @Published
  var status: CorePremium.Status

  var userKind: UserKind {
    status.userKind
  }

  private(set) lazy var accountSectionViewModel = makeAccountSectionViewModel()
  private(set) lazy var biometricToggleViewModel = makeBiometricToggleViewModel()
  private(set) lazy var pinCodeSettingsViewModel = makePinCodeSettingsViewModel()
  private(set) lazy var rememberMasterPasswordToggleViewModel =
    makeRememberMasterPasswordToggleViewModel()

  private(set) lazy var authenticationSectionViewModels:
    SettingsAuthenticationSectionContent.ViewModels = {
      .init(
        biometricToggleViewModel: biometricToggleViewModel,
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

  init(
    session: Session,
    premiumStatusProvider: PremiumStatusProvider,
    featureService: FeatureServiceProtocol,
    lockService: LockServiceProtocol,
    syncedSettings: SyncedSettingsService,
    settingsLockSectionViewModelFactory: SettingsLockSectionViewModel.Factory,
    settingsAccountSectionViewModelFactory: SettingsAccountSectionViewModel.Factory,
    settingsBiometricToggleViewModelFactory: SettingsBiometricToggleViewModel.Factory,
    masterPasswordResetActivationViewModelFactory: MasterPasswordResetActivationViewModel.Factory,
    pinCodeSettingsViewModelFactory: PinCodeSettingsViewModel.Factory,
    rememberMasterPasswordToggleViewModelFactory: RememberMasterPasswordToggleViewModel.Factory,
    twoFASettingsViewModelFactory: TwoFASettingsViewModel.Factory
  ) {
    self.session = session
    self.featureService = featureService
    self.lockService = lockService
    self.syncedSettings = syncedSettings

    self.settingsLockSectionViewModelFactory = settingsLockSectionViewModelFactory
    self.settingsAccountSectionViewModelFactory = settingsAccountSectionViewModelFactory
    self.settingsBiometricToggleViewModelFactory = settingsBiometricToggleViewModelFactory
    self.masterPasswordResetActivationViewModelFactory =
      masterPasswordResetActivationViewModelFactory
    self.pinCodeSettingsViewModelFactory = pinCodeSettingsViewModelFactory
    self.rememberMasterPasswordToggleViewModelFactory = rememberMasterPasswordToggleViewModelFactory
    self.twoFASettingsViewModelFactory = twoFASettingsViewModelFactory
    self.status = premiumStatusProvider.status
    premiumStatusProvider.statusPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &$status)
    self.richIconsEnabled = syncedSettings[\.richIcons]
    syncedSettings.changes(of: \.richIcons)
      .receive(on: DispatchQueue.main)
      .assign(to: &$richIconsEnabled)
  }

  var shouldDisplayAutoLockOptions: Bool {
    lockService.shouldDisplayAutoLockOptions == true
  }

  var isMasterPasswordAccount: Bool {
    return session.configuration.info.accountType == .masterPassword
  }

  @Published
  var richIconsEnabled: Bool = true {
    didSet {
      guard oldValue != richIconsEnabled else {
        return
      }

      syncedSettings[\.richIcons] = richIconsEnabled
    }
  }

  var derivationKey: String {
    session.cryptoEngine.displayedKeyDerivationInfo
  }

  func makeAccountSectionViewModel() -> SettingsAccountSectionViewModel {
    settingsAccountSectionViewModelFactory.make { [weak self] action in
      guard let self else {
        return
      }

      self.handleMasterPasswordResetAction(action)
    }
  }

  private func makeBiometricToggleViewModel() -> SettingsBiometricToggleViewModel {
    settingsBiometricToggleViewModelFactory.make { [weak self] action in
      guard let self else {
        return
      }

      self.handleBiometricAction(action)
    }
  }

  private func makeMasterPasswordResetActivationViewModel(masterPassword: String)
    -> MasterPasswordResetActivationViewModel
  {
    masterPasswordResetActivationViewModelFactory.make(masterPassword: masterPassword) {
      [weak self] action in
      guard let self else {
        return
      }

      self.handleMasterPasswordResetAction(action)
    }
  }

  private func makePinCodeSettingsViewModel() -> PinCodeSettingsViewModel {
    pinCodeSettingsViewModelFactory.make { [weak self] action in
      guard let self = self else {
        return
      }

      self.handlePinCodeAction(action)
    }
  }

  private func makeRememberMasterPasswordToggleViewModel() -> RememberMasterPasswordToggleViewModel
  {
    rememberMasterPasswordToggleViewModelFactory.make { [weak self] action in
      guard let self else {
        return
      }

      self.handleRememberMasterPasswordAction(action)
    }
  }

  func makeTwoFASettingsViewModel() -> TwoFASettingsViewModel {
    twoFASettingsViewModelFactory.make(
      login: session.login,
      loginOTPOption: session.configuration.info.loginOTPOption,
      isTwoFAEnforced: status.isTwoFAEnforced)
  }

  private func handlePinCodeAction(_ action: PinCodeSettingsViewModel.Action) {
    switch action {
    case .deactivateMasterPasswordReset:
      accountSectionViewModel.masterPasswordResetActivationViewModel?
        .deactivateMasterPasswordReset()
    case .disableBiometry:
      biometricToggleViewModel.useBiometry(false)
    case .disableRememberMasterPassword:
      rememberMasterPasswordToggleViewModel.useRememberMasterPassword(false)
    }
  }

  private func handleBiometricAction(_ action: SettingsBiometricToggleViewModel.Action) {
    switch action {
    case .enableMasterPasswordReset:
      accountSectionViewModel.masterPasswordResetActivationViewModel?.startMasterPasswordChallenge()
    case .disableResetMasterPassword:
      accountSectionViewModel.masterPasswordResetActivationViewModel?
        .deactivateMasterPasswordReset()
    case .disableRememberMasterPassword:
      rememberMasterPasswordToggleViewModel.useRememberMasterPassword(false)
    case .disablePinCode:
      pinCodeSettingsViewModel.enablePinCode(false)
    }
  }

  private func handleMasterPasswordResetAction(
    _ action: MasterPasswordResetActivationViewModel.Action
  ) {
    switch action {
    case .activateBiometry:
      do {
        try biometricToggleViewModel.enableBiometry()
      } catch {
        assertionFailure("Couldn't activate biometry [\(error.localizedDescription)]")
      }
    }
  }

  private func handleRememberMasterPasswordAction(
    _ action: RememberMasterPasswordToggleViewModel.Action
  ) {
    switch action {
    case .disableBiometricsAndPincode:
      biometricToggleViewModel.useBiometry(false)
      pinCodeSettingsViewModel.enablePinCode(false)
    }
  }

  static var mock: SecuritySettingsViewModel {
    .init(
      session: .mock,
      premiumStatusProvider: .mock(),
      featureService: .mock(),
      lockService: LockServiceMock(),
      syncedSettings: .mock,
      settingsLockSectionViewModelFactory: .init({ .mock }),
      settingsAccountSectionViewModelFactory: .init({ _ in .mock }),
      settingsBiometricToggleViewModelFactory: .init({ _ in .mock }),
      masterPasswordResetActivationViewModelFactory: .init({ _, _ in .mock }),
      pinCodeSettingsViewModelFactory: .init({ _ in .mock }),
      rememberMasterPasswordToggleViewModelFactory: .init({ _ in .mock }),
      twoFASettingsViewModelFactory: .init({ _, _, _ in .mock }))
  }
}

extension LockServiceProtocol {
  fileprivate var shouldDisplayAutoLockOptions: Bool {
    locker.screenLocker != nil
  }
}

extension CorePremium.Status {
  fileprivate var userKind: SecuritySettingsViewModel.UserKind {
    if b2bStatus?.statusCode == .inTeam {
      return b2bStatus?.currentTeam?.teamMembership.isTeamAdmin == true
        ? .businessAdmin : .businessUser
    } else {
      return .regular
    }
  }

  fileprivate var isTwoFAEnforced: Bool {
    if let b2bStatus = b2bStatus,
      b2bStatus.statusCode == .inTeam,
      let team = b2bStatus.currentTeam,
      team.teamInfo.twoFAEnforced?.isEnforced == true
    {
      return true
    } else {
      return false
    }
  }
}
