import Foundation
import CoreSession
import Combine
import DashTypes
import DashlaneCrypto
import CoreUserTracking
import SwiftTreats
import CoreSettings
import CoreLocalization
import DashlaneAPI

@MainActor
public final class MasterPasswordRemoteViewModel: LoginKitServicesInjecting, ObservableObject {
    let login: Login

    @Published
    var attempts: Int = 0

    @Published
    var password: String = "" {
        didSet {
            guard password != oldValue else { return }
            errorMessage = nil
            showWrongPasswordError = false
        }
    }

    @Published
    var errorMessage: String?

    @Published
    var inProgress: Bool = false

    @Published
    var isAccountRecoveryEnabled: Bool = false

    var shouldSuggestMPReset: Bool {
        return false
    }

    @Published
    var showWrongPasswordError: Bool = false

    @Published
    var showAccountRecoveryFlow = false

    @Published
    var showRecoveryProgress: Bool = false

    @Published
    var recoveryProgressState: ProgressionState = .inProgress("")

    let validator: RegularRemoteLoginHandler
    let loginMetricsReporter: LoginMetricsReporterProtocol
    let completion: () -> Void
    let logger: Logger
    let isExtension: Bool
    let remoteLoginInfoProvider: RemoteLoginDelegate
    let keys: LoginKeys
    let activityReporter: ActivityReporterProtocol

        private let verificationMode: Definition.VerificationMode
    private let isBackupCode: Bool
    private let appAPIClient: AppAPIClient
    private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory

    public init(
        login: Login,
        appAPIClient: AppAPIClient,
        verificationMode: Definition.VerificationMode,
        isBackupCode: Bool,
        isExtension: Bool,
        loginMetricsReporter: LoginMetricsReporterProtocol,
        activityReporter: ActivityReporterProtocol,
        validator: RegularRemoteLoginHandler,
        logger: Logger,
        remoteLoginDelegate: RemoteLoginDelegate,
        keys: LoginKeys,
        recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
        completion: @escaping () -> Void
    ) {
        self.login = login
        self.isExtension = isExtension
        self.verificationMode = verificationMode
        self.isBackupCode = isBackupCode
        self.loginMetricsReporter = loginMetricsReporter
        self.remoteLoginInfoProvider = remoteLoginDelegate
        self.validator = validator
        self.logger = logger
        self.keys = keys
        self.completion = completion
        self.activityReporter = activityReporter
        self.appAPIClient = appAPIClient
        self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
        Task {
           await fetchAccountRecoveryKeyStatus()
        }
    }

    func fetchAccountRecoveryKeyStatus() async {
        let response = try? await appAPIClient.accountrecovery.getStatus(login: login.email)
        isAccountRecoveryEnabled = response?.enabled ?? false
    }

    public func validate() {
        self.showWrongPasswordError = false
        inProgress = true
        loginMetricsReporter.startLoginTimer(from: .masterPassword)

        validateMasterPassword { result in
            switch result {
            case .success:
                self.errorMessage = nil
                self.completion()
            case .failure(let error):
                self.inProgress = false
                self.loginMetricsReporter.resetTimer(.login)
                self.attempts += 1
                switch error {
                case RemoteLoginHandler.Error.wrongMasterKey:
                    self.showWrongPasswordError = true
                    self.logLoginStatus(.errorWrongPassword)
                default:
                    self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
                    self.logLoginStatus(.errorUnknown)
                }
            }
        }
    }

    public func validateMasterPassword(completion: @escaping CompletionBlock<Void, Swift.Error>) {
        if let remoteKey = keys.remoteKey, let remoteKeyData = Data(base64Encoded: remoteKey.key) {
            let cryptoCenter = CryptoCenter(from: remoteKeyData)

            guard let decipheredRemoteKey = try? cryptoCenter?.decrypt(
                data: remoteKeyData,
                with: .password(password)
            ) else {
                completion(.failure(RemoteLoginHandler.Error.wrongMasterKey))
                return
            }
            validator.validateMasterKey(
                .masterPassword(password),
                authTicket: keys.authTicket,
                remoteKey: decipheredRemoteKey,
                using: remoteLoginInfoProvider,
                isRecoveryLogin: false,
                completion: completion
            )
        } else {
            validator.validateMasterKey(
                .masterPassword(password),
                authTicket: keys.authTicket,
                using: remoteLoginInfoProvider,
                isRecoveryLogin: false,
                completion: completion
            )
        }
    }

    public func logLoginStatus(_ status: Definition.Status) {
        let isBackupCode = isBackupCode
        let verificationMode = verificationMode
        
        activityReporter.report(
            UserEvent.Login(
                isBackupCode: isBackupCode,
                mode: .masterPassword,
                status: status,
                verificationMode: verificationMode
            )
        )
    }
    
    func onViewAppear() {
        activityReporter.reportPageShown(.unlockMp)
        
        #if DEBUG
        if !ProcessInfo.isTesting {
            guard password.isEmpty else { return }
            password = TestAccount.password
        }
        #endif
    }


    private func logOnAppear() {
        activityReporter.reportPageShown(.unlockMp)
    }

    func makeForgotMasterPasswordSheetModel() -> ForgotMasterPasswordSheetModel {
        ForgotMasterPasswordSheetModel(
            login: login.email,
            activityReporter: activityReporter,
            hasMasterPasswordReset: false,
            didTapAccountRecovery: { [weak self] in
                self?.showAccountRecoveryFlow = true
            }
        )
    }

    func makeAccountRecoveryFlowModel() -> AccountRecoveryKeyLoginFlowModel {
        return recoveryKeyLoginFlowModelFactory.make(
            login: login.email,
            accountType: .masterPassword,
            context: .remote(keys.authTicket),
            completion: { [weak self] result in
                guard let self = self else {
                    return
                }
                guard case let .completedWithChangeMP(masterKey, authTicket, newMasterPassword) = result else {
                    return
                }
                self.showRecoveryProgress = true
                self.validator.validateMasterKey(
                    masterKey,
                    authTicket: authTicket,
                    using: self.remoteLoginInfoProvider,
                    isRecoveryLogin: true,
                    newMasterPassword: newMasterPassword
                ) { [weak self] result in
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        self.completion()
                    case let .failure(error):
                        self.showAccountRecoveryFlow = false
                        self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
                        self.logLoginStatus(.errorUnknown)
                    }
                }
            }
        )
    }
}

extension MasterPasswordRemoteViewModel {
    static var mock: MasterPasswordRemoteViewModel {
        MasterPasswordRemoteViewModel(
            login: Login("_"),
            appAPIClient: .fake,
            verificationMode: .emailToken,
            isBackupCode: true,
            isExtension: false,
            loginMetricsReporter: .fake,
            activityReporter: FakeActivityReporter(),
            validator: .mock,
            logger: LoggerMock(),
            remoteLoginDelegate: .mock,
            keys: .init(remoteKey: nil, authTicket: AuthTicket(value: "authTicket")),
            recoveryKeyLoginFlowModelFactory: .init { _, _, _, _  in
                return .mock
            },
            completion: {}
        )
    }
}
