import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct TokenVerificationStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case waitingForTokenInput
    case qaTokenReceived(token: String)
    case tokenValidated(_ authTicket: AuthTicket)
    case errorOccured(StateMachineError)
  }

  @Loggable
  public enum Event: Sendable {
    case requestToken
    case requestQAToken
    case validateToken(_ token: String)
  }

  public var state: State

  private let appAPIClient: AppAPIClient
  private let login: Login
  private let logger: Logger

  init(state: State, login: Login, appAPIClient: AppAPIClient, logger: Logger) {
    self.state = state
    self.login = login
    self.appAPIClient = appAPIClient
    self.logger = logger
  }

  mutating public func transition(with event: Event) async throws {
    switch event {
    case .requestToken:
      await requestToken()
    case .requestQAToken:
      await qaToken()
    case let .validateToken(token):
      await validateToken(token)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  private mutating func requestToken() async {
    do {
      _ = try await appAPIClient.authentication.requestEmailTokenVerification(login: login.email)
      self.state = .waitingForTokenInput
    } catch {
      self.state = .errorOccured(StateMachineError(underlyingError: error))
    }
  }

  private mutating func qaToken() async {
    do {
      let token = try await appAPIClient.authenticationQA.getDeviceRegistrationTokenForTestLogin(
        login: login.email
      ).token
      self.state = .qaTokenReceived(token: token)
    } catch {}
  }

  private mutating func validateToken(_ token: String) async {
    do {
      let verificationResponse = try await self.appAPIClient.authentication
        .performEmailTokenVerification(login: login.email, token: token)
      self.state = .tokenValidated(AuthTicket(value: verificationResponse.authTicket))
    } catch {
      self.state = .errorOccured(StateMachineError(underlyingError: error))
    }

  }
}

extension TokenVerificationStateMachine {
  public static var mock: TokenVerificationStateMachine {
    TokenVerificationStateMachine(
      state: .waitingForTokenInput, login: Login("_"), appAPIClient: .mock({}), logger: .mock)
  }
}
