import Combine
import CoreSession
import DashTypes
import Foundation
import StateMachine

@MainActor
public class RemoteLoginFlowViewModel: StateMachineBasedObservableObject, LoginKitServicesInjecting
{

  public enum Completion {
    case dismiss
    case logout
    case migrateAccount(migrationInfos: AccountMigrationInfos)
    case completed(RemoteLoginConfiguration, LoginFlowLogInfo)
  }

  enum Step {
    case login(RemoteLoginType)
    case deviceUnlinking(DeviceUnlinker, RemoteLoginSession, LoginFlowLogInfo)
  }

  @Published
  var step: Step

  let purchasePlanFlowProvider: PurchasePlanFlowProvider
  let sessionActivityReporterProvider: SessionActivityReporterProvider
  let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
  let remoteLoginViewModelFactory: RegularRemoteLoginFlowViewModel.Factory
  let tokenPublisher: AnyPublisher<String, Never>
  let completion: @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  let deviceToDeviceLoginFlowViewModelFactory: DeviceTransferQRCodeFlowModel.Factory
  let deviceTransferLoginFlowModelFactory: DeviceTransferLoginFlowModel.Factory
  public var stateMachine: RemoteLoginStateMachine

  public init(
    type: RemoteLoginType,
    deviceInfo: DeviceInfo,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    remoteLoginViewModelFactory: RegularRemoteLoginFlowViewModel.Factory,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    deviceToDeviceLoginFlowViewModelFactory: DeviceTransferQRCodeFlowModel.Factory,
    deviceTransferLoginFlowModelFactory: DeviceTransferLoginFlowModel.Factory,
    tokenPublisher: AnyPublisher<String, Never>,
    deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
    remoteLoginStateMachineFactory: RemoteLoginStateMachine.Factory,
    completion: @escaping @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  ) {
    self.stateMachine = remoteLoginStateMachineFactory.make(type: type, deviceInfo: deviceInfo)
    self.purchasePlanFlowProvider = purchasePlanFlowProvider
    self.sessionActivityReporterProvider = sessionActivityReporterProvider
    self.completion = completion
    self.tokenPublisher = tokenPublisher
    self.deviceUnlinkingFactory = deviceUnlinkingFactory
    self.remoteLoginViewModelFactory = remoteLoginViewModelFactory
    self.deviceToDeviceLoginFlowViewModelFactory = deviceToDeviceLoginFlowViewModelFactory
    self.deviceTransferLoginFlowModelFactory = deviceTransferLoginFlowModelFactory
    self.step = .login(type)
    Task {
      await perform(.initialize)
    }
  }

  public func update(
    for event: RemoteLoginStateMachine.Event, from oldState: RemoteLoginStateMachine.State,
    to newState: RemoteLoginStateMachine.State
  ) async {
    switch (state, event) {
    case (let .completed(config), _):
      self.completion(.success(.completed(config, LoginFlowLogInfo(loginMode: .masterPassword))))
    case (let .migrateAccount(info), _):
      self.completion(.success(.migrateAccount(migrationInfos: info)))
    case (.cancelled, _):
      self.completion(.success(.dismiss))
    case (.logout, _):
      self.completion(.success(.logout))
    case (let .authentication(type), _):
      self.step = .login(type)
    case (let .deviceUnlink(unlinker, remoteLoginSession), _):
      self.step = .deviceUnlinking(
        unlinker, remoteLoginSession, LoginFlowLogInfo(loginMode: .deviceTransfer))
    case (let .failed(error), _):
      self.completion(.failure(error.underlyingError))
    }
  }
}

extension RemoteLoginFlowViewModel {
  func makeRegularRemoteLoginFlowViewModel(
    login: Login,
    deviceRegistrationMethod: LoginMethod,
    deviceInfo: DeviceInfo
  ) -> RegularRemoteLoginFlowViewModel {
    return remoteLoginViewModelFactory.make(
      login: login,
      deviceRegistrationMethod: deviceRegistrationMethod,
      deviceInfo: deviceInfo, tokenPublisher: tokenPublisher
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .success(successResult):
          switch successResult {
          case let .completed(loginSession, logInfo):
            await self.perform(.regularLoginDidFinish(loginSession))
          case .cancel:
            await self.perform(.cancel)
          }
        case let .failure(error):
          await self.perform(.failed(StateMachineError(underlyingError: error)))
        }
      }
    }
  }

  func makeDeviceTransferLoginFlowModel(login: Login?, deviceInfo: DeviceInfo)
    -> DeviceTransferLoginFlowModel
  {
    return deviceTransferLoginFlowModelFactory.make(login: login, deviceInfo: deviceInfo) {
      [weak self] result in
      guard let self = self else {
        return
      }
      Task {
        switch result {
        case let .success(successResult):
          switch successResult {
          case let .completed(loginSession, logInfo):
            await self.perform(.deviceTransferDidFinish(loginSession))
          case .dismiss:
            await self.perform(.cancel)
          case .logout:
            await self.perform(.logout)
          }
        case let .failure(error):
          await self.perform(.failed(StateMachineError(underlyingError: error)))
        }
      }
    }
  }

  internal func makeDeviceUnlinkLoadingViewModel(
    deviceUnlinker: DeviceUnlinker,
    session: RemoteLoginSession,
    logInfo: LoginFlowLogInfo
  ) -> DeviceUnlinkingFlowViewModel {
    deviceUnlinkingFactory.make(
      deviceUnlinker: deviceUnlinker,
      login: session.login,
      session: session,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      sessionActivityReporterProvider: sessionActivityReporterProvider
    ) { completion in
      Task {
        switch completion {
        case .logout:
          await self.perform(.logout)
        case let .load(_):
          await self.perform(.deviceUnlinkDidFinish(session))
        }
      }
    }
  }
}
