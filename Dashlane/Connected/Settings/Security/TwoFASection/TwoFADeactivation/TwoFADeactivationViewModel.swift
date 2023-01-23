import Foundation
import CoreSession
import TOTPGenerator
import DashTypes
import CoreNetworking
import CoreSync
import CoreKeychain
import CoreUserTracking
import DashlaneAppKit
import CorePersonalData
import AuthenticatorKit
import LoginKit
import Combine

@MainActor
class TwoFADeactivationViewModel: ObservableObject, SessionServicesInjecting {

    enum State: String, Equatable {
        case twoFAEnforced
        case otpInput
        case inProgress
        case failure
    }

    let session: Session
    let sessionsContainer: SessionsContainerProtocol
    let authenticatedAPIClient: DeprecatedCustomAPIClient
    let appAPIClient: AppAPIClient
    let logger: Logger
    let option: Dashlane2FAType
    let accountAPIClient: AccountAPIClientProtocol
    let persistor: AuthenticatorDatabaseServiceProtocol
    let syncService: SyncServiceProtocol
    let keychainService: AuthenticationKeychainServiceProtocol
    let sessionCryptoUpdater: SessionCryptoUpdater
    let activityReporter: ActivityReporterProtocol
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let databaseDriver: DatabaseDriver
    let sessionLifeCycleHandler: SessionLifeCycleHandler?
    var lostOTPSheetViewModel: LostOTPSheetViewModel

    @Published
    var showError = false

    @Published
    var state: State

    @Published
    var progressState: TwoFAProgressView.State = .inProgress(L10n.Localizable.twofaDeactivationProgressMessage)

    @Published
    var isTokenError = false

    let authenticatorCommunicator: AuthenticatorServiceProtocol

    var login: Login {
        return session.login
    }

    @Published
    var otpValue: String = "" {
        didSet {
            isTokenError = false
        }
    }

    var dismissPublisher = PassthroughSubject<Void, Never>()

    var canValidate: Bool {
        otpValue.count == 6
    }

    var accountCryptoChangerService: AccountCryptoChangerService?
    init(session: Session,
         sessionsContainer: SessionsContainerProtocol,
         authenticatedAPIClient: DeprecatedCustomAPIClient,
         appAPIClient: AppAPIClient,
         logger: Logger,
         authenticatorCommunicator: AuthenticatorServiceProtocol,
         syncService: SyncServiceProtocol,
         keychainService: AuthenticationKeychainServiceProtocol,
         sessionCryptoUpdater: SessionCryptoUpdater,
         activityReporter: ActivityReporterProtocol,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         databaseDriver: DatabaseDriver,
         persistor: AuthenticatorDatabaseServiceProtocol,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         isTwoFAEnforced: Bool,
         recover2faWebService: Recover2FAWebService) {
        self.session = session
        self.sessionsContainer = sessionsContainer
        self.authenticatedAPIClient = authenticatedAPIClient
        self.appAPIClient = appAPIClient
        self.option = session.configuration.info.loginOTPOption != nil ? .otp2 : .otp1
        self.accountAPIClient = AccountAPIClient(apiClient: authenticatedAPIClient)
        self.persistor = persistor
        self.authenticatorCommunicator = authenticatorCommunicator
        self.syncService = syncService
        self.keychainService = keychainService
        self.sessionCryptoUpdater = sessionCryptoUpdater
        self.activityReporter = activityReporter
        self.resetMasterPasswordService = resetMasterPasswordService
        self.databaseDriver = databaseDriver
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.logger = logger
        self.state = isTwoFAEnforced == true ? .twoFAEnforced : .otpInput
        self.lostOTPSheetViewModel = LostOTPSheetViewModel(recover2faService: recover2faWebService)
    }

    func disable(_ code: String) async {
        state = .inProgress
        do {
            switch option {
            case .otp1:
                try await disableOtp1(code)
            case .otp2:
                try await disableOtp2(code)
            }
        } catch let error as AccountError where error == .verificationDenied {
            await MainActor.run {
                state = .otpInput
                isTokenError = true
            }
        } catch {
            await MainActor.run {
                state = .failure
            }
        }
    }

    func disableOtp1(_ code: String) async throws {
        let authTicket = try await validateOTP(code)
        try await self.accountAPIClient.deactivateTOTP(withAuthTicket: authTicket)
        deleteCodeFromAuthenticatorApp()
        await MainActor.run {
            progressState = .completed(L10n.Localizable.twofaDeactivationFinalMessage, {
                self.dismissPublisher.send()
            })
        }
    }

    func disableOtp2(_ code: String) async throws {
        let authTicket = try await validateOTP(code)
        startOTP2Deactivation(withAuthTicket: authTicket)
    }

    func useBackupCode(_ code: String) async {
        await disable(code)
    }
}

extension TwoFADeactivationViewModel {

    func validateOTP(_ code: String) async throws -> String {
        let webservice = AccountAPIClient(apiClient: appAPIClient)
        let verificationResponse = try await webservice
            .performVerification(with: PerformTOTPVerificationRequest(login: session.login.email, otp: code))
        return verificationResponse.authTicket
    }

    @MainActor
    func deleteCodeFromAuthenticatorApp() {
        guard let otpInfo = (persistor.codes.filter { $0.configuration.login == session.login.email && $0.isDashlaneOTP }.last) else {
            return
        }
        try? self.persistor.delete(otpInfo)
        self.authenticatorCommunicator.sendMessage(.refresh)
    }

    func startOTP2Deactivation(withAuthTicket authTicket: String) {
        do {
            let migratingSession = try sessionsContainer.prepareMigration(of: session,
                                                                          to: .masterPassword(session.configuration.masterKey.masterPassword!, serverKey: nil), remoteKey: nil,
                                                                          cryptoConfig: CryptoRawConfig.masterPasswordBasedDefault,
                                                                          accountMigrationType: .masterPasswordToMasterPassword, loginOTPOption: nil)

            let postCryptoChangeHandler = PostMasterKeyChangerHandler(keychainService: keychainService,
                                                                      resetMasterPasswordService: resetMasterPasswordService,
                                                                      syncService: syncService)

            accountCryptoChangerService = try AccountCryptoChangerService(reportedType: .masterPasswordChange,
                                                                          migratingSession: migratingSession,
                                                                          syncService: syncService,
                                                                          sessionCryptoUpdater: sessionCryptoUpdater,
                                                                          activityReporter: activityReporter,
                                                                          sessionsContainer: sessionsContainer,
                                                                          databaseDriver: databaseDriver,
                                                                          postCryptoChangeHandler: postCryptoChangeHandler,
                                                                          apiNetworkingEngine: authenticatedAPIClient,
                                                                          authTicket: AuthTicket(token: authTicket, verification: .init(type: .email_token)),
                                                                          logger: self.logger,
                                                                          cryptoSettings: migratingSession.target.cryptoConfig)

            accountCryptoChangerService?.delegate = self
            accountCryptoChangerService?.start()
        } catch {
            state = .failure
        }
    }
}

extension TwoFADeactivationViewModel: AccountCryptoChangerServiceDelegate {
    func didProgress(_ progression: AccountCryptoChangerService.Progression) {
        logger.debug("Otp2 deactivation in progress: \(progression)")
    }

    func didFinish(with result: Result<Session, AccountCryptoChangerError>) {
        DispatchQueue.main.async { [self] in
            switch result {
            case .success(let session):
                guard let item = (self.persistor.codes.filter { $0.configuration.login == session.login.email  && $0.isDashlaneOTP }.last) else {
                    return
                }
                try? self.keychainService.removeServerKey(for: session.login)
                try? self.persistor.delete(item)
                self.authenticatorCommunicator.sendMessage(.refresh)
                self.logger.info("Otp2 deactivation is sucessfull")
                progressState = .completed(L10n.Localizable.twofaDeactivationFinalMessage, { [weak self] in
                    self?.sessionLifeCycleHandler?.logoutAndPerform(action: .startNewSession(session, reason: .masterPasswordChanged))
                })
            case let .failure(error):
                self.logger.fatal("Otp2 deactivation failed", error: error)
                state = .failure
            }
        }
    }
}

extension TwoFADeactivationViewModel {
    static func mock(state: State = .otpInput) -> TwoFADeactivationViewModel {
        let services = MockServicesContainer()
        var model = TwoFADeactivationViewModel(session: .mock,
                                               sessionsContainer: FakeSessionsContainer(),
                                               authenticatedAPIClient: .fake,
                                               appAPIClient: .mock({ _ in }),
                                               logger: LoggerMock(),
                                               authenticatorCommunicator: AuthenticatorAppCommunicatorMock(),
                                               syncService: services.syncService,
                                               keychainService: .fake,
                                               sessionCryptoUpdater: .mock,
                                               activityReporter: .fake,
                                               resetMasterPasswordService: ResetMasterPasswordService.mock,
                                               databaseDriver: InMemoryDatabaseDriver(),
                                               persistor: AuthenticatorDatabaseServiceMock(),
                                               sessionLifeCycleHandler: nil,
                                               isTwoFAEnforced: false,
                                               recover2faWebService: .init(webService: LegacyWebServiceMock(response: ""), login: .init("_")))
        model.state = state
        return model
    }
}
