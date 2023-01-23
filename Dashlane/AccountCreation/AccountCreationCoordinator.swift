import Foundation
import DashTypes
import CoreSession
import SwiftUI
import CorePersonalData
import DashlaneCrypto
import CoreNetworking
import Combine
import SafariServices
import CoreUserTracking
import SwiftTreats
import Logger
import DashlaneAppKit
import LoginKit
import CoreLocalization
import Adjust
import AdSupport
import AppTrackingTransparency

class AccountCreationCoordinator: NSObject, Coordinator, SubcoordinatorOwner {
    var subcoordinator: Coordinator?

    enum Step: Equatable {
        case createEmail
        case createMasterPassword
        case fastLocalSetup 
        case userConsent
        case createAccount
    }

    enum CompletionResult {
        case finished(SessionServicesContainer)
        case cancel
        case login(Login)
    }

    let navigator: Navigator

    private let accountCreationHandler: AccountCreationHandler
    private let completion: (CompletionResult) -> Void
    private let isEmailMarketingOptInRequired: Bool
    private let creationLogger: Logger
    private let appServices: AppServicesContainer
    private let logger: Logger
    private var currentStep: Step?
    private var sessionServicesSubscription: AnyCancellable?
    private var email: DashTypes.Email?
    private var masterPassword: String?
    private var hasUserAcceptedTermsAndConditions: Bool?
    private var hasUserAcceptedEmailMarketing: Bool?
    private var isAccountCreationInProgress: Bool = false
    private var isBiometricAuthenticationEnabled: Bool?
    private var isMasterPasswordResetEnabled: Bool?
    private var isRememberMasterPasswordEnabled: Bool?

    init(navigator: Navigator,
         isEmailMarketingOptInRequired: Bool,
         logger: Logger,
         accountCreationHandler: AccountCreationHandler,
         appServices: AppServicesContainer,
         completion: @escaping (CompletionResult) -> Void) {
        self.navigator = navigator
        self.logger = logger
        self.accountCreationHandler = accountCreationHandler
        self.completion = completion
        self.isEmailMarketingOptInRequired = isEmailMarketingOptInRequired
        self.creationLogger = appServices.rootLogger[.accountCreation]
        self.appServices = appServices
    }

    func start() {
        move(to: .createEmail)
    }

        private func move(to step: Step) {
        switch step {
        case .createEmail:
            navigator.push(makeAccountEmailView())
        case .createMasterPassword:
            navigator.push(makeNewMasterPasswordView(masterPassword: masterPassword))
        case .fastLocalSetup:
            if let biometry = Device.biometryType {
                navigator.push(makeFastLocalSetupView(biometry: biometry))
            } else if Device.isMac {
                navigator.push(makeFastLocalSetupView(biometry: nil))
            } else {
                                appServices.installerLogService.accountCreation.log(.fastLocalSetup(action: .biometricAuthenticationCannotBeShown))
                move(to: .userConsent)
            }
        case .userConsent:
            guard let email = self.email, let masterPassword = masterPassword else {
                return
            }
            navigator.push(makeUserConsentView(email: email, masterPassword: masterPassword, isEmailMarketingOptInRequired: isEmailMarketingOptInRequired))
        case .createAccount:
            guard let email = self.email, let password = self.masterPassword, let hasUserAcceptedEmailMarketing = self.hasUserAcceptedEmailMarketing else {
                assertionFailure("All values should be present at this stage")
                return
            }

            createAccount(with: email, password: password, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing)
        }
    }

        func makeAccountEmailView() -> AccountEmailView<EmailViewModel> {
        let model = EmailViewModel(accountCreationHandler: accountCreationHandler, logger: appServices.installerLogService.accountCreation, activityReporter: appServices.activityReporter) { [weak self] result in
            self?.handle(result)
        }
        return AccountEmailView(model: model)
    }

    func makeNewMasterPasswordView(masterPassword: String?) -> NewMasterPasswordView {
        let model = NewMasterPasswordViewModel(mode: .accountCreation,
                                               masterPassword: masterPassword,
                                               evaluator: appServices.passwordEvaluator,
                                               logger: appServices.installerLogService.accountCreation,
                                               keychainService: appServices.keychainService,
                                               activityReporter: appServices.activityReporter) { [weak self] result in
            self?.handle(result)
        }
        return NewMasterPasswordView(model: model, title: L10n.Localizable.kwTitle)
    }

    func makeFastLocalSetupView(biometry: Biometry?) -> FastLocalSetupView<FastLocalSetupInAccountCreationViewModel> {
        let model = FastLocalSetupInAccountCreationViewModel(biometry: biometry, logger: appServices.installerLogService.accountCreation) { [weak self] result in
            self?.handle(result)
        }
        return FastLocalSetupView(model: model)
    }

    func makeUserConsentView(email: DashTypes.Email, masterPassword: String, isEmailMarketingOptInRequired: Bool) -> UserConsentView {
        let model = UserConsentViewModel(email: email,
                                         masterPassword: masterPassword,
                                         loginUsageLogService: appServices.loginUsageLogService,
                                         isEmailMarketingOptInRequired: isEmailMarketingOptInRequired,
                                         logger: appServices.installerLogService.accountCreation) { [weak self] result in
                                            self?.handle(result)
        }
        return UserConsentView(model: model)
    }

            private func handle(_ result: EmailViewModel.CompletionResult) {
        switch result {
        case .next(let email):
            self.email = email
            self.move(to: .createMasterPassword)
        case .login(let login):
            self.completion(.login(login))
        case let .sso(email, info):
            self.email = email
            startSSOAccountCreation(with: info)
        case .cancel:
            self.completion(.cancel)
        }
    }

        private func handle(_ result: NewMasterPasswordViewModel.Completion) {
        switch result {
        case let .next(masterPassword: masterPassword):
            self.masterPassword = masterPassword
            move(to: .fastLocalSetup)
        case let .back(masterPassword: masterPassword):
            self.masterPassword = masterPassword
            self.navigator.pop(animated: true)
        }
    }

        private func handle(_ result: FastLocalSetupInAccountCreationViewModel.Completion) {
        switch result {
        case let .next(isBiometricAuthenticationEnabled, isMasterPasswordResetEnabled, isRememberMasterPasswordEnabled):
            self.isBiometricAuthenticationEnabled = isBiometricAuthenticationEnabled
            self.isMasterPasswordResetEnabled = isMasterPasswordResetEnabled
            self.isRememberMasterPasswordEnabled = isRememberMasterPasswordEnabled
            move(to: .userConsent)
        case let .back(isBiometricAuthenticationEnabled, isMasterPasswordResetEnabled, isRememberMasterPasswordEnabled):
            self.isBiometricAuthenticationEnabled = isBiometricAuthenticationEnabled
            self.isMasterPasswordResetEnabled = isMasterPasswordResetEnabled
            self.isRememberMasterPasswordEnabled = isRememberMasterPasswordEnabled
            navigator.pop(animated: true)
        }
    }

        private func handle(_ result: UserConsentViewModel.Completion) {
        switch result {
        case let .back(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing):
            self.hasUserAcceptedTermsAndConditions = hasUserAcceptedTermsAndConditions
            self.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
            self.navigator.pop(animated: true)
        case let .next(hasUserAcceptedTermsAndConditions: hasUserAcceptedTermsAndConditions, hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing):
            self.hasUserAcceptedTermsAndConditions = hasUserAcceptedTermsAndConditions
            self.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
            self.move(to: .createAccount)
        }
    }

    private func applyFastLocalSetupSettings(using sessionServices: SessionServicesContainer) {
        applyBiometricAuthenticationSettings(using: sessionServices.lockService)
        applyMasterPasswordResetSettings(using: sessionServices.resetMasterPasswordService)
        applyRememberMasterPasswordSettings(using: sessionServices.lockService)
    }

    private func applyBiometricAuthenticationSettings(using lockService: LockService) {
        guard let isEnabled = isBiometricAuthenticationEnabled else {
            return
        }

        appServices.installerLogService.accountCreation.logBiometricAuthenticationActivation(Device.biometryType, isEnabled: isEnabled)

        if isEnabled {
            try? lockService.secureLockConfigurator.enableBiometry()
        }
    }

    private func applyMasterPasswordResetSettings(using resetMasterPasswordService: ResetMasterPasswordService) {
        guard let masterPassword = masterPassword, let isEnabled = isMasterPasswordResetEnabled else {
            return
        }

        self.appServices.installerLogService.accountCreation.logMasterPasswordResetActivation(isEnabled: isEnabled)

        if isEnabled {
            try? resetMasterPasswordService.activate(using: masterPassword)
        }
    }

    private func applyRememberMasterPasswordSettings(using lockService: LockService) {
        guard isRememberMasterPasswordEnabled == true else {
            return
        }

        try? lockService.secureLockConfigurator.enableRememberMasterPassword()
    }
}

extension AccountCreationCoordinator {

    private func createAccount(with email: DashTypes.Email, password: String, hasUserAcceptedEmailMarketing: Bool) {

        guard isAccountCreationInProgress == false else {
            return
        }

                isAccountCreationInProgress = true

        do {
            let sessionCryptoEngine = try appServices.sessionCryptoEngineProvider.sessionCryptoEngine(for: .masterPassword(password))
            let cryptoConfig = sessionCryptoEngine.config
            let creationInfo = try AccountCreationInfo(email: email,
                                                       appVersion: Application.version(),
                                                       cryptoEngine: sessionCryptoEngine,
                                                       hasUserAcceptedEmailMarketing: hasUserAcceptedEmailMarketing,
                                                       origin: .iOS)

            self.accountCreationHandler.createAccount(with: creationInfo) { result in
                switch result {
                    case .success(let accountInfo):
                        let configuration = SessionConfiguration(login: Login(creationInfo.login),
                                                                 masterKey: .masterPassword(password, serverKey: nil),
                                                                 keys: SessionSecureKeys(serverAuthentication: ServerAuthentication(deviceAccessKey: accountInfo.deviceAccessKey, deviceSecretKey: accountInfo.deviceSecretKey),
                                                                                         remoteKey: nil,
                                                                                         analyticsIds: accountInfo.analyticsIds),
                                                                 info: SessionInfo(deviceAccessKey: accountInfo.deviceAccessKey,
                                                                                   loginOTPOption: nil,
                                                                                   isPartOfSSOCompany: false))

                        self.appServices.installerLogService.accountCreation.log(.finishingAccountCreation)
                        self.createSession(with: configuration, cryptoConfig: cryptoConfig)
                    case let .failure(error):
                        self.isAccountCreationInProgress = false
                        self.showError(error, login: Login(email.address))
                        self.logger.error("Failed to create account", error: error)
                }
            }
        } catch {
            creationLogger.error("Failed to create account", error: error)
        }
    }

    private func showError(_ error: Error, login: Login) {
        let alert: UIAlertController = {
            if case AccountCreationError.expiredVersion = error {
                return VersionValidityAlert.errorAlert()
            } else {
                let title = CoreLocalization.L10n.errorMessage(for: error, login: login)
                let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction.init(title: L10n.Localizable.kwButtonOk, style: .default, handler: nil))
                return alert
            }
        }()

        DispatchQueue.main.async {
            self.navigator.topViewController?.present(alert, animated: true)
        }
    }
}

extension AccountCreationCoordinator {

    private func makeLoginHandler() -> LoginHandler {
        return LoginHandler(sessionsContainer: appServices.sessionContainer,
                            apiClient: appServices.appAPIClient,
                            deviceInfo: DeviceInfo.default,
                            logger: self.logger,
                            cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
                            removeLocalDataHandler: appServices.sessionCleaner.removeLocalData)
    }

    private func createSession(with sessionConfiguration: SessionConfiguration, cryptoConfig: CryptoRawConfig) {
        self.makeLoginHandler().createSession(with: sessionConfiguration, cryptoConfig: cryptoConfig) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(session):
                self.buildSessionServices(from: session)
            case let .failure(error):
                self.logger.fatal("Failed to create session", error: error)
            }
        }
    }

    func buildSessionServices(from session: Session) {
        self.appServices.loginUsageLogService.didRegisterNewDevice()
        self.sessionServicesSubscription = SessionServicesContainer
            .buildSessionServices(from: session,
                                  appServices: self.appServices,
                                  logger: self.logger,
                                  loadingContext: .accountCreation) { [weak self] result in
                                    guard let self = self else { return }

                                    switch result {
                                    case let .success(sessionServices):
                                        sessionServices.activityReporter.logAccountCreationSuccessful()
                                        self.applyFastLocalSetupSettings(using: sessionServices)
                                        self.completion(.finished(sessionServices))
                                    case let .failure(error):
                                        self.showError(error, login: session.login)
                                        self.logger.error("Failed to create account", error: error)
                                        self.completion(.cancel)
                                    }
        }
    }

    func startSSOAccountCreation(with info: SSOLoginInfo) {

        guard let email = self.email else {
            return
        }
        startSubcoordinator(SSOAccountCreationCoordinator(email: email,
                                                          appServices: appServices,
                                                          navigator: navigator,
                                                          accountCreationHandler: accountCreationHandler,
                                                          isEmailMarketingOptInRequired: isEmailMarketingOptInRequired,
                                                          logger: logger,
                                                          initialStep: .authenticate(info.serviceProviderURL),
                                                          ssoLogger: appServices.installerLogService.sso,
                                                          isNitroProvider: info.isNitroProvider,
                                                          completion: { result in
                                                            switch result {
                                                            case .accountCreated(let sessionServices):
                                                                self.completion(.finished(sessionServices))
                                                            case .cancel:
                                                                self.completion(.cancel)
                                                            }

        }))
    }
}

private extension ActivityReporterProtocol {
    func logAccountCreationSuccessful() {
        let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        let idfv = UIDevice.current.identifierForVendor?.uuidString
        let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized

        report(UserEvent.CreateAccount(iosMarketing: .init(adid: Adjust.adid(), idfa: idfa, idfv: idfv),
                                       isMarketingOptIn: isMarketingOptIn,
                                       status: .success))
    }
}
