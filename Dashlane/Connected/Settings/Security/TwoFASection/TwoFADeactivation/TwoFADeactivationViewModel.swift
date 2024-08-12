import AuthenticatorKit
import Combine
import CoreKeychain
import CorePersonalData
import CoreSession
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import TOTPGenerator
import VaultKit

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
  let appAPIClient: AppAPIClient
  let userAPIClient: UserDeviceAPIClient
  let logger: Logger
  let option: Dashlane2FAType
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
  var progressState: ProgressionState = .inProgress(
    L10n.Localizable.twofaDeactivationProgressMessage)

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
  var subscriptions = Set<AnyCancellable>()
  var accountCryptoChangerService: AccountCryptoChangerService?

  init(
    session: Session,
    sessionsContainer: SessionsContainerProtocol,
    appAPIClient: AppAPIClient,
    userAPIClient: UserDeviceAPIClient,
    logger: Logger,
    authenticatorCommunicator: AuthenticatorServiceProtocol,
    syncService: SyncServiceProtocol,
    keychainService: AuthenticationKeychainServiceProtocol,
    sessionCryptoUpdater: SessionCryptoUpdater,
    activityReporter: ActivityReporterProtocol,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    databaseDriver: DatabaseDriver,
    sessionLifeCycleHandler: SessionLifeCycleHandler?,
    isTwoFAEnforced: Bool
  ) {
    self.session = session
    self.sessionsContainer = sessionsContainer
    self.appAPIClient = appAPIClient
    self.userAPIClient = userAPIClient
    self.option = session.configuration.info.loginOTPOption != nil ? .otp2 : .otp1
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
    self.lostOTPSheetViewModel = LostOTPSheetViewModel(
      appAPIClient: appAPIClient,
      login: session.login)
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
    } catch let error as DashlaneAPI.APIError where error.hasAuthenticationCode(.verificationFailed)
    {
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
    try await self.userAPIClient.authentication.deactivateTOTP(authTicket: authTicket)
    deleteCodeFromAuthenticatorApp()
    await MainActor.run {
      progressState = .completed(
        L10n.Localizable.twofaDeactivationFinalMessage,
        {
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
    let verificationResponse = try await appAPIClient.authentication.performTotpVerification
      .callAsFunction(login: session.login.email, otp: code)
    return verificationResponse.authTicket
  }

  @MainActor
  func deleteCodeFromAuthenticatorApp() {
    guard
      let otpInfo =
        (authenticatorCommunicator.codes.filter {
          $0.configuration.login == session.login.email && $0.isDashlaneOTP
        }.last)
    else {
      return
    }
    self.authenticatorCommunicator.deleteOTP(otpInfo)
    self.authenticatorCommunicator.sendMessage(.refresh)
  }

  func startOTP2Deactivation(withAuthTicket authTicket: String) {
    do {
      let migratingSession = try sessionsContainer.prepareMigration(
        of: session,
        to: .masterPassword(session.authenticationMethod.userMasterPassword!, serverKey: nil),
        remoteKey: nil,
        cryptoConfig: CryptoRawConfig.masterPasswordBasedDefault,
        accountMigrationType: .masterPasswordToMasterPassword, loginOTPOption: nil)

      let postCryptoChangeHandler = PostMasterKeyChangerHandler(
        keychainService: keychainService,
        resetMasterPasswordService: resetMasterPasswordService,
        syncService: syncService)

      accountCryptoChangerService = try AccountCryptoChangerService(
        reportedType: .masterPasswordChange,
        migratingSession: migratingSession,
        syncService: syncService,
        sessionCryptoUpdater: sessionCryptoUpdater,
        activityReporter: activityReporter,
        sessionsContainer: sessionsContainer,
        databaseDriver: databaseDriver,
        postCryptoChangeHandler: postCryptoChangeHandler,
        apiClient: userAPIClient,
        authTicket: AuthTicket(token: authTicket, verification: .init(type: .emailToken)),
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
      state = .failure
    }
  }
}

extension TwoFADeactivationViewModel {
  func didProgress(_ progression: AccountCryptoChangerService.Progression) {
    logger.debug("Otp2 deactivation in progress: \(progression)")
  }

  func didFinish(with result: Result<Session, AccountCryptoChangerError>) {
    switch result {
    case .success(let session):
      guard
        let item =
          (self.authenticatorCommunicator.codes.filter {
            $0.configuration.login == session.login.email && $0.isDashlaneOTP
          }.last)
      else {
        return
      }
      try? self.keychainService.removeServerKey(for: session.login)
      self.authenticatorCommunicator.deleteOTP(item)
      self.authenticatorCommunicator.sendMessage(.refresh)
      self.logger.info("Otp2 deactivation is sucessful")
      progressState = .completed(
        L10n.Localizable.twofaDeactivationFinalMessage,
        { [weak self] in
          self?.sessionLifeCycleHandler?.logoutAndPerform(
            action: .startNewSession(session, reason: .masterPasswordChanged))
        })
    case let .failure(error):
      self.logger.fatal("Otp2 deactivation failed", error: error)
      state = .failure
    }
  }
}

extension TwoFADeactivationViewModel {
  static func mock(state: State = .otpInput) -> TwoFADeactivationViewModel {
    let services = MockServicesContainer()
    let model = TwoFADeactivationViewModel(
      session: .mock,
      sessionsContainer: FakeSessionsContainer(),
      appAPIClient: .fake,
      userAPIClient: .fake,
      logger: LoggerMock(),
      authenticatorCommunicator: AuthenticatorAppCommunicatorMock(),
      syncService: services.syncService,
      keychainService: .fake,
      sessionCryptoUpdater: .mock,
      activityReporter: .mock,
      resetMasterPasswordService: ResetMasterPasswordService.mock,
      databaseDriver: InMemoryDatabaseDriver(),
      sessionLifeCycleHandler: nil,
      isTwoFAEnforced: false)
    model.state = state
    return model
  }
}
