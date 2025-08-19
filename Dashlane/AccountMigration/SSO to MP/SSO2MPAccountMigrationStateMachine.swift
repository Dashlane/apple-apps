import CoreSession
import DashlaneAPI
import Foundation
import StateMachine

struct SSO2MPAccountMigrationStateMachine: StateMachine {
  enum State: Hashable {
    case confirmation
    case masterPasswordCreation(AuthTicket)
    case ssoAuthentication(SSOAuthenticationInfo)
    case migration(AccountMigrationConfiguration)
    case completed(Session)
    case failed(StateMachineError)
    case cancelled
  }

  enum Event {
    case startMigration
    case ssoAuthenticationCompleted(SSOCallbackInfos)
    case migrate(_ newMasterPassword: String)
    case complete(_ session: Session)
    case cancel
    case failed(Error)
  }

  private(set) var state: State = .confirmation

  private let session: Session
  private let migrationInfos: AccountMigrationInfos
  private let appAPIClient: AppAPIClient
  private let userDeviceAPIClient: UserDeviceAPIClient

  init(
    session: Session,
    migrationInfos: AccountMigrationInfos,
    appAPIClient: AppAPIClient,
    userDeviceAPIClient: UserDeviceAPIClient
  ) {
    self.session = session
    self.migrationInfos = migrationInfos
    self.appAPIClient = appAPIClient
    self.userDeviceAPIClient = userDeviceAPIClient
  }

  mutating func transition(with event: Event) async throws {
    switch event {
    case .startMigration:
      switch state {
      case .confirmation:
        if let authTicket = migrationInfos.authTicket {
          state = .masterPasswordCreation(authTicket)
        } else {
          state = .ssoAuthentication(migrationInfos.ssoAuthenticationInfo)
        }

      case .masterPasswordCreation, .ssoAuthentication, .migration, .completed, .cancelled, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .ssoAuthenticationCompleted(let callbackInfos):
      switch state {
      case .ssoAuthentication:
        do {
          let verificationResponse = try await appAPIClient.authentication
            .performSsoVerification(
              login: migrationInfos.session.login.email,
              ssoToken: callbackInfos.ssoToken
            )

          state = .masterPasswordCreation(AuthTicket(value: verificationResponse.authTicket))
        } catch {
          state = .failed(StateMachineError(underlyingError: error))
        }

      case .confirmation, .masterPasswordCreation, .migration, .completed, .cancelled, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .migrate(let masterPassword):
      switch state {
      case .masterPasswordCreation(let authTicket):
        do {
          let configuration: AccountMigrationConfiguration = .ssoToMasterPassword(
            session: session,
            authTicket: authTicket,
            newMasterPassword: masterPassword,
            cryptoConfigHeader: try await fetchTeamSpaceCryptoConfigHeader()
          )

          state = .migration(configuration)
        } catch {
          state = .failed(StateMachineError(underlyingError: error))
        }

      case .confirmation, .ssoAuthentication, .migration, .completed, .cancelled, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .complete(let session):
      switch state {
      case .migration:
        self.state = .completed(session)

      case .confirmation, .masterPasswordCreation, .ssoAuthentication, .completed, .cancelled,
        .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .failed(let error):
      switch state {
      case .confirmation, .masterPasswordCreation, .ssoAuthentication, .migration:
        self.state = .failed(StateMachineError(underlyingError: error))

      case .completed, .cancelled, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }

    case .cancel:
      switch state {
      case .confirmation, .ssoAuthentication, .masterPasswordCreation:
        self.state = .cancelled

      case .migration, .completed, .cancelled, .failed:
        throw InvalidTransitionError<Self>(event: event, state: state)
      }
    }
  }

  private func fetchTeamSpaceCryptoConfigHeader() async throws -> CryptoEngineConfigHeader? {
    let status = try await userDeviceAPIClient.premium.getPremiumStatus()
    guard status.b2bStatus?.statusCode == .inTeam else {
      return nil
    }

    return status.b2bStatus?.currentTeam?.teamInfo.cryptoForcedPayload
  }
}
