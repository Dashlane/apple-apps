import Combine
import CoreSession
import DashTypes
import Foundation

@MainActor
public class RemoteLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

  public enum Completion {
    case dismiss
    case logout
    case migrateAccount(migrationInfos: AccountMigrationInfos)
    case completed(RemoteLoginConfiguration, LoginFlowLogInfo)
    case deviceUnlinking(
      remoteLoginSession: RemoteLoginSession,
      logInfo: LoginFlowLogInfo,
      remoteLoginHandler: RemoteLoginHandler,
      loadActionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>)
  }

  enum Step {
    case remoteLogin(LoginFlowViewModel.RemoteLoginType)
    case deviceUnlinking(DeviceUnlinker, RemoteLoginSession, LoginFlowLogInfo, RemoteLoginHandler)
  }

  @Published
  var step: Step

  let type: LoginFlowViewModel.RemoteLoginType
  let loginMetricsReporter: LoginMetricsReporterProtocol
  let purchasePlanFlowProvider: PurchasePlanFlowProvider
  let sessionActivityReporterProvider: SessionActivityReporterProvider
  let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
  let remoteLoginViewModelFactory: RegularRemoteLoginFlowViewModel.Factory
  let tokenPublisher: AnyPublisher<String, Never>
  let completion: @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  let deviceToDeviceLoginFlowViewModelFactory: DeviceTransferQRCodeFlowModel.Factory
  let deviceTransferLoginFlowModelFactory: DeviceTransferLoginFlowModel.Factory
  let remoteLoginHandler: RemoteLoginHandler

  public init(
    type: LoginFlowViewModel.RemoteLoginType,
    remoteLoginHandler: RemoteLoginHandler,
    loginMetricsReporter: LoginMetricsReporterProtocol,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    remoteLoginViewModelFactory: RegularRemoteLoginFlowViewModel.Factory,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    deviceToDeviceLoginFlowViewModelFactory: DeviceTransferQRCodeFlowModel.Factory,
    deviceTransferLoginFlowModelFactory: DeviceTransferLoginFlowModel.Factory,
    tokenPublisher: AnyPublisher<String, Never>,
    deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
    completion: @escaping @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  ) {
    self.type = type
    self.remoteLoginHandler = remoteLoginHandler
    self.purchasePlanFlowProvider = purchasePlanFlowProvider
    self.sessionActivityReporterProvider = sessionActivityReporterProvider
    self.completion = completion
    self.tokenPublisher = tokenPublisher
    self.loginMetricsReporter = loginMetricsReporter
    self.deviceUnlinkingFactory = deviceUnlinkingFactory
    self.remoteLoginViewModelFactory = remoteLoginViewModelFactory
    self.deviceToDeviceLoginFlowViewModelFactory = deviceToDeviceLoginFlowViewModelFactory
    self.deviceTransferLoginFlowModelFactory = deviceTransferLoginFlowModelFactory
    self.step = .remoteLogin(type)
  }

  func makeClassicRemoteLoginFlowViewModel(using loginHandler: RegularRemoteLoginHandler)
    -> RegularRemoteLoginFlowViewModel
  {
    return remoteLoginViewModelFactory.make(
      remoteLoginHandler: loginHandler, email: loginHandler.login.email,
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      tokenPublisher: tokenPublisher
    ) { [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .success(successResult):
        switch successResult {
        case let .completed(loginSession, logInfo):
          self.handleRemoteLoginResult(with: loginSession, logInfo: logInfo)
        case .cancel:
          self.completion(.success(.dismiss))
        }
      case let .failure(error):
        self.completion(.failure(error))
      }
    }
  }

  func makeDeviceTransferLoginFlowModel(
    using loginHandler: DeviceTransferLoginFlowStateMachine, login: Login?
  ) -> DeviceTransferLoginFlowModel {
    return deviceTransferLoginFlowModelFactory.make(login: login, stateMachine: loginHandler) {
      [weak self] result in
      guard let self = self else {
        return
      }
      switch result {
      case let .success(type):
        switch type {
        case .dismiss:
          self.completion(.success(.dismiss))
        case .logout:
          self.completion(.success(.logout))
        case let .completed(loginSession, logInfo):
          self.handleRemoteLoginResult(with: loginSession, logInfo: logInfo)
        }
      case let .failure(error):
        self.completion(.failure(error))
      }
    }
  }

  func handleRemoteLoginResult(with loginSession: RemoteLoginSession, logInfo: LoginFlowLogInfo) {
    Task {
      let loadResult: RemoteLoginHandler.CompletionType = try await self.remoteLoginHandler
        .loadAccount(with: loginSession)
      switch loadResult {
      case let .completed(config):
        self.completion(.success(.completed(config, logInfo)))
      case let .deviceUnlinking(unlinker, session):
        self.step = .deviceUnlinking(
          unlinker, session, LoginFlowLogInfo(loginMode: .deviceTransfer), self.remoteLoginHandler)
      case let .migrateAccount(info):
        self.completion(.success(.migrateAccount(migrationInfos: info)))
      }
    }
  }

  internal func makeDeviceUnlinkLoadingViewModel(
    deviceUnlinker: DeviceUnlinker,
    session: RemoteLoginSession,
    logInfo: LoginFlowLogInfo,
    remoteLoginHandler: RemoteLoginHandler
  ) -> DeviceUnlinkingFlowViewModel {
    deviceUnlinkingFactory.make(
      deviceUnlinker: deviceUnlinker,
      login: session.login,
      session: session,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      sessionActivityReporterProvider: sessionActivityReporterProvider
    ) { completion in
      switch completion {
      case .logout:
        self.completion(.success(.logout))
      case let .load(loadActionPublisher):
        self.completion(
          .success(
            .deviceUnlinking(
              remoteLoginSession: session,
              logInfo: logInfo,
              remoteLoginHandler: remoteLoginHandler,
              loadActionPublisher: loadActionPublisher)))
      }
    }
  }
}
