import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct TOTPVerificationStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case initialize
    case otpVadidated(_ authTicket: AuthTicket)
    case duoPushValidated(_ authTicket: AuthTicket)
    case errorOccurred(StateMachineError, isBackupCode: Bool)
  }

  @Loggable
  public enum Event: Sendable {
    case validateOTP(_ otp: String, isBackupCode: Bool)
    case validateDuoPush
  }

  public var state: State

  private let login: Login
  private let appAPIClient: AppAPIClient
  private let logger: Logger

  init(state: State, login: Login, appAPIClient: AppAPIClient, logger: Logger) {
    self.state = state
    self.login = login
    self.appAPIClient = appAPIClient
    self.logger = logger
  }

  mutating public func transition(with event: Event) async throws {
    switch event {
    case let .validateOTP(otp, isBackupCode):
      await validateOTP(otp, isBackupCode: isBackupCode)
    case .validateDuoPush:
      await validateUsingDUOPush()
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  private mutating func validateOTP(_ otp: String, isBackupCode: Bool) async {
    do {
      let verificationResponse = try await self.appAPIClient.authentication.performTotpVerification(
        login: login.email, otp: otp)
      state = .otpVadidated(AuthTicket(value: verificationResponse.authTicket))
    } catch {
      state = .errorOccurred(StateMachineError(underlyingError: error), isBackupCode: isBackupCode)
    }
  }

  private mutating func validateUsingDUOPush() async {
    do {
      let verificationResponse = try await self.appAPIClient.authentication
        .performDuoPushVerification(login: login.email)
      state = .duoPushValidated(AuthTicket(value: verificationResponse.authTicket))
    } catch {
      state = .errorOccurred(StateMachineError(underlyingError: error), isBackupCode: false)
    }
  }

}

extension TOTPVerificationStateMachine {
  public static var mock: TOTPVerificationStateMachine {
    TOTPVerificationStateMachine(
      state: .initialize, login: Login("_"), appAPIClient: .mock({}), logger: .mock)
  }
}
