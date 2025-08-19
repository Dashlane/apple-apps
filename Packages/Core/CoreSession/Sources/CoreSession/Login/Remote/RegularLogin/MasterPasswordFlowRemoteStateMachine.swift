import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import StateMachine

public struct MasterPasswordFlowRemoteStateMachine: StateMachine {

  @Loggable
  public enum State: Hashable, Sendable {
    case initialize
    case accountVerification(VerificationMethod, DeviceInfo)
    case masterPasswordValidation(
      MasterPasswordInputRemoteStateMachine.State, DeviceRegistrationData)
    case masterPasswordValidated(RemoteLoginSession)
    case failed(StateMachineError)
  }

  @Loggable
  public enum Event: Sendable {
    case initialize
    case accountVerificationDidFinish(AuthTicket, isBackupCode: Bool, VerificationMethod)
    case accountVerificationFailed(StateMachineError)
    case masterPasswordValidated(RemoteLoginSession)
  }

  public var state: State

  private let login: Login
  private let appAPIClient: AppAPIClient
  private let cryptoEngineProvider: CryptoEngineProvider
  private let deviceInfo: DeviceInfo
  private let logger: Logger
  private let verificationMethod: VerificationMethod
  private let remoteLogger: RemoteLogger

  public init(
    state: MasterPasswordFlowRemoteStateMachine.State,
    verificationMethod: VerificationMethod,
    deviceInfo: DeviceInfo,
    login: Login,
    appAPIClient: AppAPIClient,
    cryptoEngineProvider: CryptoEngineProvider,
    logger: Logger,
    remoteLogger: RemoteLogger
  ) {
    self.state = .accountVerification(verificationMethod, deviceInfo)
    self.login = login
    self.appAPIClient = appAPIClient
    self.cryptoEngineProvider = cryptoEngineProvider
    self.deviceInfo = deviceInfo
    self.logger = logger
    self.verificationMethod = verificationMethod
    self.remoteLogger = remoteLogger
  }

  public mutating func transition(with event: Event) async throws {
    switch (state, event) {
    case (_, .initialize):
      state = .accountVerification(verificationMethod, deviceInfo)
    case (_, let .accountVerificationDidFinish(authTicket, isBackupCode, verificationMethod)):
      await registerDevice(
        withAuthTicket: authTicket, isBackupCode: isBackupCode,
        verificationMethod: verificationMethod)
    case (_, let .accountVerificationFailed(error)):
      self.state = .failed(error)
    case (_, let .masterPasswordValidated(remoteSession)):
      state = .masterPasswordValidated(remoteSession)
    }
    let state = state
    logger.info("Transition to state: \(state)")
  }

  private mutating func registerDevice(
    withAuthTicket authTicket: AuthTicket, isBackupCode: Bool,
    verificationMethod: VerificationMethod
  ) async {
    do {
      let deviceRegistrationResponse = try await appAPIClient.authentication
        .completeDeviceRegistrationWithAuthTicket(
          device: deviceInfo, login: login.email, authTicket: authTicket.value)
      let deviceRegistrationData = DeviceRegistrationData(
        initialSettings: deviceRegistrationResponse.settings.content,
        deviceAccessKey: deviceRegistrationResponse.deviceAccessKey,
        deviceSecretKey: deviceRegistrationResponse.deviceSecretKey,
        analyticsIds: deviceRegistrationResponse.analyticsIds,
        authTicket: authTicket.value,
        verificationMethod: verificationMethod,
        serverKey: deviceRegistrationResponse.serverKey,
        remoteKeys: deviceRegistrationResponse.remoteKeys,
        isBackupCode: isBackupCode)
      remoteLogger.configureReportedDeviceId(deviceRegistrationResponse.deviceAccessKey)
      self.state = .masterPasswordValidation(.waitingForUserInput(false), deviceRegistrationData)
    } catch {
      self.state = .failed(StateMachineError(underlyingError: error))
      logger.error("Device registration failed", error: error)
    }
  }
}

extension MasterPasswordFlowRemoteStateMachine {
  public static var mock: MasterPasswordFlowRemoteStateMachine {
    MasterPasswordFlowRemoteStateMachine(
      state: .initialize, verificationMethod: .emailToken, deviceInfo: .mock, login: Login(""),
      appAPIClient: .mock({}), cryptoEngineProvider: .mock(), logger: .mock, remoteLogger: .mock)
  }
}

extension MasterPasswordFlowRemoteStateMachine {
  public func makeMasterPasswordInputRemoteStateMachine(
    state: MasterPasswordInputRemoteStateMachine.State,
    data: DeviceRegistrationData
  ) -> MasterPasswordInputRemoteStateMachine {
    MasterPasswordInputRemoteStateMachine(
      state: state, login: login, data: data, appAPIClient: appAPIClient,
      cryptoEngineProvider: cryptoEngineProvider, logger: logger)
  }

  public func makeAccountVerificationStateMachine(verificationMethod: VerificationMethod)
    -> AccountVerificationStateMachine
  {
    AccountVerificationStateMachine(
      state: .initialize, login: login, verificationMethod: verificationMethod,
      appAPIClient: appAPIClient, logger: logger)
  }
}
