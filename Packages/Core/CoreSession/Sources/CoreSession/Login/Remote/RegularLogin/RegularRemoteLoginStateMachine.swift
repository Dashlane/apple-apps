import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct RegularRemoteLoginStateMachine: StateMachine {

  @Loggable
  public enum Error: Swift.Error, Equatable {
    case wrongMasterKey
    case userDataNotFetched
    case invalidServiceProviderKey
  }

  @Loggable
  public enum State: Hashable, Sendable {
    case initializing
    case masterPasswordFlow(
      MasterPasswordFlowRemoteStateMachine.State, VerificationMethod, DeviceInfo)
    case completed(RemoteLoginSession)
    case ssoLoginFlow(SSORemoteStateMachine.State, SSOAuthenticationInfo)
    case failed(StateMachineError)
    case cancelled
  }

  @Loggable
  public enum Event: Sendable {
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
  private let remoteLogger: RemoteLogger

  public init(
    login: Login,
    deviceRegistrationMethod: LoginMethod,
    deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil,
    appAPIClient: AppAPIClient,
    sessionsContainer: SessionsContainerProtocol,
    logger: Logger,
    cryptoEngineProvider: CryptoEngineProvider,
    remoteLogger: RemoteLogger
  ) {
    self.login = login
    self.sessionsContainer = sessionsContainer
    self.logger = logger
    self.deviceInfo = deviceInfo
    self.deviceRegistrationMethod = deviceRegistrationMethod
    self.appAPIClient = appAPIClient
    self.cryptoEngineProvider = cryptoEngineProvider
    self.remoteLogger = remoteLogger
  }

  public mutating func transition(with event: Event) async throws {
    logger.info("Received event \(event)")
    switch (state, event) {
    case (_, .initialize):
      switch deviceRegistrationMethod {
      case .tokenByEmail:
        state = .masterPasswordFlow(.initialize, .emailToken, deviceInfo)
      case let .thirdPartyOTP(option, _):
        state = .masterPasswordFlow(.initialize, .totp(option.pushType), deviceInfo)
      case let .loginViaSSO(ssoAuthenticationInfo):
        state = .ssoLoginFlow(.waitingForUserInput, ssoAuthenticationInfo)
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
    let state = state
    logger.info("Transition to state: \(state)")
  }
}

extension RegularRemoteLoginStateMachine {
  public static var mock: RegularRemoteLoginStateMachine {
    return RegularRemoteLoginStateMachine(
      login: Login("_"),
      deviceRegistrationMethod: .tokenByEmail(),
      deviceInfo: .mock,
      appAPIClient: .fake,
      sessionsContainer: .mock,
      logger: .mock,
      cryptoEngineProvider: .mock(),
      remoteLogger: .mock
    )
  }
}

extension RegularRemoteLoginStateMachine {
  public func makeSSORemoteStateMachine(ssoAuthenticationInfo: SSOAuthenticationInfo)
    -> SSORemoteStateMachine
  {
    SSORemoteStateMachine(
      ssoAuthenticationInfo: ssoAuthenticationInfo, deviceInfo: deviceInfo, apiClient: appAPIClient,
      cryptoEngineProvider: cryptoEngineProvider, logger: logger, remoteLogger: remoteLogger)
  }

  public func makeMasterPasswordFlowRemoteStateMachine(
    state: MasterPasswordFlowRemoteStateMachine.State, verificationMethod: VerificationMethod
  ) -> MasterPasswordFlowRemoteStateMachine {
    MasterPasswordFlowRemoteStateMachine(
      state: state, verificationMethod: verificationMethod, deviceInfo: deviceInfo, login: login,
      appAPIClient: appAPIClient, cryptoEngineProvider: cryptoEngineProvider, logger: logger,
      remoteLogger: remoteLogger)
  }
}
