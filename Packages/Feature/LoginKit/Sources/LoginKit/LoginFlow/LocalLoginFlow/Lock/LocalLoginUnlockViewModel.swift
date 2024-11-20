import Combine
import CoreKeychain
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats
import SwiftUI

@MainActor
public class LocalLoginUnlockViewModel: ObservableObject, LoginKitServicesInjecting {
  public enum Completion {
    public enum AuthenticationMode {
      case masterPassword

      case resetMasterPassword

      case biometry

      case pincode

      case rememberMasterPassword

      case accountRecovered(_ newMasterPassword: String)

      case sso
    }

    case authenticated(AuthenticationMode, LocalLoginConfiguration?)

    case logout
  }

  enum UnlockMode: Equatable {
    case masterPassword
    case pincode(pinCodeLock: SecureLockMode.PinCodeLock, biometry: Biometry?)
    case biometry(Biometry)
    case passwordLessRecovery(afterFailure: Bool)
    case sso

    var biometryType: Biometry? {
      switch self {
      case .biometry(let biometryType):
        return biometryType
      default: return nil
      }
    }
  }

  enum UnlockOrigin {
    case login
    case lock
  }

  @Published
  var unlockMode: UnlockMode

  @Published
  var showRememberPassword: Bool = false

  let login: Login
  let loginMetricsReporter: LoginMetricsReporterProtocol
  let activityReporter: ActivityReporterProtocol
  let unlocker: UnlockSessionHandler
  let userSettings: UserSettings
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let accountType: CoreSession.AccountType
  let unlockType: UnlockType
  let completion: (Completion) -> Void
  let keychainService: AuthenticationKeychainServiceProtocol
  let context: LoginUnlockContext
  let appAPIClient: AppAPIClient
  let nitroClient: NitroSSOAPIClient
  let masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory
  let biometryViewModelFactory: BiometryViewModel.Factory
  let lockPinCodeAndBiometryViewModelFactory: LockPinCodeAndBiometryViewModel.Factory
  let passwordLessRecoveryViewModelFactory: PasswordLessRecoveryViewModel.Factory
  let ssoUnlockViewModelFactory: SSOUnlockViewModel.Factory
  let expectedSecureLockMode: SecureLockMode
  let sessionCleaner: SessionCleaner
  let localLoginHandler: LocalLoginHandler

  public init(
    login: Login,
    accountType: CoreSession.AccountType,
    unlockType: UnlockType,
    secureLockMode: SecureLockMode,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    unlocker: UnlockSessionHandler,
    context: LoginUnlockContext,
    userSettings: UserSettings,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    appAPIClient: AppAPIClient,
    localLoginHandler: LocalLoginHandler,
    nitroClient: NitroSSOAPIClient,
    sessionCleaner: SessionCleaner,
    keychainService: AuthenticationKeychainServiceProtocol,
    masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory,
    biometryViewModelFactory: BiometryViewModel.Factory,
    lockPinCodeAndBiometryViewModelFactory: LockPinCodeAndBiometryViewModel.Factory,
    passwordLessRecoveryViewModelFactory: PasswordLessRecoveryViewModel.Factory,
    ssoUnlockViewModelFactory: SSOUnlockViewModel.Factory,
    completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
  ) {
    self.login = login
    self.context = context
    self.unlockType = unlockType
    self.keychainService = keychainService
    self.loginMetricsReporter = loginMetricsReporter
    self.activityReporter = activityReporter
    self.unlocker = unlocker
    self.userSettings = userSettings
    self.resetMasterPasswordService = resetMasterPasswordService
    self.accountType = accountType
    self.completion = completion
    self.appAPIClient = appAPIClient
    self.localLoginHandler = localLoginHandler
    self.nitroClient = nitroClient
    self.masterPasswordLocalViewModelFactory = masterPasswordLocalViewModelFactory
    self.lockPinCodeAndBiometryViewModelFactory = lockPinCodeAndBiometryViewModelFactory
    self.passwordLessRecoveryViewModelFactory = passwordLessRecoveryViewModelFactory
    self.biometryViewModelFactory = biometryViewModelFactory
    self.unlockMode = accountType.fallbackUnlockMode(afterFailure: false)
    expectedSecureLockMode = secureLockMode
    self.sessionCleaner = sessionCleaner
    self.ssoUnlockViewModelFactory = ssoUnlockViewModelFactory
    selectConvenientUnlockModeMethodIfPossible(for: secureLockMode)
  }

  private func selectConvenientUnlockModeMethodIfPossible(for secureLockMode: SecureLockMode) {
    switch secureLockMode {
    case let .biometry(biometry):
      unlockMode = .biometry(biometry)

    case let .pincode(pinCodeLock):
      if pinCodeLock.attempts.tooManyAttempts {
        unlockMode = accountType.fallbackUnlockMode(afterFailure: true)
      } else {
        unlockMode = .pincode(pinCodeLock: pinCodeLock, biometry: nil)
      }

    case let .biometryAndPincode(biometry, pinCodeLock):
      if pinCodeLock.attempts.tooManyAttempts {
        unlockMode = accountType.fallbackUnlockMode(afterFailure: true)
      } else {
        unlockMode = .pincode(pinCodeLock: pinCodeLock, biometry: biometry)
      }

    case .rememberMasterPassword:
      self.showRememberPassword = true
      fallthrough

    case .masterKey:
      unlockMode = accountType.fallbackUnlockMode(afterFailure: false)
    }
  }

  func logOnAppear() {
    if let performanceLogInfo = loginMetricsReporter.getPerformanceLogInfo(.appLaunch) {
      activityReporter.report(performanceLogInfo.performanceUserEvent(for: .timeToAppReady))
      loginMetricsReporter.resetTimer(.appLaunch)
    }
  }

  func makeSSOUnlockViewModel() -> SSOUnlockViewModel {
    guard case let UnlockType.ssoValidation(ssoAuthenticationInfo, _, _) = unlockType else {
      fatalError()
    }

    return ssoUnlockViewModelFactory.make(
      login: login, deviceAccessKey: localLoginHandler.deviceAccessKey
    ) { result in
      Task {
        await self.handleSSOResult(result, ssoAuthenticationInfo: ssoAuthenticationInfo)
      }
    }
  }

  @MainActor
  private func handleSSOResult(
    _ result: Result<SSOUnlockViewModel.CompletionType, Error>,
    ssoAuthenticationInfo: SSOAuthenticationInfo
  ) async {
    do {
      let result = try result.get()
      switch result {
      case let .completed(ssoKeys):
        try await self.localLoginHandler.validateSSOKey(
          ssoKeys, ssoAuthenticationInfo: ssoAuthenticationInfo)
        self.completion(.authenticated(.sso, nil))
      case .cancel, .logout:
        self.completion(.logout)
      }
    } catch {
      self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: true)
      self.activityReporter.logFailure(for: self.unlockType)
    }
  }
}

extension LocalLoginUnlockViewModel {
  func authenticateUsingRememberPassword() async {
    if let masterKey = try? await keychainService.masterKey(for: self.login) {
      await self.validateLocalMasterKeyForRememberPassword(masterKey, unlocker: unlocker)
    } else {
      self.showRememberPassword = false
    }
  }

  private func validateLocalMasterKeyForRememberPassword(
    _ masterKey: DashTypes.MasterKey, unlocker: UnlockSessionHandler
  ) async {
    switch masterKey {
    case .masterPassword(let masterPassword):
      do {
        try await unlocker.validateMasterKey(
          .masterPassword(masterPassword, serverKey: nil), isRecoveryLogin: false)
        self.completion(.authenticated(.rememberMasterPassword, nil))
      } catch {
        try? self.keychainService.removeMasterKey(for: self.login)
        self.showRememberPassword = false
      }
    case .key(let key):
      do {
        try await unlocker.validateMasterKey(.ssoKey(key), isRecoveryLogin: false)
        self.completion(.authenticated(.rememberMasterPassword, nil))
      } catch {
        self.showRememberPassword = false
      }
    }
  }
}

extension LocalLoginUnlockViewModel {
  func makeMasterPasswordLocalViewModel() -> MasterPasswordLocalViewModel {
    let user: AccountRecoveryKeyLoginFlowStateMachine.User =
      if let authTicket = unlockType.authTicket {
        .otp2User(authTicket)
      } else {
        .normalUser
      }
    return masterPasswordLocalViewModelFactory.make(
      login: login,
      biometry: unlockMode.biometryType,
      user: user,
      unlocker: unlocker,
      context: context,
      resetMasterPasswordService: resetMasterPasswordService,
      userSettings: userSettings
    ) { [weak self] result in
      guard let self = self else { return }
      switch result {
      case let .authenticated(config):
        if config.shouldResetMP {
          self.completion(.authenticated(.resetMasterPassword, config))
        } else if let newMasterPassword = config.newMasterPassword {
          self.completion(.authenticated(.accountRecovered(newMasterPassword), config))
        } else {
          self.completion(.authenticated(.masterPassword, config))
        }

      case .biometry(let biometry):
        self.activityReporter.logAskOtherAuthentication(for: .masterPassword, nextMode: .biometric)
        self.unlockMode = .biometry(biometry)
      case .cancel:
        self.completion(.logout)
      }
    }
  }

  func makeBiometryViewModel(biometryType: Biometry) -> BiometryViewModel {
    biometryViewModelFactory.make(
      login: login,
      biometryType: biometryType,
      unlocker: unlocker,
      context: context,
      userSettings: userSettings
    ) { [weak self] isSuccess in
      guard let self = self else {
        return
      }

      if !isSuccess {
        self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: true)
        self.activityReporter.logFailure(for: self.unlockType)
      } else {
        self.completion(.authenticated(.biometry, nil))
      }
    }
  }

  func makePinCodeViewModel(
    lock: SecureLockMode.PinCodeLock,
    biometryType: Biometry? = nil
  ) -> LockPinCodeAndBiometryViewModel {
    lockPinCodeAndBiometryViewModelFactory.make(
      login: login,
      accountType: accountType,
      pinCodeLock: lock,
      biometryType: biometryType,
      context: context,
      unlocker: unlocker
    ) { [weak self] result in
      guard let self = self else {
        return
      }

      switch result {
      case .biometricAuthenticationSuccess:
        self.completion(.authenticated(.biometry, nil))

      case .pinAuthenticationSuccess:
        self.completion(.authenticated(.pincode, nil))

      case .failure:
        self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: true)

      case .recover:
        self.unlockMode = self.accountType.fallbackUnlockMode(afterFailure: false)

      case .cancel:
        let unlockMethod = self.accountType.fallbackUnlockMode(afterFailure: false)
        switch unlockMethod {
        case .passwordLessRecovery:
          self.completion(.logout)
        default:
          self.unlockMode = unlockMethod
        }
      }
    }
  }

  func makePasswordLessRecoveryViewModel(recoverFromFailure: Bool) -> PasswordLessRecoveryViewModel
  {
    passwordLessRecoveryViewModelFactory.make(login: login, recoverFromFailure: recoverFromFailure)
    { [weak self] completion in
      guard let self = self else {
        return
      }

      switch completion {
      case .logout:
        sessionCleaner.removeLocalData(for: login)
        self.completion(.logout)
      case .cancel:
        self.selectConvenientUnlockModeMethodIfPossible(for: self.expectedSecureLockMode)
      }
    }
  }
}

extension ActivityReporterProtocol {
  fileprivate func logFailure(for unlockType: UnlockType) {
    if case UnlockType.ssoValidation = unlockType {
      self.logAskOtherAuthentication(for: .pin, nextMode: .sso)
    } else {
      self.logAskOtherAuthentication(for: .pin, nextMode: .masterPassword)
    }
  }

  fileprivate func logAskOtherAuthentication(for mode: Definition.Mode, nextMode: Definition.Mode) {
    report(UserEvent.AskUseOtherAuthentication(next: nextMode, previous: mode))
  }
}

extension CoreSession.AccountType {
  func fallbackUnlockMode(afterFailure: Bool) -> LocalLoginUnlockViewModel.UnlockMode {
    switch self {
    case .masterPassword:
      return .masterPassword
    case .invisibleMasterPassword:
      return .passwordLessRecovery(afterFailure: afterFailure)
    case .sso:
      return .sso
    }
  }
}
