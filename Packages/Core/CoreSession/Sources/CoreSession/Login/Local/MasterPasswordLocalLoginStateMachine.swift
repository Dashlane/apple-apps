import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import UserTrackingFoundation

public struct MasterPasswordLocalLoginStateMachine: StateMachine {

  @Loggable
  public enum Error: Swift.Error {
    case wrongMasterKey
    case noServerKey
    case unknown
  }

  public var state: State = .initial

  @Loggable
  public enum State: Hashable, Sendable {
    case initial
    case waitingForUserInput(isArkEnabled: Bool, isResetMPEnabled: Bool)
    case validationSuccess(LocalLoginConfiguration)
    case validationFailed(Error)
    case resetMPinProgress
    case cancelled
    case logout
    case accountRecoveryFlow(
      AccountRecoveryKeyLoginFlowStateMachine.State,
      AccountRecoveryKeyLoginFlowStateMachine.LoginType)
    case accountRecoveryCancelled
  }

  @Loggable
  public enum Event: Sendable {
    case initialize
    case logout
    case validateMP(String, newMasterPassword: String?)
    case recoveryFinished(AccountRecoveryKeyLoginFlowStateMachine.Completion)
    case cancelled
    case initiateResetMP
    case resetMP
    case startAccountRecovery
    case cancelAccountRecovery
  }

  let login: Login
  let unlocker: UnlockSessionHandler
  let appAPIClient: AppAPIClient
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let unlockMode: MPUserAccountUnlockMode
  let pinCodeAttempts: PinCodeAttemptsProtocol
  private let logger: Logger
  let cryptoEngineProvider: CryptoEngineProvider
  let activityReporter: ActivityReporterProtocol
  let context: LoginUnlockContext

  public init(
    login: Login,
    unlocker: UnlockSessionHandler,
    context: LoginUnlockContext,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    pinCodeAttempts: PinCodeAttemptsProtocol,
    unlockMode: MPUserAccountUnlockMode,
    logger: Logger,
    activityReporter: ActivityReporterProtocol
  ) {
    self.login = login
    self.unlocker = unlocker
    self.appAPIClient = appAPIClient
    self.resetMasterPasswordService = resetMasterPasswordService
    self.unlockMode = unlockMode
    self.logger = logger
    self.pinCodeAttempts = pinCodeAttempts
    self.cryptoEngineProvider = cryptoEngineProvider
    self.activityReporter = activityReporter
    self.context = context
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (_, let .validateMP(password, _)):
      var serverKey: ServerKey?
      if case let .twoFactor(key, _) = unlockMode {
        serverKey = key
      }
      let masterKey = MasterKey.masterPassword(password, serverKey: serverKey)
      await validateMasterKey(masterKey: masterKey)
    case (_, let .recoveryFinished(result)):
      await validateMasterKey(
        masterKey: result.masterKey, newMasterPassword: result.newMasterPassword)
    case (_, .cancelAccountRecovery):
      self.state = .accountRecoveryCancelled
    case (_, .cancelled):
      self.state = .cancelled
    case (_, .logout):
      self.state = .logout
    case (.initial, .initialize):
      await fetchAccountRecoveryKeyStatus(login: login)
    case (_, .initiateResetMP):
      self.state = .resetMPinProgress
    case (.resetMPinProgress, .resetMP):
      do {
        let masterPassword = try self.resetMasterPasswordService.storedMasterPassword()
        await validateMasterKey(masterKey: .masterPassword(masterPassword), shouldResetMP: true)
      } catch {
        self.state = .validationFailed(.unknown)
      }
    case (_, .startAccountRecovery):
      self.state = .accountRecoveryFlow(.loading, .local(unlockMode, .default))
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating func validateMasterKey(
    masterKey: MasterKey,
    shouldResetMP: Bool = false,
    newMasterPassword: String? = nil
  ) async {
    do {
      let session = try await unlocker.validateMasterKey(masterKey)
      var verificationMode: LocalLoginVerificationMode = .none
      if case .twoFactor = unlockMode {
        verificationMode = .otp2
      }
      pinCodeAttempts.removeAll()
      self.state = .validationSuccess(
        LocalLoginConfiguration(
          session: session,
          shouldResetMP: shouldResetMP,
          isRecoveryLogin: newMasterPassword != nil,
          newMasterPassword: newMasterPassword,
          authenticationMode: shouldResetMP ? .resetMasterPassword : .masterPassword,
          verificationMode: verificationMode))
    } catch let error as MasterPasswordLocalLoginStateMachine.Error where error == .wrongMasterKey {
      self.activityReporter.logLoginStatus(.errorWrongPassword, context: context)
      self.state = .validationFailed(.wrongMasterKey)
    } catch let error as LocalLoginStateMachine.Error where error == .wrongMasterKey {
      self.activityReporter.logLoginStatus(.errorWrongPassword, context: context)
      self.state = .validationFailed(.wrongMasterKey)
    } catch {
      self.activityReporter.logLoginStatus(.errorUnknown, context: context)
      self.state = .validationFailed(.unknown)
    }
  }

  mutating func fetchAccountRecoveryKeyStatus(login: Login) async {
    let response = try? await appAPIClient.accountrecovery.getStatus(login: login.email)
    self.state = .waitingForUserInput(
      isArkEnabled: response?.enabled ?? false,
      isResetMPEnabled: resetMasterPasswordService.isActive)
  }
}

extension ActivityReporterProtocol {
  fileprivate func logLoginStatus(_ status: Definition.Status, context: LoginUnlockContext) {
    report(
      UserEvent.Login(
        isBackupCode: context.isBackupCode,
        mode: .masterPassword,
        status: status,
        verificationMode: context.verificationMode
      )
    )
  }

  fileprivate func logForgotPassword(shouldSuggestMPReset: Bool) {
    let shouldSuggestMPReset = shouldSuggestMPReset
    report(
      UserEvent.ForgetMasterPassword(
        hasBiometricReset: shouldSuggestMPReset,
        hasTeamAccountRecovery: false
      )
    )
  }
}

extension MasterPasswordLocalLoginStateMachine {
  public func makeAccountRecoveryKeyLoginFlowStateMachine(
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
  ) -> AccountRecoveryKeyLoginFlowStateMachine {
    AccountRecoveryKeyLoginFlowStateMachine(
      initialState: .loading, login: login, loginType: loginType, accountType: .masterPassword,
      appAPIClient: appAPIClient, cryptoEngineProvider: cryptoEngineProvider, logger: logger)
  }
}

extension MasterPasswordLocalLoginStateMachine {
  public static var mock: MasterPasswordLocalLoginStateMachine {
    MasterPasswordLocalLoginStateMachine(
      login: Login("_"),
      unlocker: .mock(),
      context: .init(origin: .login, localLoginContext: .passwordApp),
      appAPIClient: .mock({}),
      cryptoEngineProvider: .mock(),
      resetMasterPasswordService: ResetMasterPasswordServiceMock(),
      pinCodeAttempts: .mock,
      unlockMode: .masterPasswordOnly,
      logger: .mock,
      activityReporter: .mock)
  }
}
