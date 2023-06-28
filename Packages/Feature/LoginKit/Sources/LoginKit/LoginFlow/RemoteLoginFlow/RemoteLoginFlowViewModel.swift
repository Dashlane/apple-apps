import Foundation
import CoreSession
import Combine

@MainActor
public class RemoteLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        case logout
        case migrateAccount(migrationInfos: AccountMigrationInfos,
                            validator: SSODeviceRegistrationValidator)
        case completed(RemoteLoginConfiguration)
        case deviceUnlinking(remoteLoginSession: RemoteLoginSession,
                             logInfo: LoginFlowLogInfo,
                             remoteLoginHandler: RemoteLoginHandler,
                             loadActionPublisher: PassthroughSubject<DeviceUnlinkLoadingAction, Never>)
    }

    enum Step {
        case remoteLogin(LoginFlowViewModel.RemoteLoginType)
        case deviceUnlinking(DeviceUnlinker, RemoteLoginSession, LoginFlowLogInfo, RemoteLoginHandler)
    }

    @Published
    var steps: [Step]

    let type: LoginFlowViewModel.RemoteLoginType
    let loginMetricsReporter: LoginMetricsReporterProtocol
    let purchasePlanFlowProvider: PurchasePlanFlowProvider
    let sessionActivityReporterProvider: SessionActivityReporterProvider
    let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
    let remoteLoginViewModelFactory: RegularRemoteLoginFlowViewModel.Factory
    let tokenPublisher: AnyPublisher<String, Never>
    let completion: @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
    let deviceToDeviceLoginFlowViewModelFactory: DeviceToDeviceLoginFlowViewModel.Factory

    public init(type: LoginFlowViewModel.RemoteLoginType,
                loginMetricsReporter: LoginMetricsReporterProtocol,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                remoteLoginInfoProvider: RemoteLoginDelegate,
                purchasePlanFlowProvider: PurchasePlanFlowProvider,
                remoteLoginViewModelFactory: RegularRemoteLoginFlowViewModel.Factory,
                sessionActivityReporterProvider: SessionActivityReporterProvider,
                deviceToDeviceLoginFlowViewModelFactory: DeviceToDeviceLoginFlowViewModel.Factory,
                tokenPublisher: AnyPublisher<String, Never>,
                deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
                completion: @escaping @MainActor (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void) {
        self.type = type
        self.purchasePlanFlowProvider = purchasePlanFlowProvider
        self.sessionActivityReporterProvider = sessionActivityReporterProvider
        self.completion = completion
        self.tokenPublisher = tokenPublisher
        self.loginMetricsReporter = loginMetricsReporter
        self.deviceUnlinkingFactory = deviceUnlinkingFactory
        self.remoteLoginViewModelFactory = remoteLoginViewModelFactory
        self.deviceToDeviceLoginFlowViewModelFactory = deviceToDeviceLoginFlowViewModelFactory
        self.steps = [.remoteLogin(type)]
    }

    func makeClassicRemoteLoginFlowViewModel(using loginHandler: RegularRemoteLoginHandler) -> RegularRemoteLoginFlowViewModel {
        remoteLoginViewModelFactory.make(remoteLoginHandler: loginHandler, email: loginHandler.login.email, sessionActivityReporterProvider: sessionActivityReporterProvider, tokenPublisher: tokenPublisher) { result in
            switch result {
            case let .success(type):
                switch type {
                case let .completed(config):
                    self.completion(.success(.completed(config)))
                case let .deviceUnlinking(unlinker, session, logInfo, remoteLoginHandler):
                    self.steps.append(.deviceUnlinking(unlinker, session, logInfo, remoteLoginHandler))
                case let .migrateAccount(migrationInfos, validator):
                    self.completion(.success(.migrateAccount(migrationInfos: migrationInfos, validator: validator)))
                }
            case let .failure(error):
                self.completion(.failure(error))
            }
        }
    }

    func makeDeviceToDeviceLoginFlowViewModel(using loginHandler: DeviceToDeviceLoginHandler) -> DeviceToDeviceLoginFlowViewModel {
        deviceToDeviceLoginFlowViewModelFactory.make(loginHandler: loginHandler,
                                                     sessionActivityReporterProvider: sessionActivityReporterProvider) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case let .success(type):
                switch type {
                case .logout:
                    self.completion(.success(.logout))
                case let .completed(config):
                    self.completion(.success(.completed(config)))
                case let .deviceUnlinking(unlinker, session, logInfo, remoteLoginHandler):
                    self.steps.append(.deviceUnlinking(unlinker, session, logInfo, remoteLoginHandler))
                case let .migrateAccount(migrationInfos, validator):
                    self.completion(.success(.migrateAccount(migrationInfos: migrationInfos, validator: validator)))
                }
            case let .failure(error):
                self.completion(.failure(error))
            }
        }
    }

    internal func makeDeviceUnlinkLoadingViewModel(deviceUnlinker: DeviceUnlinker,
                                                   session: RemoteLoginSession,
                                                   logInfo: LoginFlowLogInfo,
                                                   remoteLoginHandler: RemoteLoginHandler) -> DeviceUnlinkingFlowViewModel {
        deviceUnlinkingFactory.make(deviceUnlinker: deviceUnlinker,
                                    login: session.login,
                                    session: session,
                                    purchasePlanFlowProvider: purchasePlanFlowProvider,
                                    sessionActivityReporterProvider: sessionActivityReporterProvider) { completion in
            switch completion {
            case .logout:
                self.completion(.success(.logout))
            case let .load(loadActionPublisher):
                self.completion(.success(.deviceUnlinking(remoteLoginSession: session,
                                                          logInfo: logInfo,
                                                 remoteLoginHandler: remoteLoginHandler,
                                                          loadActionPublisher: loadActionPublisher)))
            }
        }
    }
}

public struct RemoteLoginConfiguration {
    public let session: Session
    public let logInfo: LoginFlowLogInfo
    public let pinCode: String?
    public let isRecoveryLogin: Bool
    public let shouldEnableBiometry: Bool
    public let newMasterPassword: String?
    init(session: Session, logInfo: LoginFlowLogInfo, pinCode: String? = nil, isRecoveryLogin: Bool = false, shouldEnableBiometry: Bool = false, newMasterPassword: String? = nil) {
        self.session = session
        self.logInfo = logInfo
        self.pinCode = pinCode
        self.isRecoveryLogin = isRecoveryLogin
        self.shouldEnableBiometry = shouldEnableBiometry
        self.newMasterPassword = newMasterPassword
    }
}
