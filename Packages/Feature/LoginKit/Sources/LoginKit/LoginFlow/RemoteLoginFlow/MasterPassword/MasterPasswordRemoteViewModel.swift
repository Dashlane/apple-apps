import Combine
import CoreLocalization
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

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
  let keys: LoginKeys
  let activityReporter: ActivityReporterProtocol

  private let verificationMode: Definition.VerificationMode
  private let isBackupCode: Bool
  private let appAPIClient: AppAPIClient
  private let recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory
  private let cryptoEngineProvider: CryptoEngineProvider

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
    keys: LoginKeys,
    cryptoEngineProvider: CryptoEngineProvider,
    recoveryKeyLoginFlowModelFactory: AccountRecoveryKeyLoginFlowModel.Factory,
    completion: @escaping () -> Void
  ) {
    self.login = login
    self.isExtension = isExtension
    self.verificationMode = verificationMode
    self.isBackupCode = isBackupCode
    self.loginMetricsReporter = loginMetricsReporter
    self.validator = validator
    self.logger = logger
    self.keys = keys
    self.completion = completion
    self.activityReporter = activityReporter
    self.appAPIClient = appAPIClient
    self.recoveryKeyLoginFlowModelFactory = recoveryKeyLoginFlowModelFactory
    self.cryptoEngineProvider = cryptoEngineProvider
    Task {
      await fetchAccountRecoveryKeyStatus()
    }
  }

  func fetchAccountRecoveryKeyStatus() async {
    let response = try? await appAPIClient.accountrecovery.getStatus(login: login.email)
    isAccountRecoveryEnabled = response?.enabled ?? false
  }

  public func validate() async {
    self.showWrongPasswordError = false
    inProgress = true
    loginMetricsReporter.startLoginTimer(from: .masterPassword)

    do {
      try await validateMasterPassword()
      self.errorMessage = nil
      self.completion()
    } catch let error {
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

  public func validateMasterPassword() async throws {
    if let remoteKey = keys.remoteKey, let remoteKeyData = Data(base64Encoded: remoteKey.key) {
      let cryptoEngine = try cryptoEngineProvider.sessionCryptoEngine(
        forEncryptedPayload: remoteKeyData,
        masterKey: .masterPassword(password, serverKey: nil))

      guard let decipheredRemoteKey = try? cryptoEngine.decrypt(remoteKeyData) else {
        throw RemoteLoginHandler.Error.wrongMasterKey
      }

      try await validator.validateMasterKeyAndRegister(
        .masterPassword(password),
        authTicket: keys.authTicket,
        remoteKey: decipheredRemoteKey,
        isRecoveryLogin: false)
    } else {
      try await validator.validateMasterKeyAndRegister(
        .masterPassword(password),
        authTicket: keys.authTicket,
        isRecoveryLogin: false)
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
      login: login,
      accountType: .masterPassword,
      loginType: .remote(keys.authTicket),
      completion: { [weak self] result in
        guard let self = self else {
          return
        }
        guard case let .completedWithChangeMP(masterKey, authTicket, newMasterPassword) = result
        else {
          return
        }
        self.showRecoveryProgress = true
        Task {
          do {
            try await self.validator.validateMasterKeyAndRegister(
              masterKey,
              authTicket: authTicket,
              isRecoveryLogin: true,
              newMasterPassword: newMasterPassword)
          } catch {
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
      activityReporter: .mock,
      validator: .mock,
      logger: LoggerMock(),
      keys: .init(remoteKey: nil, authTicket: AuthTicket(value: "authTicket")),
      cryptoEngineProvider: FakeCryptoEngineProvider(),
      recoveryKeyLoginFlowModelFactory: .init { _, _, _, _ in .mock },
      completion: {}
    )
  }
}
