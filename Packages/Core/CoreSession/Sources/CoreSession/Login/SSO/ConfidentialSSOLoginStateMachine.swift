import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct ConfidentialSSOLoginStateMachine: StateMachine {

  public struct SSOInfo: Hashable, Sendable {
    public let idpAuthorizeUrl: URL
    public let injectionScript: String
    public let domainName: String
    public let teamUuid: String
  }

  @Loggable
  public enum State: Hashable, Sendable {
    case waitingForUserInput
    case ssoInfoReceived(SSOInfo)
    case receivedCallbackInfo(SSOCallbackInfos)
    case failed(StateMachineError)
    case cancelled
  }

  @Loggable
  public enum Event: Sendable {
    case fetchSSOInfo
    case didReceiveCallback(Result<String, Error>)
    case cancel
  }

  public var state: State = .waitingForUserInput

  private let login: Login
  private var secureNitroClient: SecureNitroSSOAPIClient
  private let logger: Logger

  public init(
    login: Login,
    nitroClient: NitroSSOAPIClient,
    nitroSecureTunnelCreatorType: NitroSecureTunnelCreator.Type,
    logger: Logger
  ) async throws {
    let secureNitroClient = try await nitroClient.createSecureNitroSSOAPIClient(
      using: nitroSecureTunnelCreatorType)
    self.init(login: login, secureNitroClient: secureNitroClient, logger: logger)
  }

  public init(
    login: Login,
    secureNitroClient: SecureNitroSSOAPIClient,
    logger: Logger
  ) {
    self.login = login
    self.secureNitroClient = secureNitroClient
    self.logger = logger
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (_, .fetchSSOInfo):
      await fetchSSOInfo()
    case (let .ssoInfoReceived(info), let .didReceiveCallback(result)):
      await handleCallback(result: result, with: info)
    case (_, .cancel):
      state = .cancelled
    default:
      let errorMessage: LogMessage = "Unexpected \(event) event for the state \(state)"
      logger.fatal(errorMessage)
      throw InvalidTransitionError<Self>(event: event, state: state)
    }
    let state = state
    logger.info("Transition to state \(state)")
  }

  private mutating func fetchSSOInfo() async {
    do {
      let loginResponse = try await secureNitroClient.authentication.requestLogin2(
        login: login.email)
      let script = try ConfidentialSSOInjectionScript.script(
        callbackURL: loginResponse.spCallbackUrl)
      guard let idpAuthorizeUrl = URL(string: loginResponse.idpAuthorizeUrl) else {
        throw URLError(.badURL)
      }
      state = .ssoInfoReceived(
        SSOInfo(
          idpAuthorizeUrl: idpAuthorizeUrl, injectionScript: script,
          domainName: loginResponse.domainName, teamUuid: loginResponse.teamUuid))
    } catch {
      state = .failed(StateMachineError(underlyingError: error))
    }
  }

  private mutating func handleCallback(result: Result<String, Error>, with ssoInfo: SSOInfo) async {
    switch result {
    case let .success(saml):
      await self.callbackInfo(
        withSAML: saml, teamUuid: ssoInfo.teamUuid, domainName: ssoInfo.domainName)
    case let .failure(error):
      state = .failed(StateMachineError(underlyingError: error))
    }
  }

  private mutating func callbackInfo(withSAML saml: String, teamUuid: String, domainName: String)
    async
  {
    do {
      let response = try await secureNitroClient.authentication.confirmLogin2(
        teamUuid: teamUuid, domainName: domainName, samlResponse: saml)
      let ssoCallbackInfo = SSOCallbackInfos(
        ssoToken: response.ssoToken, serviceProviderKey: response.userServiceProviderKey,
        exists: response.exists)
      state = .receivedCallbackInfo(ssoCallbackInfo)
    } catch {
      state = .failed(StateMachineError(underlyingError: error))
    }
  }
}
