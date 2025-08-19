import CoreTypes
import CyrilKit
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import SwiftTreats

public struct RegularAccountCreationStateMachine: StateMachine {

  public enum State: Hashable, Sendable {
    case initial
    case waitingForUserInput(
      email: CoreTypes.Email,
      isB2BAccount: Bool)
    case passwordAccountCreation(
      MasterPasswordAccountCreationStateMachine.State, AccountCreationConfiguration)
    case passwordlessAccountCreation(
      PasswordlessAccountCreationStateMachine.State, AccountCreationConfiguration)
    case accountCreated
    case cancelled
  }

  public enum Event: Hashable {
    case start
    case userEnteredPassword(password: String)
    case createPasswordlessAccount
    case accountCreated
    case cancel
  }

  public var state: State = .initial

  let email: Email
  let isB2BAccount: Bool
  let accountCreationService: RegularAccountCreationServiceProtocol
  let logger: Logger
  let passwordGenerator: PasswordGeneratorProtocol

  public init(
    email: Email,
    isB2BAccount: Bool,
    accountCreationService: RegularAccountCreationServiceProtocol,
    passwordGenerator: PasswordGeneratorProtocol,
    logger: Logger
  ) {
    self.email = email
    self.isB2BAccount = isB2BAccount
    self.accountCreationService = accountCreationService
    self.logger = logger
    self.passwordGenerator = passwordGenerator
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.initial, .start):
      state = .waitingForUserInput(email: email, isB2BAccount: isB2BAccount)
    case (.waitingForUserInput, .userEnteredPassword(password: let password)):
      state = .passwordAccountCreation(
        .initial,
        AccountCreationConfiguration(email: email, password: password, accountType: .masterPassword)
      )
    case (.waitingForUserInput, .createPasswordlessAccount):
      let password = passwordGenerator.generate()
      state = .passwordlessAccountCreation(
        .initial,
        AccountCreationConfiguration(
          email: email, password: password, accountType: .invisibleMasterPassword))
    case (.passwordAccountCreation, .accountCreated),
      (.passwordlessAccountCreation, .accountCreated):
      state = .accountCreated
    case (.passwordlessAccountCreation, .cancel):
      state = .waitingForUserInput(email: email, isB2BAccount: isB2BAccount)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension RegularAccountCreationStateMachine {
  public func makeMasterPasswordAccountCreationFlowStateMachine(
    configuration: AccountCreationConfiguration
  ) -> MasterPasswordAccountCreationStateMachine {
    MasterPasswordAccountCreationStateMachine(
      configuration: configuration, biometry: Device.biometryType,
      accountCreationService: accountCreationService, logger: logger)
  }

  public func makePasswordlessAccountCreationFlowStateMachine(
    configuration: AccountCreationConfiguration
  ) -> PasswordlessAccountCreationStateMachine {
    PasswordlessAccountCreationStateMachine(
      configuration: configuration, biometry: Device.biometryType,
      accountCreationService: accountCreationService, logger: logger)
  }
}
