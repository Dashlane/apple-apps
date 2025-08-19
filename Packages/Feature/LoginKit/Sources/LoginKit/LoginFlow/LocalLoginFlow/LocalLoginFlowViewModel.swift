import Combine
import CoreKeychain
import CoreNetworking
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import Logger
import StateMachine
import UserTrackingFoundation

@MainActor
public class LocalLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting,
  StateMachineBasedObservableObject
{

  public enum Completion {
    case completed(config: LocalLoginConfiguration, logInfo: LoginFlowLogInfo)
    case migration(AccountMigrationInfos)
    case logout
    case cancel
  }

  enum Step {
    case unlock(UserUnlockInfo)
    case otp(ThirdPartyOTPOption, SecureLockMode, DeviceInfo)
    case sso(SSOLocalStateMachine.State, SSOAuthenticationInfo, _ deviceAccessKey: String)
  }

  @Published
  var steps: [Step] = []

  @Published public var isPerformingEvent: Bool = false

  let login: Login

  let settingsManager: LocalSettingsFactory
  let keychainService: AuthenticationKeychainServiceProtocol
  let activityReporter: ActivityReporterProtocol
  let userSettings: UserSettings
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let sessionContainer: SessionsContainerProtocol
  var completion: (@MainActor (Result<Completion, Error>) -> Void)?
  let context: UnlockOriginProcess
  let accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory
  let recoveryLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  let localLoginUnlockViewModelFactory: LocalLoginUnlockViewModel.Factory
  let masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory
  let ssoLoginViewModelFactory: SSOLocalLoginViewModel.Factory
  let logger: Logger

  @Published public var stateMachine: LocalLoginStateMachine

  public init(
    stateMachine: LocalLoginStateMachine,
    settingsManager: LocalSettingsFactory,
    activityReporter: ActivityReporterProtocol,
    sessionContainer: SessionsContainerProtocol,
    logger: Logger,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    userSettings: UserSettings,
    keychainService: AuthenticationKeychainServiceProtocol,
    login: Login,
    context: UnlockOriginProcess,
    accountVerificationFlowModelFactory: AccountVerificationFlowModel.Factory,
    recoveryLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    localLoginUnlockViewModelFactory: LocalLoginUnlockViewModel.Factory,
    masterPasswordLocalViewModelFactory: MasterPasswordLocalViewModel.Factory,
    ssoLoginViewModelFactory: SSOLocalLoginViewModel.Factory,
    completion: @escaping @MainActor (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
  ) {
    self.login = login
    self.context = context
    self.userSettings = userSettings
    self.resetMasterPasswordService = resetMasterPasswordService
    self.activityReporter = activityReporter
    self.logger = logger[.session]
    self.sessionContainer = sessionContainer
    self.completion = completion
    self.keychainService = keychainService
    self.settingsManager = settingsManager
    self.accountVerificationFlowModelFactory = accountVerificationFlowModelFactory
    self.recoveryLoginFlowModelFactory = recoveryLoginFlowModelFactory
    self.localLoginUnlockViewModelFactory = localLoginUnlockViewModelFactory
    self.masterPasswordLocalViewModelFactory = masterPasswordLocalViewModelFactory
    self.ssoLoginViewModelFactory = ssoLoginViewModelFactory
    self.stateMachine = stateMachine
    start()
  }

  func start() {
    Task {
      await perform(.getLoginType)
    }
  }

  func makeAccountVerificationFlowViewModel(
    method: VerificationMethod, lockType: SecureLockMode, deviceInfo: DeviceInfo
  ) -> AccountVerificationFlowModel {
    accountVerificationFlowModelFactory.make(
      login: login, mode: .masterPassword,
      stateMachine: stateMachine.makeAccountVerificationStateMachine(verificationMethod: method),
      completion: { [weak self] result in
        guard let self = self else {
          return
        }
        Task {
          do {
            let (authTicket, isBackupCode) = try result.get()
            await self.perform(
              .otpDidFinish(authTicket: authTicket, lockType, isBackUpCode: isBackupCode))
          } catch {
            await self.perform(
              .errorEncountered(
                StateMachineError(underlyingError: LocalLoginStateMachine.Error.noServerKey)))
          }
        }
      })
  }

  func makeSSOLoginViewModel(
    initialState: SSOLocalStateMachine.State, ssoAuthenticationInfo: SSOAuthenticationInfo,
    deviceAccessKey: String
  ) -> SSOLocalLoginViewModel {
    return ssoLoginViewModelFactory.make(
      stateMachine: stateMachine.makeSSOLocalStateMachine(
        state: initialState, ssoAuthenticationInfo: ssoAuthenticationInfo),
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      completion: { result in
        Task {
          await self.handleSSOResult(result, ssoAuthenticationInfo: ssoAuthenticationInfo)
        }
      })
  }

  private func handleSSOResult(
    _ result: Result<SSOLocalLoginViewModel.CompletionType, Error>,
    ssoAuthenticationInfo: SSOAuthenticationInfo
  ) async {
    do {
      let result = try result.get()
      switch result {
      case let .completed(ssoKeys):
        await perform(.validateSSO(ssoKeys))
      case .cancel:
        await self.perform(.cancel)
      }
    } catch {
      await self.perform(.errorEncountered(StateMachineError(underlyingError: error)))
      self.activityReporter.report(
        UserEvent.Login(
          mode: .sso,
          status: .errorInvalidSso,
          verificationMode: Definition.VerificationMode.none))
    }
  }
}

extension LocalLoginFlowViewModel {
  public func update(
    for event: CoreSession.LocalLoginStateMachine.Event,
    from oldState: CoreSession.LocalLoginStateMachine.State,
    to newState: CoreSession.LocalLoginStateMachine.State
  ) {
    switch (newState, event) {
    case (.initial, _):
      break
    case (let .needsThirdPartyOTP(option, lockType, deviceInfo, _), _):
      self.steps.append(.otp(option, lockType, deviceInfo))
    case (let .ssoAuthenticationNeeded(initialState, ssoAuthenticationInfo, deviceAccessKey), _):
      self.steps.append(.sso(initialState, ssoAuthenticationInfo, deviceAccessKey))
    case (let .userUnlock(unlockInfo), _):
      self.steps.append(.unlock(unlockInfo))
    case (let .completed(config), _):
      let loginFlowLogInfo: LoginFlowLogInfo = .init(
        loginMode: config.authenticationMode?.authenticationLog ?? .masterPassword,
        verificationMode: config.verificationMode.verificationModeLog,
        isBackupCode: config.isBackupCode)
      loginCompleted(with: .success(.completed(config: config, logInfo: loginFlowLogInfo)))
    case (let .failed(error), _):
      loginCompleted(with: .failure(error.underlyingError))
    case (.cancelled, _):
      loginCompleted(with: .success(.cancel))
    case (let .migrateAccount(infos), _):
      loginCompleted(with: .success(.migration(infos)))
    case (.logout, _):
      loginCompleted(with: .success(.logout))
    }
  }

  func loginCompleted(with result: Result<LocalLoginFlowViewModel.Completion, Error>) {
    guard completion != nil else {
      logger.error("Local login Completion called more than once")
      return
    }
    self.completion?(result)
    self.completion = nil
  }
}

extension AuthenticationMode {
  fileprivate var shouldRefreshKeychainMasterKey: Bool {
    switch self {
    case .resetMasterPassword, .masterPassword, .sso: return true
    default: return false
    }
  }
}

extension UnlockOriginProcess {
  fileprivate var shouldCheckBiometricSetIsIntact: Bool {
    switch self {
    case .autofillExtension: return false
    default: return true
    }
  }
}

extension AuthenticationMode {
  fileprivate var authenticationLog: Definition.Mode {
    switch self {
    case .masterPassword, .resetMasterPassword, .accountRecovered:
      return .masterPassword
    case .biometry, .rememberMasterPassword:
      return .biometric
    case .pincode:
      return .pin
    case .sso:
      return .sso
    }
  }
}

extension LocalLoginVerificationMode {
  fileprivate var verificationModeLog: Definition.VerificationMode {
    switch self {
    case .otp2:
      return .otp2
    default:
      return .none
    }
  }
}
