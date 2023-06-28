import Foundation
import CoreSession
import Combine
import AuthenticatorKit
import TOTPGenerator
import CoreNetworking
import CoreKeychain
import DashlaneCrypto
import DashTypes
import LoginKit
import DashlaneAppKit
import CorePersonalData
import CoreUserTracking
import CoreSync

class TwoFACompletionViewModel: ObservableObject, SessionServicesInjecting {

    enum State: Equatable {
        static func == (lhs: TwoFACompletionViewModel.State, rhs: TwoFACompletionViewModel.State) -> Bool {
            return lhs.id == rhs.id
        }

        case inProgress
        case success(onDismiss: () -> Void)
        case failure(OTPError)

        public var id: String {
            switch self {
            case .inProgress:
                return "inProgress"
            case .success:
                return "success"
            case .failure:
                return "failure"
            }
        }
    }

    @Published
    var state: State = .inProgress

    @Published
    var progressState: ProgressionState = .inProgress(L10n.Localizable.twofaActivationProgressMessage)

    let option: TFAOption
    let response: TOTPActivationResponse

    let authenticatedAPIClient: DeprecatedCustomAPIClient
    let appAPIClient: AppAPIClient
    let session: Session
    let sessionsContainer: SessionsContainerProtocol
    let keychainService: AuthenticationKeychainServiceProtocol
    let authenticatorCommunicator: AuthenticatorServiceProtocol
    let syncService: SyncServiceProtocol
    let resetMasterPasswordService: ResetMasterPasswordServiceProtocol
    let completion: () -> Void
    let databaseDriver: DatabaseDriver
    var subscriptions = Set<AnyCancellable>()
    var accountCryptoChangerService: AccountCryptoChangerService?
    let sessionCryptoUpdater: SessionCryptoUpdater
    let activityReporter: ActivityReporterProtocol
    let logger: Logger
    let sessionLifeCycleHandler: SessionLifeCycleHandler?
    let userDeviceAPIClient: UserDeviceAPIClient

    init(option: TFAOption,
         response: TOTPActivationResponse,
         session: Session,
         sessionsContainer: SessionsContainerProtocol,
         keychainService: AuthenticationKeychainServiceProtocol,
         authenticatorCommunicator: AuthenticatorServiceProtocol,
         syncService: SyncServiceProtocol,
         resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
         databaseDriver: DatabaseDriver,
         sessionCryptoUpdater: SessionCryptoUpdater,
         activityReporter: ActivityReporterProtocol,
         authenticatedAPIClient: DeprecatedCustomAPIClient,
         appAPIClient: AppAPIClient,
         userDeviceAPIClient: UserDeviceAPIClient,
         sessionLifeCycleHandler: SessionLifeCycleHandler?,
         logger: Logger,
         completion: @escaping () -> Void) {
        self.option = option
        self.response = response
        self.session = session
        self.sessionsContainer = sessionsContainer
        self.keychainService = keychainService
        self.authenticatorCommunicator = authenticatorCommunicator
        self.syncService = syncService
        self.resetMasterPasswordService = resetMasterPasswordService
        self.logger = logger
        self.databaseDriver = databaseDriver
        self.sessionCryptoUpdater = sessionCryptoUpdater
        self.completion = completion
        self.authenticatedAPIClient = authenticatedAPIClient
        self.appAPIClient = appAPIClient
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        self.activityReporter = activityReporter
        self.userDeviceAPIClient = userDeviceAPIClient
        Task {
            await start()
        }
    }

    func start() async {
        await changeState(to: .inProgress)
        switch option {
        case .firstLogin:
            await enableOTP1()
        case .everyLogin:
            await enableOTP2()
        }
    }

    func enableOTP1() async {
        do {
            let (response, authTicket, otpInfo) = try await validateOTP()
            try await completeTOTPActivation(with: response, authTicket: authTicket, otpInfo: otpInfo)
            await MainActor.run {
                progressState = .completed(L10n.Localizable.twofaActivationFinalMessage, {})
            }
            Task.delayed(by: 2) {
                await changeState(to: .success(onDismiss: completion))
            }
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            await changeState(to: .failure(.noInternet))
        } catch {
            await changeState(to: .failure(.unknown))
        }
    }

    @MainActor
    func changeState(to newState: State) {
        self.state = newState
    }

    func enableOTP2() async {
        do {
            let (response, authTicket, otpInfo) = try await validateOTP()
            self.startOtp2(with: response, authTicket: authTicket, otpInfo: otpInfo)
        } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
            await changeState(to: .failure(.noInternet))
        } catch {
            await changeState(to: .failure(.unknown))
        }
    }

        func validateOTP() async throws -> (TOTPActivationResponse, String, OTPInfo) {
        guard let url = URL(string: self.response.uri), let config = try? OTPConfiguration(otpURL: url, supportDashlane2FA: true) else {
            throw OTPError.unknown
        }
        let otp = TOTPGenerator.generate(with: config.type, for: Date(), digits: config.digits, algorithm: config.algorithm, secret: config.secret)
        let verificationResponse = try await appAPIClient.authentication.performTotpVerification(login: self.session.login.email, otp: otp, activationFlow: true)
        return (self.response, verificationResponse.authTicket, OTPInfo(configuration: config, isFavorite: true, recoveryCodes: self.response.recoveryKeys))
    }

    func completeTOTPActivation(with response: TOTPActivationResponse, authTicket: String, otpInfo: OTPInfo) async throws {
        try self.authenticatorCommunicator.addOTP(otpInfo)
        self.authenticatorCommunicator.sendMessage(.refresh)
        try await self.userDeviceAPIClient.authentication.completeTOTPActivation(authTicket: authTicket)
    }

    func startOtp2(with response: TOTPActivationResponse, authTicket: String, otpInfo: OTPInfo) {
        do {
            try self.authenticatorCommunicator.addOTP(otpInfo)
            self.authenticatorCommunicator.sendMessage(.refresh)

            let serverKey = response.serverKey
            let migratingSession = try sessionsContainer.prepareMigration(of: session,
                                                                          to: .masterPassword(session.authenticationMethod.userMasterPassword!, serverKey: serverKey), remoteKey: nil,
                                                                          cryptoConfig: CryptoRawConfig.masterPasswordBasedDefault,
                                                                          accountMigrationType: .masterPasswordToMasterPassword, loginOTPOption: .authenticatorPush)

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
                                                                          authTicket: AuthTicket(token: authTicket, verification: .init(type: .totp, serverKey: response.serverKey)),
                                                                          logger: self.logger,
                                                                          cryptoSettings: migratingSession.target.cryptoConfig)

            accountCryptoChangerService?.progressPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                guard let self = self else {
                    return
                }
                switch state {
                case let .inProgress(progression):
                    self.didProgress(progression)
                case let .finished(result):
                    self.didFinish(with: result)
                }
            }.store(in: &subscriptions)
            accountCryptoChangerService?.start()
        } catch {
            self.state = .failure(.unknown)
        }
    }
}

extension TwoFACompletionViewModel {
    func didProgress(_ progression: AccountCryptoChangerService.Progression) {
        logger.debug("Otp2 activation in progress: \(progression)")
    }

    func didFinish(with result: Result<Session, AccountCryptoChangerError>) {
        switch result {
        case .success(let session):
            if let serverKey = session.authenticationMethod.sessionKey.serverKey {
                try? self.keychainService.saveServerKey(serverKey, for: session.login)
                self.authenticatorCommunicator.sendMessage(.refresh)
            }
            self.logger.info("Otp2 activation is sucessful")
            self.progressState = .completed(L10n.Localizable.twofaActivationFinalMessage, {
                self.state = .success(onDismiss: {
                    self.sessionLifeCycleHandler?.logoutAndPerform(action: .startNewSession(session, reason: .masterPasswordChanged))
                })
            })
        case .failure:
            self.state = .failure(.unknown)
        }
    }
}

enum OTPError: String, Error, Identifiable {
    var id: String {
        rawValue
    }
    case noInternet
    case unknown
}

extension TwoFACompletionViewModel {
    static func mock(_ option: TFAOption, response: TOTPActivationResponse) -> TwoFACompletionViewModel {
        return .init(option: option,
                     response: response,
                     session: .mock,
                     sessionsContainer: FakeSessionsContainer(),
                     keychainService: .fake,
                     authenticatorCommunicator: AuthenticatorAppCommunicatorMock(),
                     syncService: SyncServiceMock(),
                     resetMasterPasswordService: ResetMasterPasswordServiceMock(),
                     databaseDriver: InMemoryDatabaseDriver(),
                     sessionCryptoUpdater: .mock,
                     activityReporter: .fake,
                     authenticatedAPIClient: .fake,
                     appAPIClient: AppAPIClient.fake,
                     userDeviceAPIClient: UserDeviceAPIClient.fake,
                     sessionLifeCycleHandler: nil,
                     logger: LoggerMock(),
                     completion: {})
    }
}
