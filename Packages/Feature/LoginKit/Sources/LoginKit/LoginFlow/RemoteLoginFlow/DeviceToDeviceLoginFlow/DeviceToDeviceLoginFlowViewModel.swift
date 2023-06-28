import Foundation
import CoreCrypto
import DashlaneAPI
import CoreSession
import DashTypes
import Combine
import CoreUserTracking
import CoreNetworking
import CoreLocalization
import CoreKeychain
import SwiftTreats

@MainActor
public class DeviceToDeviceLoginFlowViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum Completion {
        case logout
        case completed(RemoteLoginConfiguration)
        case deviceUnlinking(DeviceUnlinker, RemoteLoginSession, logInfo: LoginFlowLogInfo, RemoteLoginHandler)
        case migrateAccount(migrationInfos: AccountMigrationInfos,
                            validator: SSODeviceRegistrationValidator)
    }

    @Published
    var steps: [Step] = []

    var pinCode: String?
    let appAPIClient: AppAPIClient
    let loginHandler: DeviceToDeviceLoginHandler
    let completion: @MainActor (Result<Completion, Error>) -> Void
    let sessionCryptoEngineProvider: SessionCryptoEngineProvider
    let remoteLoginInfoProvider: RemoteLoginDelegate
    let deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory
    let sessionActivityReporterProvider: SessionActivityReporterProvider
    let totpFactory: DeviceToDeviceOTPLoginViewModel.Factory
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let sessionCleaner: SessionCleaner
    let deviceToDeviceLoginQrCodeViewModelFactory: DeviceToDeviceLoginQrCodeViewModel.Factory
    let keychainService: AuthenticationKeychainServiceProtocol

        var verificationMode: Definition.VerificationMode = .none
        var isBackupCode: Bool = false

    @Published
    var isInProgress = false

    private var isRecoveryInProgress = false

    enum Step {
        case secretTransfer
        case verifyLogin(DevciceToDeviceTransferData)
        case otp(ThirdPartyOTPDeviceRegistrationValidator)
        case pinSetup(DeviceRegisterData)
        case biometry(Biometry, DeviceRegisterData)
    }

    @Published
    var showError = false

    @Published
    var progressState: ProgressionState = .inProgress(L10n.Core.deviceToDeviceLoginProgress)

    var dismissPublisher = PassthroughSubject<Void, Never>()

    var logInfo: LoginFlowLogInfo {
        .init(loginMode: .masterPassword,
              verificationMode: verificationMode,
              isBackupCode: isBackupCode)
    }

    var shouldEnableBiometry: Bool = false
    public init(appAPIClient: AppAPIClient,
                loginHandler: DeviceToDeviceLoginHandler,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                remoteLoginInfoProvider: RemoteLoginDelegate,
                keychainService: AuthenticationKeychainServiceProtocol,
                deviceUnlinkingFactory: DeviceUnlinkingFlowViewModel.Factory,
                sessionActivityReporterProvider: SessionActivityReporterProvider,
                totpFactory: DeviceToDeviceOTPLoginViewModel.Factory,
                deviceToDeviceLoginQrCodeViewModelFactory: DeviceToDeviceLoginQrCodeViewModel.Factory,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                sessionCleaner: SessionCleaner,
                completion: @escaping @MainActor (Result<DeviceToDeviceLoginFlowViewModel.Completion, Error>) -> Void) {
        self.appAPIClient = appAPIClient
        self.loginHandler = loginHandler
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        self.remoteLoginInfoProvider = remoteLoginInfoProvider
        self.completion = completion
        self.deviceUnlinkingFactory = deviceUnlinkingFactory
        self.sessionActivityReporterProvider = sessionActivityReporterProvider
        self.totpFactory = totpFactory
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.sessionCleaner = sessionCleaner
        self.deviceToDeviceLoginQrCodeViewModelFactory = deviceToDeviceLoginQrCodeViewModelFactory
        self.keychainService = keychainService
        updateStep()
    }

    internal func updateStep() {
        switch loginHandler.step {
        case .startTransfer:
            steps.append(.secretTransfer)
        case let .verifyLogin(loginData):
            steps.append(.verifyLogin(loginData))
        case let .pin(loginData, authTicket):
            guard let masterKey = loginData.key.masterKey else {
                self.showError = true
                return
            }
            steps.append(.pinSetup(DeviceRegisterData(login: Login(loginData.login), accountType: loginData.key.accountType, sessionKey: masterKey, authTicket: authTicket, isRecoveryLogin: false)))
        case let .validateMasterKeyAndRegister(registerData, loginData, ssoKeys):
            guard let masterKey = loginData.key.masterKey else {
                self.showError = true
                return
            }

            loginHandler.validateMasterKey(masterKey, authTicket: registerData.authTicket, remoteKey: ssoKeys?.remoteKey, using: remoteLoginInfoProvider, isRecoveryLogin: isRecoveryInProgress) { response in
                DispatchQueue.main.async {
                    guard (try? response.get()) != nil else {
                        self.showError = true
                        return
                    }
                    self.updateStep()
                }
            }
        case let .thirdPartyOTP(validator):
            steps.append(.otp(validator))
        case let .deviceUnlinking(deviceUnlinker, session):
            self.completion(.success(.deviceUnlinking(deviceUnlinker, session, logInfo: self.logInfo, loginHandler.remoteLoginHandler)))
        case let .migrateAccount(migrationInfos, validator):
            completion(.success(.migrateAccount(migrationInfos: migrationInfos, validator: validator)))
        case let .completed(session, isRecoveryLogin, newMasterPassword):
            progressState = .completed(isRecoveryInProgress ? L10n.Core.recoveryKeyLoginSuccessMessage : L10n.Core.deviceToDeviceLoginCompleted, {
                self.dismissPublisher.send()
                let config = RemoteLoginConfiguration(session: session, logInfo: self.logInfo, pinCode: self.pinCode, isRecoveryLogin: isRecoveryLogin, shouldEnableBiometry: self.shouldEnableBiometry, newMasterPassword: newMasterPassword)
                self.completion(.success(.completed(config)))
            })
        }
    }

    func makeDeviceToDeviceLoginQrCodeViewModel() -> DeviceToDeviceLoginQrCodeViewModel {
        return deviceToDeviceLoginQrCodeViewModelFactory.make(loginHandler: loginHandler) { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .qrFinished:
                self.updateStep()
            case let .recoveryFinished(deviceRegisterData):
                self.isRecoveryInProgress = true
                switch deviceRegisterData.accountType {
                case .invisibleMasterPassword:
                    self.steps.append(.pinSetup(deviceRegisterData))
                default:
                    self.progressState = .inProgress(L10n.Core.recoveryKeyLoginProgressMessage)
                    isInProgress = true
                    Task {
                        try? await self.loginHandler.registerDevice(
                            with: DevciceToDeviceTransferData(
                                key: deviceRegisterData.sessionKey.transferKey(
                                    accountType: deviceRegisterData.accountType
                                ),
                                token: nil,
                                login: deviceRegisterData.login.email,
                                version: 1), authTicket
                            : deviceRegisterData.authTicket
                        )
                        self.updateStep()
                    }
                }
            case .cancel:
                self.completion(.success(.logout))
            }
        }
    }

    func makeDeviceToDeviceVerifyLoginViewModel(loginData: DevciceToDeviceTransferData) -> DeviceToDeviceVerifyLoginViewModel {
        return DeviceToDeviceVerifyLoginViewModel(loginData: loginData, sessionCleaner: sessionCleaner, loginHandler: loginHandler) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .confirm:
               self.updateStep()
            case .cancel:
                self.completion(.success(.logout))
            }
        }
    }

    func makeDeviceToDeviceOTPLoginViewModel(
        validator: ThirdPartyOTPDeviceRegistrationValidator
    ) -> DeviceToDeviceOTPLoginViewModel {
        totpFactory.make(
            validator: validator,
            recover2faWebService: Recover2FAWebService(
                webService: nonAuthenticatedUKIBasedWebService,
                login: validator.login
            )
        ) { [weak self] completionType in
            guard let self = self else { return }
            switch completionType {
            case let .success(isBackupCode):
                self.verificationMode = .otp1
                self.isBackupCode = isBackupCode
                self.updateStep()
            case .error:
                self.showError = true
            case .cancel:
                self.completion(.success(.logout))
            }
        }
    }

    func makePinCodeSetupViewModel(registerData: DeviceRegisterData) -> PinCodeSetupViewModel {
        PinCodeSetupViewModel(login: registerData.login) { [weak self] pin in
            guard let self = self else {
                return
            }
            self.pinCode = pin
            if let biometry = Device.biometryType {
                self.steps.append(.biometry(biometry, registerData))
            } else {
                self.registerDevice(with: registerData)
            }
        }
    }

    func enableBiometry(with registerData: DeviceRegisterData) {
        shouldEnableBiometry = true
        registerDevice(with: registerData)
    }

    func skipBiometry(with registerData: DeviceRegisterData) {
        shouldEnableBiometry = false
        registerDevice(with: registerData)
    }

    func registerDevice(with registerData: DeviceRegisterData) {
        self.progressState = .inProgress(L10n.Core.deviceToDeviceLoginProgress)
        self.isInProgress = true
        Task {
            try? await self.loginHandler.registerDevice(with: DevciceToDeviceTransferData(key: registerData.sessionKey.transferKey(accountType: registerData.accountType), token: nil, login: registerData.login.email, version: 1), authTicket: registerData.authTicket)
            self.updateStep()
        }
    }
}

enum TransferError: Error {
    case couldNotDecrypt
}

extension DeviceToDeviceLoginFlowViewModel {
    static var mock: DeviceToDeviceLoginFlowViewModel {
        DeviceToDeviceLoginFlowViewModel(
            appAPIClient: .fake,
            loginHandler: .mock,
            sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
            remoteLoginInfoProvider: .mock,
            keychainService: FakeAuthenticationKeychainService.mock,
            deviceUnlinkingFactory: InjectedFactory { deviceUnlinker, login, _, purchasePlanFlowProvider, _, completion in
                DeviceUnlinkingFlowViewModel(
                    deviceUnlinker: deviceUnlinker,
                    login: login,
                    authentication: ServerAuthentication(deviceAccessKey: "", deviceSecretKey: ""),
                    logger: LoggerMock(),
                    purchasePlanFlowProvider: purchasePlanFlowProvider,
                    userTrackingSessionActivityReporter: FakeActivityReporter(),
                    completion: completion
                )
            },
            sessionActivityReporterProvider: FakeSessionActivityReporter(),
            totpFactory: InjectedFactory { validator, recover2faWebService, completion in
                DeviceToDeviceOTPLoginViewModel(
                    validator: validator,
                    activityReporter: FakeActivityReporter(),
                    recover2faWebService: recover2faWebService,
                    completion: completion
                )
            },
            deviceToDeviceLoginQrCodeViewModelFactory: .init { loginHandler, completion in
                DeviceToDeviceLoginQrCodeViewModel(
                    loginHandler: loginHandler,
                    apiClient: .fake,
                    sessionCryptoEngineProvider: SessionCryptoEngineProvider(logger: LoggerMock()),
                    accountRecoveryKeyLoginFlowModelFactory: .init { _, _, _, _  in
                        return .mock
                    },
                    completion: completion
                )
            },
            nonAuthenticatedUKIBasedWebService: LegacyWebServiceMock(response: ""),
            sessionCleaner: .mock,
            completion: { _ in }
        )
    }
}

public struct DeviceRegisterData {
    let login: Login
    let accountType: AccountType
    let sessionKey: CoreSession.MasterKey
    let authTicket: AuthTicket?
    let isRecoveryLogin: Bool
}
