import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats

public struct AccountCreationStateMachine: StateMachine {

  public enum AccountType: Hashable {
    case regular(Email, isB2B: Bool)
    case sso(Email, SSOLoginInfo)
  }

  public enum State: Hashable, Sendable {
    case waitingForEmailInput
    case regularAccountCreation(RegularAccountCreationStateMachine.State, Email, isB2B: Bool)
    case ssoAccountCreation(SSOAccountCreationStateMachine.State, Email, SSOLoginInfo)
    case cancelled
  }

  public enum Event: Hashable {
    case start
    case userDidEnterEmail(AccountCreationStateMachine.AccountType)
    case cancel
  }

  public var state: State = .waitingForEmailInput

  let logger: Logger
  let appAPIClient: AppAPIClient
  let sessionContainer: SessionsContainerProtocol
  let sessionCleaner: SessionCleanerProtocol
  let sessionCryptoEngineProvider: CryptoEngineProvider
  let accountCreationSettingsProvider: AccountCreationSettingsProvider
  let accountCreationSharingKeysProvider: AccountCreationSharingKeysProvider
  let passwordGenerator: PasswordGeneratorProtocol

  public init(
    logger: Logger,
    appAPIClient: AppAPIClient,
    sessionCleaner: SessionCleanerProtocol,
    sessionContainer: SessionsContainerProtocol,
    passwordGenerator: PasswordGeneratorProtocol,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    accountCreationSettingsProvider: AccountCreationSettingsProvider,
    accountCreationSharingKeysProvider: AccountCreationSharingKeysProvider
  ) {
    self.logger = logger
    self.appAPIClient = appAPIClient
    self.sessionContainer = sessionContainer
    self.sessionCleaner = sessionCleaner
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.accountCreationSettingsProvider = accountCreationSettingsProvider
    self.accountCreationSharingKeysProvider = accountCreationSharingKeysProvider
    self.passwordGenerator = passwordGenerator
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.waitingForEmailInput, .start):
      state = .waitingForEmailInput
    case (.regularAccountCreation, .cancel), (.ssoAccountCreation, .cancel):
      state = .waitingForEmailInput
    case (_, .cancel):
      state = .cancelled
    case (.waitingForEmailInput, let .userDidEnterEmail(type)):
      switch type {
      case let .regular(email, isB2B):
        state = .regularAccountCreation(.initial, email, isB2B: isB2B)
      case let .sso(login, info):
        state = .ssoAccountCreation(.initial, login, info)
      }
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension AccountCreationStateMachine {
  public func makeSSOAccountCreationFlowStateMachine(login: Login, info: SSOLoginInfo)
    -> SSOAccountCreationStateMachine
  {
    SSOAccountCreationStateMachine(
      login: login,
      info: info,
      logger: logger,
      appAPIClient: appAPIClient,
      sessionContainer: sessionContainer,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      accountCreationSettingsProvider: accountCreationSettingsProvider,
      accountCreationSharingKeysProvider: accountCreationSharingKeysProvider)
  }

  public func makeRegularAccountcreationFlowStateMachine(login: Login, isB2B: Bool)
    -> RegularAccountCreationStateMachine
  {
    let accountCreationService = RegularAccountCreationService(
      sessionsContainer: sessionContainer,
      sessionCleaner: sessionCleaner,
      accountCreationSettingsProvider: accountCreationSettingsProvider,
      accountCreationSharingKeysProvider: accountCreationSharingKeysProvider,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      logger: logger)
    return RegularAccountCreationStateMachine(
      email: Email(login.email), isB2BAccount: isB2B,
      accountCreationService: accountCreationService, passwordGenerator: passwordGenerator,
      logger: logger)
  }
}
