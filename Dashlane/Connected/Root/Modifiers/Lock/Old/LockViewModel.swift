import Combine
import CoreKeychain
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import LoginKit
import SwiftTreats
import SwiftUI
import VaultKit

typealias ChangeMasterPasswordLauncher = () -> Void

@MainActor
class LockViewModel: ObservableObject, SessionServicesInjecting {
  enum Mode {
    case privacyShutter
    case masterPassword(MasterPasswordLocalViewModel)
    case biometry(BiometryViewModel)
    case pinCode(LockPinCodeAndBiometryViewModel)
    case sso
    case passwordLessRecovery(recoverFromFailure: Bool)
  }

  @Published
  var lock: ScreenLocker.Lock?

  @Published
  var mode: Mode = .privacyShutter

  @Published
  var newMasterPassword: String?

  private let session: Session
  private let locker: ScreenLocker
  private let keychainService: AuthenticationKeychainServiceProtocol
  private let userSettings: UserSettings
  private let resetMasterPasswordService: ResetMasterPasswordService
  private let pinCodeAttempts: PinCodeAttempts
  private let userSpacesService: UserSpacesService
  private let loginMetricsReporter: LoginMetricsReporterProtocol
  private let lockService: LockServiceProtocol
  private weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
  private var subscriptions: Set<AnyCancellable> = .init()
  private var initialBiometry: Biometry?
  private let appAPIClient: AppAPIClient
  private let loginKitServices: LoginKitServicesContainer
  private let accountType: CoreSession.AccountType
  private let appservices: AppServicesContainer
  private let syncService: SyncServiceProtocol
  private let sessionCryptoUpdater: SessionCryptoUpdater
  private let userDeviceAPIClient: UserDeviceAPIClient
  private let syncedSettings: SyncedSettingsService
  private let databaseDriver: DatabaseDriver
  private let logger: Logger
  private let nitroClient: NitroSSOAPIClient
  private let postARKChangeMasterPasswordViewModelFactory:
    PostARKChangeMasterPasswordViewModel.Factory
  var changeMasterPasswordLauncher: ChangeMasterPasswordLauncher

  var canAutomaticallyPromptQuickLoginScreen: Bool
  private let activityReporter: ActivityReporterProtocol

  lazy var mainAuthenticationMode: Definition.Mode =
    session.configuration.info.accountType == .sso ? .sso : .masterPassword

  init(
    locker: ScreenLocker,
    session: Session,
    appServices: AppServicesContainer,
    appAPIClient: AppAPIClient,
    userDeviceAPIClient: UserDeviceAPIClient,
    nitroClient: NitroSSOAPIClient,
    keychainService: AuthenticationKeychainServiceProtocol,
    userSettings: UserSettings,
    resetMasterPasswordService: ResetMasterPasswordService,
    activityReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    lockService: LockServiceProtocol,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    syncService: SyncServiceProtocol,
    sessionCryptoUpdater: SessionCryptoUpdater,
    syncedSettings: SyncedSettingsService,
    databaseDriver: DatabaseDriver,
    logger: Logger,
    newMasterPassword: String? = nil,
    changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher,
    postARKChangeMasterPasswordViewModelFactory: PostARKChangeMasterPasswordViewModel.Factory
  ) {
    self.session = session
    self.locker = locker
    self.accountType = session.configuration.info.accountType
    self.keychainService = keychainService
    self.userSettings = userSettings
    self.resetMasterPasswordService = resetMasterPasswordService
    self.changeMasterPasswordLauncher = changeMasterPasswordLauncher
    self.pinCodeAttempts = PinCodeAttempts(internalStore: userSettings.internalStore)
    self.userSpacesService = userSpacesService
    self.loginMetricsReporter = loginMetricsReporter
    self.lockService = lockService
    self.sessionLifeCycleHandler = sessionLifeCycleHandler
    self.activityReporter = activityReporter
    self.appAPIClient = appAPIClient
    self.syncService = syncService
    self.userDeviceAPIClient = userDeviceAPIClient
    self.syncedSettings = syncedSettings
    self.databaseDriver = databaseDriver
    self.appservices = appServices
    self.sessionCryptoUpdater = sessionCryptoUpdater
    self.logger = logger
    self.newMasterPassword = newMasterPassword
    self.nitroClient = nitroClient
    self.loginKitServices = appServices.makeLoginKitServicesContainer()
    self.postARKChangeMasterPasswordViewModelFactory = postARKChangeMasterPasswordViewModelFactory
    canAutomaticallyPromptQuickLoginScreen = !Device.isMac
    lock = locker.lock
    updateMode(with: lock)

    locker
      .$lock
      .filter { $0 != nil }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] lock in
        guard let self = self else {
          return
        }
        if self.lock != lock {
          self.lock = lock
          self.updateMode(with: lock)
        }
        self.initialBiometry = self.locker.lock?.biometry
      }
      .store(in: &subscriptions)
  }

  func updateMode(with lock: ScreenLocker.Lock?, recoverFromFailure: Bool = false) {
    switch lock {
    case .privacyShutter, .none:
      self.mode = .privacyShutter
    case let .secure(secureMode):
      switch secureMode {
      case .masterKey:
        switch accountType {
        case .masterPassword:
          self.mode = .masterPassword(makeMasterPasswordViewModel())
        case .invisibleMasterPassword:
          self.mode = .passwordLessRecovery(recoverFromFailure: recoverFromFailure)
        case .sso:
          self.mode = .sso
        }
      case .biometry(let type):
        guard canShow(secureMode) else { return }
        self.mode = .biometry(makeBiometryViewModel(biometryType: type))
      case .pincode(let lock):
        guard canShow(secureMode) else { return }
        guard !lock.attempts.tooManyAttempts else { break }
        let model = makePincodeAndBiometryViewModel(lock: lock)
        self.mode = .pinCode(model)
      case .biometryAndPincode(let biometry, let lock):
        guard canShow(secureMode) else { return }
        guard !lock.attempts.tooManyAttempts else { break }
        let model = makePincodeAndBiometryViewModel(lock: lock, biometryType: biometry)
        self.mode = .pinCode(model)
      default:
        break
      }
    }
  }

  func canShow(_ secureMode: SecureLockMode) -> Bool {
    guard canAutomaticallyPromptQuickLoginScreen || !secureMode.isBiometric else { return false }
    canAutomaticallyPromptQuickLoginScreen = false
    return true
  }

  private func performUnlock(_ mode: Definition.Mode) {
    activityReporter.logSuccessfulUnlock(mode)
    if let performanceLogInfo = loginMetricsReporter.getPerformanceLogInfo(.login) {
      activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToUnlock))
    }
    loginMetricsReporter.resetTimer(.login)
    locker.unlock()
  }
}

extension ScreenLocker.Lock {
  fileprivate var secureLockMode: SecureLockMode? {
    guard case let ScreenLocker.Lock.secure(mode) = self else {
      return nil
    }
    return mode
  }

  fileprivate var biometry: Biometry? {
    guard let secureLockMode = self.secureLockMode,
      case let SecureLockMode.biometry(biometry) = secureLockMode
    else {
      return nil
    }
    return biometry
  }
}

extension ActivityReporterProtocol {
  fileprivate func logSuccessfulUnlock(_ mode: Definition.Mode) {
    report(UserEvent.Login(isFirstLogin: false, mode: mode, status: .success))
  }
}

extension LockViewModel {
  func makePostARKChangeMasterPasswordViewModel(newMasterPassword: String)
    -> PostARKChangeMasterPasswordViewModel
  {
    let cryptoConfig = CryptoRawConfig.masterPasswordBasedDefault
    let currentMasterKey = session.authenticationMethod.sessionKey

    let migratingSession = try? appservices.sessionContainer.prepareMigration(
      of: session,
      to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey),
      remoteKey: nil,
      cryptoConfig: cryptoConfig,
      accountMigrationType: .masterPasswordToMasterPassword,
      loginOTPOption: session.configuration.info.loginOTPOption)

    let postCryptoChangeHandler = PostMasterKeyChangerHandler(
      keychainService: keychainService,
      resetMasterPasswordService: resetMasterPasswordService,
      syncService: syncService)

    let accountCryptoChangerService = try? AccountCryptoChangerService(
      reportedType: .masterPasswordChange,
      migratingSession: migratingSession!,
      syncService: syncService,
      sessionCryptoUpdater: sessionCryptoUpdater,
      activityReporter: activityReporter,
      sessionsContainer: appservices.sessionContainer,
      databaseDriver: databaseDriver,
      postCryptoChangeHandler: postCryptoChangeHandler,
      apiClient: userDeviceAPIClient,
      logger: logger,
      cryptoSettings: cryptoConfig)
    let model = postARKChangeMasterPasswordViewModelFactory.make(
      accountCryptoChangerService: accountCryptoChangerService!,
      completion: { [weak self] result in
        guard let self = self else {
          return
        }
        switch result {
        case let .finished(session):
          self.sessionLifeCycleHandler?.logoutAndPerform(
            action: .startNewSession(session, reason: .masterPasswordChangedForARK))
        case .cancel:
          self.newMasterPassword = nil
        }
      })
    return model

  }

  func makeMasterPasswordViewModel() -> MasterPasswordLocalViewModel {
    loginKitServices.makeMasterPasswordLocalViewModel(
      login: locker.login,
      biometry: initialBiometry,
      user: .normalUser,
      unlocker: locker,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      resetMasterPasswordService: resetMasterPasswordService,
      userSettings: userSettings
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case .biometry(let type):
        let mainAuthenticationMode = self.mainAuthenticationMode
        self.activityReporter.report(
          UserEvent.AskUseOtherAuthentication(
            next: .biometric,
            previous: mainAuthenticationMode))
        DispatchQueue.main.async {
          self.mode = .biometry(self.makeBiometryViewModel(biometryType: type))
        }
      case let .authenticated(config):
        if config.shouldResetMP {
          self.changeMasterPasswordLauncher()
        } else if config.newMasterPassword != nil {
          self.newMasterPassword = config.newMasterPassword
        } else {
          self.performUnlock(self.mainAuthenticationMode)
        }
      case .cancel:
        self.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
      }
    }
  }

  func makeBiometryViewModel(biometryType: Biometry) -> BiometryViewModel {
    loginKitServices.makeBiometryViewModel(
      login: locker.login,
      biometryType: biometryType,
      manualLockOrigin: true,
      unlocker: locker,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      userSettings: userSettings
    ) { [weak self] isSuccess in
      guard let self = self else { return }
      guard isSuccess else {
        let mainAuthenticationMode = self.mainAuthenticationMode
        self.activityReporter.report(
          UserEvent.AskUseOtherAuthentication(next: mainAuthenticationMode, previous: .biometric))
        self.lock = .secure(.masterKey)
        self.updateMode(with: self.lock)
        return
      }
      self.performUnlock(.biometric)
    }
  }

  func makePincodeAndBiometryViewModel(
    lock: SecureLockMode.PinCodeLock, biometryType: Biometry? = nil
  ) -> LockPinCodeAndBiometryViewModel {
    LockPinCodeAndBiometryViewModel(
      login: locker.login,
      accountType: accountType,
      pinCodeLock: lock,
      biometryType: biometryType,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      unlocker: locker,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case .failure, .cancel:
        let mainAuthenticationMode = self.mainAuthenticationMode
        self.activityReporter.report(
          UserEvent.AskUseOtherAuthentication(next: mainAuthenticationMode, previous: .pin))
        self.lock = .secure(.masterKey)
        self.updateMode(with: self.lock, recoverFromFailure: result == .failure)
        return
      case .biometricAuthenticationSuccess:
        self.performUnlock(.biometric)
      case .recover:
        self.mode = .passwordLessRecovery(recoverFromFailure: true)
      default:
        self.performUnlock(.pin)
      }
    }
  }

  func makePasswordLessRecoveryViewModel(recoverFromFailure: Bool) -> PasswordLessRecoveryViewModel
  {
    PasswordLessRecoveryViewModel(
      login: locker.login,
      recoverFromFailure: recoverFromFailure
    ) { completion in
      switch completion {
      case .logout:
        self.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
      case .cancel:
        self.performUnlock(.pin)
      }
    }
  }

  func makeSSOUnlockViewModel() -> SSOUnlockViewModel {
    return loginKitServices.makeSSOUnlockViewModel(
      login: session.login,
      deviceAccessKey: session.configuration.keys.serverAuthentication.deviceId
    ) { result in
      switch result {
      case let .success(type):
        switch type {
        case .completed:
          self.performUnlock(.sso)
        case .cancel:
          self.lock = .secure(.masterKey)
          self.updateMode(with: self.lock)
        case .logout:
          self.sessionLifeCycleHandler?.logout(clearAutoLoginData: true)
        }
      case .failure:
        self.lock = .secure(.masterKey)
        self.updateMode(with: self.lock)
      }
    }
  }
}
