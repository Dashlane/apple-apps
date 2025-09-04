import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine
import UserTrackingFoundation

public struct SSOUnlockStateMachine: StateMachine {

  @Loggable
  enum Error: Swift.Error {
    case invalidLoginMethod
  }

  @Loggable
  public enum State: Hashable, Sendable {
    case locked
    case ssoLogin(SSOLocalStateMachine.State, SSOAuthenticationInfo, deviceAccessKey: String)
    case logout
    case failed(StateMachineError)
    case cancelled
    case completed(SSOKeys)
  }

  @Loggable
  public enum Event: Sendable {
    case ssoLogin
    case logout
    case cancel
    case ssoLoginFailed(StateMachineError)
    case ssoLoginCompleted(SSOKeys)
  }

  public var state: State
  private let login: Login
  private let apiClient: AppAPIClient
  private let nitroClient: NitroSSOAPIClient
  private let deviceAccessKey: String
  private let cryptoEngineProvider: CryptoEngineProvider
  private let logger: Logger
  private let activityReporter: ActivityReporterProtocol

  public init(
    state: SSOUnlockStateMachine.State,
    login: Login, apiClient: AppAPIClient,
    nitroClient: NitroSSOAPIClient,
    deviceAccessKey: String,
    cryptoEngineProvider: CryptoEngineProvider,
    logger: Logger,
    activityReporter: ActivityReporterProtocol
  ) {
    self.state = state
    self.login = login
    self.apiClient = apiClient
    self.nitroClient = nitroClient
    self.deviceAccessKey = deviceAccessKey
    self.cryptoEngineProvider = cryptoEngineProvider
    self.logger = logger
    self.activityReporter = activityReporter
  }

  mutating public func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (.locked, .ssoLogin):
      await fetchSSOInfo()
    case (_, .logout):
      state = .logout
    case (_, .cancel):
      state = .cancelled
    case (.ssoLogin, let .ssoLoginFailed(error)):
      state = .failed(error)
    case (.ssoLogin, let .ssoLoginCompleted(keys)):
      state = .completed(keys)
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  mutating func fetchSSOInfo() async {
    do {
      let ssoAuthenticationInfo = try await self.apiClient.authentication.ssoInfo(
        for: login, deviceAccessKey: deviceAccessKey)
      state = .ssoLogin(
        .waitingForUserInput, ssoAuthenticationInfo, deviceAccessKey: deviceAccessKey)
      activityReporter.report(
        UserEvent.AskAuthentication(
          mode: .sso,
          reason: .unlockApp))
    } catch {
      logger.error("Couldn't fetch sso info")
      state = .failed(StateMachineError(underlyingError: error))
    }
  }
}

extension AppAPIClient.Authentication {
  fileprivate func ssoInfo(for login: Login, deviceAccessKey: String) async throws
    -> SSOAuthenticationInfo
  {
    let response = try await getAuthenticationMethodsForLogin(
      login: login.email,
      deviceAccessKey: deviceAccessKey,
      methods: [.emailToken, .totp, .duoPush],
      profiles: [
        AuthenticationMethodsLoginProfiles(
          login: login.email,
          deviceAccessKey: deviceAccessKey
        )
      ],
      u2fSecret: nil
    )
    let loginMethod = response.verifications.loginMethod(for: login)

    guard case let .loginViaSSO(ssoAuthenticationInfo) = loginMethod else {
      throw SSOUnlockStateMachine.Error.invalidLoginMethod
    }
    return ssoAuthenticationInfo
  }
}

extension SSOUnlockStateMachine {
  public func makeSSOLocalStateMachine(
    initialState: SSOLocalStateMachine.State, ssoAuthenticationInfo: SSOAuthenticationInfo
  ) -> SSOLocalStateMachine {
    SSOLocalStateMachine(
      initialState: initialState, ssoAuthenticationInfo: ssoAuthenticationInfo,
      deviceAccessKey: deviceAccessKey, apiClient: apiClient,
      cryptoEngineProvider: cryptoEngineProvider, logger: logger)
  }
}

extension SSOUnlockStateMachine {
  public static var mock: SSOUnlockStateMachine {
    SSOUnlockStateMachine(
      state: .ssoLogin(.waitingForUserInput, .mock(), deviceAccessKey: "deviceAccessKey"),
      login: Login("_"), apiClient: .fake, nitroClient: .fake, deviceAccessKey: "deviceAccessKey",
      cryptoEngineProvider: .mock(), logger: .mock, activityReporter: .mock)
  }
}
