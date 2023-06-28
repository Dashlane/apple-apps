import Foundation
import CoreSession
import Combine
import DashTypes
import CoreKeychain
import CoreUserTracking
import SwiftTreats
import CoreSettings
import CoreLocalization
import DashlaneAPI

@MainActor
public final class MasterPasswordLocalViewModel: ObservableObject, LoginKitServicesInjecting {

    public enum CompletionMode: Equatable {
                case authenticated
                case masterPasswordReset

        case biometry(Biometry)
        case accountRecovered(_ newMasterPassword: String)
    }

        @Published var attempts: Int = 0
    @Published var password: String = "" {
        didSet {
            guard password != oldValue else { return }
            errorMessage = nil
            showWrongPasswordError = false
        }
    }
    @Published var errorMessage: String?
    @Published var inProgress: Bool = false
    @Published var shouldDisplayError: Bool = false
    @Published var showWrongPasswordError: Bool = false
    @Published var showAccountRecoveryFlow = false
    @Published var hasAccountRecoveryKey = false

        let login: Login
    let completion: (CompletionMode?) -> Void
    var isExtension: Bool {
        context.localLoginContext.isExtension
    }

        let shouldSuggestMPReset: Bool
    let biometry: Biometry?
    let activityReporter: ActivityReporterProtocol

    let context: LoginUnlockContext

    private let unlocker: UnlockSessionHandler
    private let authTicket: AuthTicket?
    private let appAPIClient: AppAPIClient
    private let deviceInfo: DeviceInfo
    private let userSettings: UserSettings
    private let loginMetricsReporter: LoginMetricsReporterProtocol
    private let pinCodeAttempts: PinCodeAttempts
    private let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory

        public init(
        login: Login,
        biometry: Biometry?,
        authTicket: AuthTicket?,
        unlocker: UnlockSessionHandler,
        context: LoginUnlockContext,
        resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
        loginMetricsReporter: LoginMetricsReporterProtocol,
        activityReporter: ActivityReporterProtocol,
        appAPIClient: AppAPIClient,
        userSettings: UserSettings,
        recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
        completion: @escaping (MasterPasswordLocalViewModel.CompletionMode?) -> Void
    ) {
        self.login = login
        self.context = context
        self.loginMetricsReporter = loginMetricsReporter
        self.unlocker = unlocker
        self.userSettings = userSettings
        self.pinCodeAttempts = .init(internalStore: userSettings.internalStore)
        self.completion = completion
        self.resetMasterPasswordService = resetMasterPasswordService
        self.biometry = biometry
        shouldSuggestMPReset = context.localLoginContext.isPasswordApp ? resetMasterPasswordService.isActive : false
        self.activityReporter = activityReporter
        self.appAPIClient = appAPIClient
        self.authTicket = authTicket
        self.deviceInfo = DeviceInfo.default
        self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
        if context.localLoginContext.isPasswordApp {
            fetchAccountRecoveryKeyStatus()
        }
    }

        func fetchAccountRecoveryKeyStatus() {
        Task {
            let response = try? await appAPIClient.accountrecovery.getStatus(login: login.email)
            hasAccountRecoveryKey = response?.enabled ?? false
        }
    }

    func logout() {
        completion(nil)
    }

    func validate() async {
        self.showWrongPasswordError = false
        await validate(masterPassword: password, mode: .authenticated)
    }

    private func validate(masterPassword password: String, mode: CompletionMode) async {
        inProgress = true
        loginMetricsReporter.startLoginTimer(from: .masterPassword)

        do {
            try await unlocker.validateMasterKey(.masterPassword(password), isRecoveryLogin: false)
            self.errorMessage = nil
            self.pinCodeAttempts.removeAll()
            self.completion(mode)
        } catch {
            self.loginMetricsReporter.resetTimer(.login)
            self.inProgress = false
            self.attempts += 1
            switch error {
            case LocalLoginHandler.Error.wrongMasterKey:
                self.showWrongPasswordError = true
                self.activityReporter.logLoginStatus(.errorWrongPassword, context: context)
            default:
                self.errorMessage = L10n.errorMessage(for: error)
                self.activityReporter.logLoginStatus(.errorUnknown, context: context)
            }
        }
    }

    func showBiometryView() {
        guard let biometry = biometry else {
            return
        }
        completion(.biometry(biometry))
    }
    
    func onViewAppear() {
        logOnAppear()
        #if DEBUG
        if !ProcessInfo.isTesting {
            guard password.isEmpty else { return }
            password = TestAccount.password
        }
        #endif
    }


    func logOnAppear() {
        activityReporter.logOnAppear(for: context)
    }

    func makeForgotMasterPasswordSheetModel() -> ForgotMasterPasswordSheetModel {
        ForgotMasterPasswordSheetModel(
            login: login.email,
            activityReporter: activityReporter,
            hasMasterPasswordReset: shouldSuggestMPReset,
            didTapResetMP: { [weak self] in
                self?.didTapResetMP()
            },
            didTapAccountRecovery: {
                self.showAccountRecoveryFlow = true
            }
        )
    }

    func makeAccountRecoveryFlowModel() -> AccountRecoveryKeyLoginFlowModel {
        recoveryKeyLoginFlowModelFactory.make(
            login: login.email,
            accountType: .masterPassword,
            context: .local(authTicket, deviceInfo),
            completion: { [weak self] result in
                guard let self = self else {
                    return
                }
                switch result {
                case .cancel:
                    self.showAccountRecoveryFlow = false
                case let .completedWithChangeMP(masterKey, _, newMasterPassword):
                    Task {
                        do {
                            try await self.unlocker.validateMasterKey(masterKey, isRecoveryLogin: true)
                            self.completion(.accountRecovered(newMasterPassword))
                        } catch {
                            self.showAccountRecoveryFlow = false
                            self.errorMessage = CoreLocalization.L10n.errorMessage(for: error)
                        }
                    }
                default:
                    self.showAccountRecoveryFlow = false
                }
            }
        )
    }
}

fileprivate extension ActivityReporterProtocol {
    func logLoginStatus(_ status: Definition.Status, context: LoginUnlockContext) {
        report(
            UserEvent.Login(
                isBackupCode: context.isBackupCode,
                mode: .masterPassword,
                status: status,
                verificationMode: context.verificationMode
            )
        )
    }

    func logOnAppear(for context: LoginUnlockContext) {
        if context.verificationMode == .none {
            report(
                UserEvent.AskAuthentication(
                    mode: .masterPassword,
                    reason: context.reason,
                    verificationMode: context.verificationMode
                )
            )
        }
        reportPageShown(.unlockMp)
    }

    func logForgotPassword(shouldSuggestMPReset: Bool) {
        let shouldSuggestMPReset = shouldSuggestMPReset
        report(
            UserEvent.ForgetMasterPassword(
                hasBiometricReset: shouldSuggestMPReset,
                hasTeamAccountRecovery: false
            )
        )
    }
}

@MainActor
extension MasterPasswordLocalViewModel {

    public func didTapResetMP() {
        activityReporter.logForgotPassword(shouldSuggestMPReset: shouldSuggestMPReset)
        self.inProgress = true
        Task.delayed(by: 0.5) { @MainActor in
            do {
                let masterPassword = try self.resetMasterPasswordService.storedMasterPassword()
                await self.validate(masterPassword: masterPassword, mode: .masterPasswordReset)
            } catch {
                self.errorMessage = L10n.errorMessage(for: error)
            }
            self.inProgress = false
        }
    }
}

public extension AppAPIClient.Authentication.Get2FAStatusUnauthenticated.Response {
    var pushType: PushType? {
        if isDuoEnabled {
            return .duo
        } else if hasDashlaneAuthenticator {
            return .authenticator
        }
        return nil
    }

    var verificationMethod: VerificationMethod? {
        switch self.type {
        case .emailToken:
            return .emailToken
        case .totpDeviceRegistration:
            return .totp(pushType)
        case .totpLogin:
            return .totp(pushType)
        case .sso:
            return nil
        }
    }
}

public extension MasterPasswordLocalViewModel {
    static var mock: MasterPasswordLocalViewModel {
        MasterPasswordLocalViewModel(
            login: Login("_"),
            biometry: nil,
            authTicket: nil,
            unlocker: .mock,
            context: LoginUnlockContext(
                verificationMode: .emailToken,
                isBackupCode: nil,
                origin: .login,
                localLoginContext: .passwordApp
            ),
            resetMasterPasswordService: ResetMasterPasswordService.mock,
            loginMetricsReporter: .fake,
            activityReporter: FakeActivityReporter(),
            appAPIClient: .fake,
            userSettings: .mock,
            recoveryKeyLoginFlowModelFactory: .init({ _, _, _, _ in .mock }),
            completion: { _ in}
        )
    }
}
