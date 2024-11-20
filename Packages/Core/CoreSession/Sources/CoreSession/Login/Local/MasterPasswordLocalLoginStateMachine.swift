import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public struct MasterPasswordLocalLoginStateMachine: StateMachine {

  public enum Error: Swift.Error {
    case wrongMasterKey
    case noServerKey
    case unknown
  }

  public var state: State = .waitingForUserInput(false)

  public enum State: Hashable {
    case waitingForUserInput(Bool)
    case validationInProgress
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

  public enum Event {
    case logout
    case initiateMPvalidation
    case validateMP(String, newMasterPassword: String?)
    case recoveryFinished(AccountRecoveryKeyLoginFlowStateMachine.Completion)
    case cancelled
    case initiateResetMP
    case resetMP
    case startAccountRecovery
    case cancelAccountRecovery
    case fetchAccountRecoveryKeyStatus
  }

  let login: Login
  let unlocker: UnlockSessionHandler
  let appAPIClient: AppAPIClient
  let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
  let loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
  private let logger: Logger

  public init(
    login: Login,
    unlocker: UnlockSessionHandler,
    appAPIClient: AppAPIClient,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType,
    logger: Logger
  ) {
    self.login = login
    self.unlocker = unlocker
    self.appAPIClient = appAPIClient
    self.resetMasterPasswordService = resetMasterPasswordService
    self.loginType = loginType
    self.logger = logger
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (_, .initiateMPvalidation):
      self.state = .validationInProgress
    case (.validationInProgress, let .validateMP(password, _)):
      let masterKey = MasterKey.masterPassword(password, serverKey: nil)
      await validateMasterKey(masterKey: masterKey)
    case (_, let .recoveryFinished(result)):
      await validateMasterKey(
        masterKey: result.masterKey, newMasterPassword: result.newMasterPassword,
        isRecoveryLogin: true)
    case (_, .cancelAccountRecovery):
      self.state = .accountRecoveryCancelled
    case (_, .cancelled):
      self.state = .cancelled
    case (_, .logout):
      self.state = .logout
    case (.waitingForUserInput, .fetchAccountRecoveryKeyStatus):
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
      self.state = .accountRecoveryFlow(.loading, loginType)
    default:
      let errorMessage = "Unexpected \(event) event for the state \(state)"
      logger.error(errorMessage)
    }
    logger.logInfo("Transition to state: \(state)")
  }

  mutating func validateMasterKey(
    masterKey: MasterKey,
    shouldResetMP: Bool = false,
    newMasterPassword: String? = nil,
    isRecoveryLogin: Bool = false
  ) async {
    do {
      let session = try await unlocker.validateMasterKey(masterKey)
      self.state = .validationSuccess(
        LocalLoginConfiguration(
          session: session, shouldResetMP: shouldResetMP, isRecoveryLogin: isRecoveryLogin,
          newMasterPassword: newMasterPassword))
    } catch let error as MasterPasswordLocalLoginStateMachine.Error where error == .wrongMasterKey {
      self.state = .validationFailed(.wrongMasterKey)
    } catch {
      self.state = .validationFailed(.unknown)
    }
  }

  mutating func fetchAccountRecoveryKeyStatus(login: Login) async {
    let response = try? await appAPIClient.accountrecovery.getStatus(login: login.email)
    self.state = .waitingForUserInput(response?.enabled ?? false)
  }
}
