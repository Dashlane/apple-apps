import Combine
import CoreKeychain
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import LogFoundation
import LoginKit
import SwiftTreats
import SwiftUI
import UserTrackingFoundation
import VaultKit

typealias ChangeMasterPasswordLauncher = () -> Void

@MainActor
class LockViewModel: ObservableObject, SessionServicesInjecting {
  enum Mode {
    case privacyShutter
    case masterPassword(MasterPasswordLocalViewModel)
    case biometry(BiometryViewModel)
    case pinCode(PinCodeAndBiometryViewModel)
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
  private let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  private weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
  private var subscriptions: Set<AnyCancellable> = .init()
  private var initialBiometry: Biometry?
  private let appAPIClient: AppAPIClient
  private let loginKitServices: LoginKitServicesContainer
  private let accountType: CoreSession.AccountType
  private let logger: Logger
  private let sessionCryptoEngineProvider: SessionCryptoEngineProvider
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
    loginKitServices: LoginKitServicesContainer,
    appAPIClient: AppAPIClient,
    userDeviceAPIClient: UserDeviceAPIClient,
    nitroClient: NitroSSOAPIClient,
    keychainService: AuthenticationKeychainServiceProtocol,
    userSettings: UserSettings,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    lockService: LockServiceProtocol,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    syncService: SyncServiceProtocol,
    sessionCryptoUpdater: SessionCryptoUpdater,
    syncedSettings: SyncedSettingsService,
    databaseDriver: DatabaseDriver,
    sessionsContainer: SessionsContainerProtocol,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider,
    logger: Logger,
    newMasterPassword: String? = nil,
    postARKChangeMasterPasswordViewModelFactory: PostARKChangeMasterPasswordViewModel.Factory,
    changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher
  ) {
    self.session = session
    self.locker = locker
    self.accountType = session.configuration.info.accountType
    self.keychainService = keychainService
    self.userSettings = userSettings
    self.resetMasterPasswordService = resetMasterPasswordService
    self.changeMasterPasswordLauncher = changeMasterPasswordLauncher
    self.sessionLifeCycleHandler = sessionLifeCycleHandler
    self.activityReporter = activityReporter
    self.appAPIClient = appAPIClient
    self.logger = logger
    self.newMasterPassword = newMasterPassword
    self.loginKitServices = loginKitServices
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.postARKChangeMasterPasswordViewModelFactory = postARKChangeMasterPasswordViewModelFactory
    canAutomaticallyPromptQuickLoginScreen = !Device.is(.mac)
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
        self.mode = .biometry(makeBiometryViewModel(biometryType: type, manualLockOrigin: true))
      case .pincode(let lock):
        let attempts = PinCodeAttempts(internalStore: userSettings.internalStore)
        guard canShow(secureMode) else { return }
        guard !attempts.tooManyAttempts else { break }
        let model = makePincodeAndBiometryViewModel(lock: lock)
        self.mode = .pinCode(model)
      case .biometryAndPincode(let biometry, let lock):
        let attempts = PinCodeAttempts(internalStore: userSettings.internalStore)
        guard canShow(secureMode) else { return }
        guard !attempts.tooManyAttempts else { break }
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
    let model = postARKChangeMasterPasswordViewModelFactory.make(
      accountMigrationConfiguration: .masterPasswordToMasterPassword(
        session: session, masterPassword: newMasterPassword)
    ) { [weak self] result in
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
    }
    return model

  }

  func makeMasterPasswordViewModel() -> MasterPasswordLocalViewModel {
    let stateMachine = MasterPasswordLocalLoginStateMachine(
      login: locker.login,
      unlocker: locker,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      appAPIClient: appAPIClient,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      resetMasterPasswordService: resetMasterPasswordService,
      pinCodeAttempts: PinCodeAttempts(internalStore: userSettings.internalStore),
      unlockMode: .masterPasswordOnly,
      logger: logger,
      activityReporter: activityReporter)

    return loginKitServices.makeMasterPasswordLocalViewModel(
      login: locker.login,
      biometry: initialBiometry,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      masterPasswordLocalStateMachine: stateMachine
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
          self.mode = .biometry(
            self.makeBiometryViewModel(biometryType: type, manualLockOrigin: false))
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

  func makeBiometryViewModel(biometryType: Biometry, manualLockOrigin: Bool) -> BiometryViewModel {
    let stateMachine = BiometryUnlockStateMachine(
      unlocker: locker,
      keychainService: keychainService,
      login: locker.login,
      loginSettings: LoginSettingsImpl(
        login: locker.login, userSettings: userSettings, keychainService: keychainService),
      logger: logger,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      activityReporter: activityReporter)
    return loginKitServices.makeBiometryViewModel(
      login: locker.login,
      biometryType: biometryType,
      manualLockOrigin: manualLockOrigin,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      biometryUnlockStateMachine: stateMachine
    ) { [weak self] session in
      guard let self = self else { return }
      guard session != nil else {
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
  ) -> PinCodeAndBiometryViewModel {
    let stateMachine = LockPinCodeAndBiometryStateMachine(
      unlocker: locker,
      login: locker.login,
      biometry: biometryType,
      context: .init(origin: .lock, localLoginContext: .passwordApp),
      pinCodeLock: lock,
      pinCodeAttempts: PinCodeAttempts(internalStore: userSettings.internalStore),
      logger: logger,
      activityReporter: activityReporter)
    return loginKitServices.makePinCodeAndBiometryViewModel(
      login: locker.login,
      accountType: accountType,
      pincode: lock.code,
      lockPinCodeAndBiometryStateMachine: stateMachine
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
      case let .authenticated(config):
        guard config.authenticationMode == .biometry else {
          self.performUnlock(.pin)
          return
        }
        self.performUnlock(.biometric)
      case .recover:
        self.mode = .passwordLessRecovery(recoverFromFailure: true)
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
      deviceAccessKey: session.configuration.keys.serverAuthentication.deviceId,
      stateMachine: loginKitServices.makeSSOUnlockStateMachine(
        state: .locked, login: session.login,
        deviceAccessKey: session.configuration.keys.serverAuthentication.deviceId)
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

extension LockViewModel {
  static func mock() async -> LockViewModel {
    let appServices = try! await AppServicesContainer(
      sessionLifeCycleHandler: .mock,
      crashReporter: SentryCrashReporter(target: .app),
      appLaunchTimeStamp: Date().timeIntervalSince1970
    )

    return LockViewModel(
      locker: .mock,
      session: .mock,
      loginKitServices: appServices,
      appAPIClient: .mock({}),
      userDeviceAPIClient: .mock({}),
      nitroClient: .mock({}),
      keychainService: .mock,
      userSettings: .mock,
      resetMasterPasswordService: .mock,
      activityReporter: .mock,
      userSpacesService: .mock(),
      lockService: .mock,
      sessionLifeCycleHandler: .mock,
      syncService: .mock(),
      sessionCryptoUpdater: .mock,
      syncedSettings: .mock,
      databaseDriver: InMemoryDatabaseDriver(),
      sessionsContainer: .mock,
      sessionCryptoEngineProvider: .init(logger: .mock),
      logger: .mock,
      newMasterPassword: nil,
      postARKChangeMasterPasswordViewModelFactory: .init({ _, _ in .mock }),
      changeMasterPasswordLauncher: {
      }
    )
  }
}
