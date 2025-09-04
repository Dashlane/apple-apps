import CoreSession
import DashlaneAPI
import Foundation
import LoginKit
import StateMachine

struct MP2SSOAccountMigrationStateMachine: StateMachine {

  var state: State = .confirmation

  enum State: Hashable, Sendable {
    case confirmation
    case ssoAuthentication(SSOAuthenticationInfo)
    case migration(AccountMigrationConfiguration)
    case completed(Session)
    case failed(StateMachineError)
    case cancelled
  }

  enum Event {
    case startSSOAuthentication
    case ssoAuthenticationCompleted(SSOCallbackInfos)
    case migrationCompleted(Session)
    case failed(Error)
    case back
  }

  private let session: Session
  private let migrationInfos: AccountMigrationInfos
  private let appAPIClient: AppAPIClient
  private let sessionCryptoEngineProvider: SessionCryptoEngineProvider

  init(
    session: Session,
    migrationInfos: AccountMigrationInfos,
    appAPIClient: AppAPIClient,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider
  ) {
    self.session = session
    self.migrationInfos = migrationInfos
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
  }

  mutating func transition(with event: Event) async throws {
    switch event {
    case .startSSOAuthentication:
      switch state {
      case .confirmation:
        self.state = .ssoAuthentication(migrationInfos.ssoAuthenticationInfo)
      case .ssoAuthentication, .migration, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .ssoAuthenticationCompleted(let callbackInfos):
      switch state {
      case .ssoAuthentication:
        do {
          state = .migration(
            try await makeAccountMigrationConfiguration(callbackInfos: callbackInfos))
        } catch {
          state = .failed(StateMachineError(underlyingError: error))
        }
      case .confirmation, .migration, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .migrationCompleted(let session):
      switch state {
      case .migration:
        self.state = .completed(session)
      case .confirmation, .ssoAuthentication, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .failed(let error):
      switch state {
      case .confirmation, .ssoAuthentication, .migration:
        self.state = .failed(StateMachineError(underlyingError: error))
      case .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .back:
      switch state {
      case .confirmation:
        self.state = .cancelled
      case .ssoAuthentication:
        self.state = .confirmation
      case .migration, .completed, .failed, .cancelled:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }
    }
  }

  private func makeAccountMigrationConfiguration(callbackInfos: SSOCallbackInfos) async throws
    -> AccountMigrationConfiguration
  {
    let authTicket = try await authenticationTicket(with: callbackInfos)
    return try .masterPasswordToSSO(
      session: session,
      authTicket: authTicket,
      serviceProviderKey: callbackInfos.serviceProviderKey,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider
    )
  }

  private func authenticationTicket(with callbackInfos: SSOCallbackInfos) async throws -> AuthTicket
  {
    if let authTicket = migrationInfos.authTicket {
      return authTicket
    }

    let verificationResponse = try await appAPIClient.authentication.performSsoVerification(
      login: migrationInfos.session.login.email,
      ssoToken: callbackInfos.ssoToken
    )
    return AuthTicket(value: verificationResponse.authTicket)
  }
}
