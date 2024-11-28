import DashTypes
import DashlaneAPI
import Foundation
import StateMachine

@MainActor
public struct RegularRemoteLoginStateMachine: StateMachine {

  public enum Error: Swift.Error, Equatable {
    case wrongMasterKey
    case userDataNotFetched
    case invalidServiceProviderKey
  }

  public enum State: Hashable {
    case initializing
    case masterPasswordFlow(
      MasterPasswordFlowRemoteStateMachine.State, VerificationMethod, DeviceInfo)
    case completed(RemoteLoginSession)
    case ssoLoginFlow(SSORemoteStateMachine.State, SSOAuthenticationInfo, DeviceInfo)
    case failed(StateMachineError)
    case cancelled
  }

  public enum Event {
    case initialize
    case ssoFlowDidFinish(RemoteLoginSession)
    case masterPasswordFlowDidFinish(RemoteLoginSession)
    case failed(StateMachineError)
    case cancel
  }

  public var state: State = .initializing

  private let logger: Logger
  public let login: Login
  private let sessionsContainer: SessionsContainerProtocol
  public let deviceInfo: DeviceInfo
  public let deviceRegistrationMethod: LoginMethod
  private let cryptoEngineProvider: CryptoEngineProvider
  private let appAPIClient: AppAPIClient

  public init(
    login: Login,
    deviceRegistrationMethod: LoginMethod,
    deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil,
    appAPIClient: AppAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider
  ) {
    self.login = login
    self.sessionsContainer = sessionsContainer
    self.logger = logger
    self.deviceInfo = deviceInfo
    self.deviceRegistrationMethod = deviceRegistrationMethod
    self.appAPIClient = appAPIClient
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  public mutating func transition(with event: Event) async {
    logger.logInfo("Received event \(event)")
    switch (state, event) {
    case (_, .initialize):
      switch deviceRegistrationMethod {
      case .tokenByEmail:
        state = .masterPasswordFlow(.initialize, .emailToken, deviceInfo)
      case let .thirdPartyOTP(option, _):
        state = .masterPasswordFlow(.initialize, .totp(option.pushType), deviceInfo)
      case let .loginViaSSO(ssoAuthenticationInfo):
        state = .ssoLoginFlow(.waitingForUserInput, ssoAuthenticationInfo, deviceInfo)
      }
    case (_, let .ssoFlowDidFinish(session)):
      state = .completed(session)
    case (_, let .masterPasswordFlowDidFinish(session)):
      state = .completed(session)
    case (_, let .failed(error)):
      state = .failed(error)
    case (_, .cancel):
      state = .cancelled
    }
    logger.logInfo("Transition to state: \(state)")
  }
}

extension RegularRemoteLoginStateMachine {
  public static var mock: RegularRemoteLoginStateMachine {
    return RegularRemoteLoginStateMachine(
      login: Login("_"),
      deviceRegistrationMethod: .tokenByEmail(),
      deviceInfo: .mock,
      appAPIClient: .fake,
      sessionsContainer: SessionsContainer<InMemorySessionStoreProvider>.mock,
      logger: LoggerMock(),
      cryptoEngineProvider: FakeCryptoEngineProvider()
    )
  }
}
