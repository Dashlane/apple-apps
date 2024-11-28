#if canImport(AuthenticationServices)
  import AuthenticationServices
#endif
#if canImport(Combine)
  import Combine
#endif
#if canImport(CoreCrypto)
  import CoreCrypto
#endif
#if canImport(CoreKeychain)
  import CoreKeychain
#endif
#if canImport(CoreLocalization)
  import CoreLocalization
#endif
#if canImport(CoreNetworking)
  import CoreNetworking
#endif
#if canImport(CorePasswords)
  import CorePasswords
#endif
#if canImport(CoreSession)
  import CoreSession
#endif
#if canImport(CoreSettings)
  import CoreSettings
#endif
#if canImport(CoreUserTracking)
  import CoreUserTracking
#endif
#if canImport(DashTypes)
  import DashTypes
#endif
#if canImport(DashlaneAPI)
  import DashlaneAPI
#endif
#if canImport(Foundation)
  import Foundation
#endif
#if canImport(LocalAuthentication)
  import LocalAuthentication
#endif
#if canImport(Logger)
  import Logger
#endif
#if canImport(StateMachine)
  import StateMachine
#endif
#if canImport(SwiftTreats)
  import SwiftTreats
#endif
#if canImport(SwiftUI)
  import SwiftUI
#endif
#if canImport(UIComponents)
  import UIComponents
#endif
#if canImport(UIDelight)
  import UIDelight
#endif
#if canImport(UIKit)
  import UIKit
#endif

public protocol LoginKitServicesInjecting {}

extension LoginKitServicesContainer {
  @MainActor
  public func makeAccountRecoveryKeyLoginFlowModel(
    login: Login, accountType: CoreSession.AccountType,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> AccountRecoveryKeyLoginFlowModel {
    return AccountRecoveryKeyLoginFlowModel(
      login: login,
      accountType: accountType,
      loginType: loginType,
      appAPIClient: appAPIClient,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      passwordEvaluator: passwordEvaluator,
      activityReporter: activityReporter,
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      accountRecoveryKeyLoginViewModelFactory: InjectedFactory(
        makeAccountRecoveryKeyLoginViewModel),
      newMasterPasswordViewModelFactory: InjectedFactory(makeNewMasterPasswordViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeAccountRecoveryKeyLoginViewModel(
    accountType: CoreSession.AccountType,
    generateMasterKey: @MainActor @escaping (_ recoveryKey: String) async -> Void
  ) -> AccountRecoveryKeyLoginViewModel {
    return AccountRecoveryKeyLoginViewModel(
      accountType: accountType,
      generateMasterKey: generateMasterKey
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeAccountVerificationFlowModel(
    login: Login, mode: Definition.Mode, verificationMethod: VerificationMethod,
    deviceInfo: DeviceInfo, debugTokenPublisher: AnyPublisher<String, Never>? = nil,
    completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> AccountVerificationFlowModel {
    return AccountVerificationFlowModel(
      login: login,
      mode: mode,
      verificationMethod: verificationMethod,
      appAPIClient: appAPIClient,
      deviceInfo: deviceInfo,
      debugTokenPublisher: debugTokenPublisher,
      tokenVerificationViewModelFactory: InjectedFactory(makeTokenVerificationViewModel),
      totpVerificationViewModelFactory: InjectedFactory(makeTOTPVerificationViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeBiometryViewModel(
    login: Login, biometryType: Biometry, manualLockOrigin: Bool = false,
    unlocker: UnlockSessionHandler, context: LoginUnlockContext, userSettings: UserSettings,
    completion: @escaping (_ isSuccess: Bool) -> Void
  ) -> BiometryViewModel {
    return BiometryViewModel(
      login: login,
      biometryType: biometryType,
      manualLockOrigin: manualLockOrigin,
      unlocker: unlocker,
      context: context,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      userSettings: userSettings,
      keychainService: keychainService,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeConfidentialSSOViewModel(
    login: Login, completion: @escaping Completion<SSOCompletion>
  ) -> ConfidentialSSOViewModel {
    return ConfidentialSSOViewModel(
      login: login,
      nitroClient: nitroClient,
      logger: rootLogger,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {

  public func makeDebugAccountListViewModel() -> DebugAccountListViewModel {
    return DebugAccountListViewModel(
      sessionCleaner: sessionCleaner,
      sessionsContainer: sessionContainer
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferLoginFlowModel(
    login: Login?, deviceInfo: DeviceInfo,
    completion: @MainActor @escaping (Result<DeviceTransferQRCodeFlowModel.Completion, Error>) ->
      Void
  ) -> DeviceTransferLoginFlowModel {
    return DeviceTransferLoginFlowModel(
      login: login,
      deviceInfo: deviceInfo,
      activityReporter: activityReporter,
      totpFactory: InjectedFactory(makeDeviceTransferOTPLoginViewModel),
      deviceToDeviceLoginFlowViewModelFactory: InjectedFactory(makeDeviceTransferQRCodeFlowModel),
      securityChallengeFlowModelFactory: InjectedFactory(
        makeDeviceTransferSecurityChallengeFlowModel),
      deviceTransferRecoveryFlowModelFactory: InjectedFactory(makeDeviceTransferRecoveryFlowModel),
      deviceTransferLoginFlowStateMachineFactory: InjectedFactory(
        makeDeviceTransferLoginFlowStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferLoginFlowStateMachine(login: Login?, deviceInfo: DeviceInfo)
    -> DeviceTransferLoginFlowStateMachine
  {
    return DeviceTransferLoginFlowStateMachine(
      login: login,
      deviceInfo: deviceInfo,
      apiClient: appAPIClient,
      sessionsContainer: sessionContainer,
      logger: rootLogger,
      cryptoEngineProvider: sessionCryptoEngineProvider
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferOTPLoginViewModel(
    initialState: ThirdPartyOTPLoginStateMachine.State, login: Login, option: ThirdPartyOTPOption,
    completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
  ) -> DeviceTransferOTPLoginViewModel {
    return DeviceTransferOTPLoginViewModel(
      initialState: initialState,
      login: login,
      option: option,
      activityReporter: activityReporter,
      appAPIClient: appAPIClient,
      thirdPartyOTPLoginStateMachineFactory: InjectedFactory(makeThirdPartyOTPLoginStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferPassphraseViewModel(
    initialState: PassphraseVerificationStateMachine.State, words: [String], transferId: String,
    secretBox: DeviceTransferSecretBox,
    completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
  ) -> DeviceTransferPassphraseViewModel {
    return DeviceTransferPassphraseViewModel(
      initialState: initialState,
      words: words,
      transferId: transferId,
      secretBox: secretBox,
      passphraseStateMachineFactory: InjectedFactory(makePassphraseVerificationStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferQRCodeFlowModel(
    login: Login?, state: QRCodeFlowStateMachine.State,
    completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQRCodeFlowModel {
    return DeviceTransferQRCodeFlowModel(
      login: login,
      state: state,
      qrCodeLoginViewModelFactory: InjectedFactory(makeDeviceTransferQrCodeViewModel),
      accountRecoveryKeyLoginFlowModelFactory: InjectedFactory(
        makeAccountRecoveryKeyLoginFlowModel),
      deviceTransferQRCodeFlowStateMachineFactory: InjectedFactory(makeQRCodeFlowStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferQrCodeViewModel(
    login: Login?, state: QRCodeScanStateMachine.State,
    completion: @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQrCodeViewModel {
    return DeviceTransferQrCodeViewModel(
      login: login,
      state: state,
      activityReporter: activityReporter,
      deviceTransferQRCodeStateMachineFactory: InjectedFactory(makeQRCodeScanStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferRecoveryFlowModel(
    accountRecoveryInfo: AccountRecoveryInfo, deviceInfo: DeviceInfo,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> DeviceTransferRecoveryFlowModel {
    return DeviceTransferRecoveryFlowModel(
      accountRecoveryInfo: accountRecoveryInfo,
      deviceInfo: deviceInfo,
      recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferSecurityChallengeFlowModel(
    login: Login, completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferSecurityChallengeFlowModel {
    return DeviceTransferSecurityChallengeFlowModel(
      login: login,
      securityChallengeIntroViewModelFactory: InjectedFactory(
        makeDeviceTransferSecurityChallengeIntroViewModel),
      passphraseViewModelFactory: InjectedFactory(makeDeviceTransferPassphraseViewModel),
      securityChallengeFlowStateMachineFactory: InjectedFactory(
        makeSecurityChallengeFlowStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferSecurityChallengeIntroViewModel(
    login: Login,
    completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
  ) -> DeviceTransferSecurityChallengeIntroViewModel {
    return DeviceTransferSecurityChallengeIntroViewModel(
      login: login,
      apiClient: appAPIClient,
      securityChallengeTransferStateMachineFactory: InjectedFactory(
        makeSecurityChallengeTransferStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceUnlinkingFlowViewModel(
    deviceUnlinker: DeviceUnlinker, login: Login, session: RemoteLoginSession,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    completion: @MainActor @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
  ) -> DeviceUnlinkingFlowViewModel {
    return DeviceUnlinkingFlowViewModel(
      deviceUnlinker: deviceUnlinker,
      login: login,
      session: session,
      logger: rootLogger,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      completion: completion
    )
  }
  @MainActor
  public func makeDeviceUnlinkingFlowViewModel(
    deviceUnlinker: DeviceUnlinker, login: Login, authentication: ServerAuthentication,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
  ) -> DeviceUnlinkingFlowViewModel {
    return DeviceUnlinkingFlowViewModel(
      deviceUnlinker: deviceUnlinker,
      login: login,
      authentication: authentication,
      logger: rootLogger,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      userTrackingSessionActivityReporter: activityReporter,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLocalLoginFlowViewModel(
    localLoginHandler: LocalLoginHandler,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings,
    email: String, context: LocalLoginFlowContext,
    completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
  ) -> LocalLoginFlowViewModel {
    return LocalLoginFlowViewModel(
      localLoginHandler: localLoginHandler,
      settingsManager: settingsManager,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      sessionContainer: sessionContainer,
      logger: rootLogger,
      resetMasterPasswordService: resetMasterPasswordService,
      userSettings: userSettings,
      keychainService: keychainService,
      email: email,
      context: context,
      nitroClient: nitroClient,
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      recoveryLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      localLoginUnlockViewModelFactory: InjectedFactory(makeLocalLoginUnlockViewModel),
      ssoLoginViewModelFactory: InjectedFactory(makeSSOLocalLoginViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLocalLoginUnlockViewModel(
    login: Login, accountType: CoreSession.AccountType, unlockType: UnlockType,
    secureLockMode: SecureLockMode, unlocker: UnlockSessionHandler, context: LoginUnlockContext,
    userSettings: UserSettings, resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    localLoginHandler: LocalLoginHandler,
    completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
  ) -> LocalLoginUnlockViewModel {
    return LocalLoginUnlockViewModel(
      login: login,
      accountType: accountType,
      unlockType: unlockType,
      secureLockMode: secureLockMode,
      sessionsContainer: sessionContainer,
      logger: rootLogger,
      unlocker: unlocker,
      context: context,
      userSettings: userSettings,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      resetMasterPasswordService: resetMasterPasswordService,
      appAPIClient: appAPIClient,
      localLoginHandler: localLoginHandler,
      nitroClient: nitroClient,
      sessionCleaner: sessionCleaner,
      keychainService: keychainService,
      masterPasswordLocalViewModelFactory: InjectedFactory(makeMasterPasswordLocalViewModel),
      biometryViewModelFactory: InjectedFactory(makeBiometryViewModel),
      lockPinCodeAndBiometryViewModelFactory: InjectedFactory(makeLockPinCodeAndBiometryViewModel),
      passwordLessRecoveryViewModelFactory: InjectedFactory(makePasswordLessRecoveryViewModel),
      ssoUnlockViewModelFactory: InjectedFactory(makeSSOUnlockViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLockPinCodeAndBiometryViewModel(
    login: Login, accountType: CoreSession.AccountType, pinCodeLock: SecureLockMode.PinCodeLock,
    biometryType: Biometry? = nil, context: LoginUnlockContext, unlocker: UnlockSessionHandler,
    completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void
  ) -> LockPinCodeAndBiometryViewModel {
    return LockPinCodeAndBiometryViewModel(
      login: login,
      accountType: accountType,
      pinCodeLock: pinCodeLock,
      biometryType: biometryType,
      context: context,
      unlocker: unlocker,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLoginFlowViewModel(
    login: Login?, deviceId: String?, loginHandler: LoginHandler,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>, versionValidityAlertProvider: AlertContent,
    context: LocalLoginFlowContext, completion: @escaping (LoginFlowViewModel.Completion) -> Void
  ) -> LoginFlowViewModel {
    return LoginFlowViewModel(
      login: login,
      deviceId: deviceId,
      logger: rootLogger,
      loginHandler: loginHandler,
      loginMetricsReporter: loginMetricsReporter,
      keychainService: keychainService,
      spiegelSettingsManager: settingsManager,
      localLoginViewModelFactory: InjectedFactory(makeLocalLoginFlowViewModel),
      remoteLoginViewModelFactory: InjectedFactory(makeRemoteLoginFlowViewModel),
      loginViewModelFactory: InjectedFactory(makeLoginViewModel),
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      tokenPublisher: tokenPublisher,
      versionValidityAlertProvider: versionValidityAlertProvider,
      context: context,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLoginViewModel(
    email: String?, loginHandler: LoginHandler, staticErrorPublisher: AnyPublisher<Error?, Never>,
    versionValidityAlertProvider: AlertContent,
    completion: @escaping (LoginHandler.LoginResult?) -> Void
  ) -> LoginViewModel {
    return LoginViewModel(
      email: email,
      loginHandler: loginHandler,
      activityReporter: activityReporter,
      loginMetricsReporter: loginMetricsReporter,
      debugAccountsListFactory: InjectedFactory(makeDebugAccountListViewModel),
      staticErrorPublisher: staticErrorPublisher,
      versionValidityAlertProvider: versionValidityAlertProvider,
      appAPIClient: appAPIClient,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordFlowRemoteStateMachine(
    state: MasterPasswordFlowRemoteStateMachine.State, verificationMethod: VerificationMethod,
    deviceInfo: DeviceInfo, login: Login
  ) -> MasterPasswordFlowRemoteStateMachine {
    return MasterPasswordFlowRemoteStateMachine(
      state: state,
      verificationMethod: verificationMethod,
      deviceInfo: deviceInfo,
      login: login,
      appAPIClient: appAPIClient,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordInputRemoteViewModel(
    state: MasterPasswordRemoteStateMachine.State, login: Login, data: DeviceRegistrationData,
    completion: @escaping (RemoteLoginSession) -> Void
  ) -> MasterPasswordInputRemoteViewModel {
    return MasterPasswordInputRemoteViewModel(
      state: state,
      login: login,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      data: data,
      logger: rootLogger,
      recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      masterPasswordRemoteStateMachineFactory: InjectedFactory(
        makeMasterPasswordRemoteStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordLocalLoginStateMachine(
    login: Login, unlocker: UnlockSessionHandler,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
  ) -> MasterPasswordLocalLoginStateMachine {
    return MasterPasswordLocalLoginStateMachine(
      login: login,
      unlocker: unlocker,
      appAPIClient: appAPIClient,
      resetMasterPasswordService: resetMasterPasswordService,
      loginType: loginType,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordLocalViewModel(
    login: Login, biometry: Biometry?, user: AccountRecoveryKeyLoginFlowStateMachine.User,
    unlocker: UnlockSessionHandler, context: LoginUnlockContext,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings,
    completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
  ) -> MasterPasswordLocalViewModel {
    return MasterPasswordLocalViewModel(
      login: login,
      biometry: biometry,
      user: user,
      unlocker: unlocker,
      context: context,
      resetMasterPasswordService: resetMasterPasswordService,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      userSettings: userSettings,
      logger: rootLogger,
      recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      masterPasswordLocalStateMachineFactory: InjectedFactory(
        makeMasterPasswordLocalLoginStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordRemoteLoginFlowModel(
    login: Login, deviceInfo: DeviceInfo, verificationMethod: VerificationMethod,
    tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) -> MasterPasswordRemoteLoginFlowModel {
    return MasterPasswordRemoteLoginFlowModel(
      login: login,
      deviceInfo: deviceInfo,
      verificationMethod: verificationMethod,
      tokenPublisher: tokenPublisher,
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      masterPasswordFactory: InjectedFactory(makeMasterPasswordInputRemoteViewModel),
      masterPasswordRemoteStateMachineFactory: InjectedFactory(
        makeMasterPasswordFlowRemoteStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordRemoteStateMachine(
    state: MasterPasswordRemoteStateMachine.State, login: Login, data: DeviceRegistrationData
  ) -> MasterPasswordRemoteStateMachine {
    return MasterPasswordRemoteStateMachine(
      state: state,
      login: login,
      data: data,
      appAPIClient: appAPIClient,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {

  public func makeNewMasterPasswordViewModel(
    mode: NewMasterPasswordViewModel.Mode, masterPassword: String? = "", login: Login? = nil,
    step: NewMasterPasswordViewModel.Step = .masterPasswordCreation,
    completion: @escaping (NewMasterPasswordViewModel.Completion) -> Void
  ) -> NewMasterPasswordViewModel {
    return NewMasterPasswordViewModel(
      mode: mode,
      masterPassword: masterPassword,
      evaluator: passwordEvaluator,
      keychainService: keychainService,
      login: login,
      activityReporter: activityReporter,
      step: step,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makePassphraseVerificationStateMachine(
    initialState: PassphraseVerificationStateMachine.State, transferId: String,
    secretBox: DeviceTransferSecretBox
  ) -> PassphraseVerificationStateMachine {
    return PassphraseVerificationStateMachine(
      initialState: initialState,
      apiClient: appAPIClient,
      transferId: transferId,
      secretBox: secretBox,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makePasswordLessRecoveryViewModel(
    login: Login, recoverFromFailure: Bool,
    completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void
  ) -> PasswordLessRecoveryViewModel {
    return PasswordLessRecoveryViewModel(
      login: login,
      recoverFromFailure: recoverFromFailure,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeQRCodeFlowStateMachine(state: QRCodeFlowStateMachine.State)
    -> QRCodeFlowStateMachine
  {
    return QRCodeFlowStateMachine(
      sessionCleaner: sessionCleaner,
      state: state,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeQRCodeScanStateMachine(
    login: Login?, state: QRCodeScanStateMachine.State, qrDeviceTransferCrypto: ECDHProtocol
  ) -> QRCodeScanStateMachine {
    return QRCodeScanStateMachine(
      login: login,
      state: state,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      qrDeviceTransferCrypto: qrDeviceTransferCrypto,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeRegularRemoteLoginFlowViewModel(
    login: Login, deviceRegistrationMethod: LoginMethod, deviceInfo: DeviceInfo,
    tokenPublisher: AnyPublisher<String, Never>, steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) -> RegularRemoteLoginFlowViewModel {
    return RegularRemoteLoginFlowViewModel(
      login: login,
      deviceRegistrationMethod: deviceRegistrationMethod,
      deviceInfo: deviceInfo,
      settingsManager: settingsManager,
      activityReporter: activityReporter,
      logger: rootLogger,
      tokenPublisher: tokenPublisher,
      deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      steps: steps,
      regularRemoteLoginStateMachineFactory: InjectedFactory(makeRegularRemoteLoginStateMachine),
      ssoRemoteLoginViewModelFactory: InjectedFactory(makeSSORemoteLoginViewModel),
      masterPasswordRemoteLoginFlowModelFactory: InjectedFactory(
        makeMasterPasswordRemoteLoginFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeRegularRemoteLoginStateMachine(
    login: Login, deviceRegistrationMethod: LoginMethod, deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil
  ) -> RegularRemoteLoginStateMachine {
    return RegularRemoteLoginStateMachine(
      login: login,
      deviceRegistrationMethod: deviceRegistrationMethod,
      deviceInfo: deviceInfo,
      ssoInfo: ssoInfo,
      appAPIClient: appAPIClient,
      sessionsContainer: sessionContainer,
      logger: rootLogger,
      cryptoEngineProvider: sessionCryptoEngineProvider
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeRemoteLoginFlowViewModel(
    type: RemoteLoginType, deviceInfo: DeviceInfo,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  ) -> RemoteLoginFlowViewModel {
    return RemoteLoginFlowViewModel(
      type: type,
      deviceInfo: deviceInfo,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      remoteLoginViewModelFactory: InjectedFactory(makeRegularRemoteLoginFlowViewModel),
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      deviceToDeviceLoginFlowViewModelFactory: InjectedFactory(makeDeviceTransferQRCodeFlowModel),
      deviceTransferLoginFlowModelFactory: InjectedFactory(makeDeviceTransferLoginFlowModel),
      tokenPublisher: tokenPublisher,
      deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
      remoteLoginStateMachineFactory: InjectedFactory(makeRemoteLoginStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeRemoteLoginStateMachine(
    type: RemoteLoginType, deviceInfo: DeviceInfo, ssoInfo: SSOInfo? = nil
  ) -> RemoteLoginStateMachine {
    return RemoteLoginStateMachine(
      type: type,
      deviceInfo: deviceInfo,
      ssoInfo: ssoInfo,
      apiclient: appAPIClient,
      sessionsContainer: sessionContainer,
      logger: rootLogger,
      cryptoEngineProvider: sessionCryptoEngineProvider
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSOLocalLoginViewModel(
    deviceAccessKey: String, ssoAuthenticationInfo: SSOAuthenticationInfo,
    completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
  ) -> SSOLocalLoginViewModel {
    return SSOLocalLoginViewModel(
      deviceAccessKey: deviceAccessKey,
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      ssoViewModelFactory: InjectedFactory(makeSSOViewModel),
      ssoLocalStateMachineFactory: InjectedFactory(makeSSOLocalStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSOLocalStateMachine(
    ssoAuthenticationInfo: SSOAuthenticationInfo, deviceAccessKey: String
  ) -> SSOLocalStateMachine {
    return SSOLocalStateMachine(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      deviceAccessKey: deviceAccessKey,
      apiClient: appAPIClient,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSORemoteLoginViewModel(
    ssoAuthenticationInfo: SSOAuthenticationInfo, deviceInfo: DeviceInfo,
    completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
  ) -> SSORemoteLoginViewModel {
    return SSORemoteLoginViewModel(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      deviceInfo: deviceInfo,
      ssoViewModelFactory: InjectedFactory(makeSSOViewModel),
      ssoRemoteStateMachineFactory: InjectedFactory(makeSSORemoteStateMachine),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSORemoteStateMachine(
    ssoAuthenticationInfo: SSOAuthenticationInfo, deviceInfo: DeviceInfo
  ) -> SSORemoteStateMachine {
    return SSORemoteStateMachine(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      deviceInfo: deviceInfo,
      apiClient: appAPIClient,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSOUnlockViewModel(
    login: Login, deviceAccessKey: String,
    completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
  ) -> SSOUnlockViewModel {
    return SSOUnlockViewModel(
      login: login,
      apiClient: appAPIClient,
      nitroClient: nitroClient,
      deviceAccessKey: deviceAccessKey,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      activityReporter: activityReporter,
      ssoLoginViewModelFactory: InjectedFactory(makeSSOLocalLoginViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSOViewModel(
    ssoAuthenticationInfo: SSOAuthenticationInfo, completion: @escaping Completion<SSOCompletion>
  ) -> SSOViewModel {
    return SSOViewModel(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      selfHostedSSOViewModelFactory: InjectedFactory(makeSelfHostedSSOViewModel),
      confidentialSSOViewModelFactory: InjectedFactory(makeConfidentialSSOViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSecurityChallengeFlowStateMachine(state: SecurityChallengeFlowStateMachine.State)
    -> SecurityChallengeFlowStateMachine
  {
    return SecurityChallengeFlowStateMachine(
      state: state,
      appAPIClient: appAPIClient,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSecurityChallengeTransferStateMachine(
    login: Login, cryptoProvider: DeviceTransferCryptoKeysProvider
  ) -> SecurityChallengeTransferStateMachine {
    return SecurityChallengeTransferStateMachine(
      login: login,
      apiClient: appAPIClient,
      cryptoProvider: cryptoProvider,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSelfHostedSSOViewModel(
    login: Login, authorisationURL: URL, completion: @escaping Completion<SSOCompletion>
  ) -> SelfHostedSSOViewModel {
    return SelfHostedSSOViewModel(
      login: login,
      authorisationURL: authorisationURL,
      logger: rootLogger,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeTOTPVerificationViewModel(
    accountVerificationService: AccountVerificationService, pushType: VerificationMethod.PushType?,
    completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> TOTPVerificationViewModel {
    return TOTPVerificationViewModel(
      accountVerificationService: accountVerificationService,
      appAPIClient: appAPIClient,
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      pushType: pushType,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeThirdPartyOTPLoginStateMachine(
    initialState: ThirdPartyOTPLoginStateMachine.State, login: Login, option: ThirdPartyOTPOption
  ) -> ThirdPartyOTPLoginStateMachine {
    return ThirdPartyOTPLoginStateMachine(
      initialState: initialState,
      login: login,
      option: option,
      apiClient: appAPIClient,
      logger: rootLogger
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeTokenVerificationViewModel(
    tokenPublisher: AnyPublisher<String, Never>?,
    accountVerificationService: AccountVerificationService, mode: Definition.Mode,
    completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
  ) -> TokenVerificationViewModel {
    return TokenVerificationViewModel(
      tokenPublisher: tokenPublisher,
      accountVerificationService: accountVerificationService,
      activityReporter: activityReporter,
      mode: mode,
      completion: completion
    )
  }

}

public typealias _AccountRecoveryKeyLoginFlowModelFactory = @MainActor (
  _ login: Login,
  _ accountType: CoreSession.AccountType,
  _ loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType,
  _ completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
) -> AccountRecoveryKeyLoginFlowModel

extension InjectedFactory where T == _AccountRecoveryKeyLoginFlowModelFactory {
  @MainActor
  public func make(
    login: Login, accountType: CoreSession.AccountType,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> AccountRecoveryKeyLoginFlowModel {
    return factory(
      login,
      accountType,
      loginType,
      completion
    )
  }
}

extension AccountRecoveryKeyLoginFlowModel {
  public typealias Factory = InjectedFactory<_AccountRecoveryKeyLoginFlowModelFactory>
}

public typealias _AccountRecoveryKeyLoginViewModelFactory = @MainActor (
  _ accountType: CoreSession.AccountType,
  _ generateMasterKey: @MainActor @escaping (_ recoveryKey: String) async -> Void
) -> AccountRecoveryKeyLoginViewModel

extension InjectedFactory where T == _AccountRecoveryKeyLoginViewModelFactory {
  @MainActor
  public func make(
    accountType: CoreSession.AccountType,
    generateMasterKey: @MainActor @escaping (_ recoveryKey: String) async -> Void
  ) -> AccountRecoveryKeyLoginViewModel {
    return factory(
      accountType,
      generateMasterKey
    )
  }
}

extension AccountRecoveryKeyLoginViewModel {
  public typealias Factory = InjectedFactory<_AccountRecoveryKeyLoginViewModelFactory>
}

public typealias _AccountVerificationFlowModelFactory = @MainActor (
  _ login: Login,
  _ mode: Definition.Mode,
  _ verificationMethod: VerificationMethod,
  _ deviceInfo: DeviceInfo,
  _ debugTokenPublisher: AnyPublisher<String, Never>?,
  _ completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
) -> AccountVerificationFlowModel

extension InjectedFactory where T == _AccountVerificationFlowModelFactory {
  @MainActor
  public func make(
    login: Login, mode: Definition.Mode, verificationMethod: VerificationMethod,
    deviceInfo: DeviceInfo, debugTokenPublisher: AnyPublisher<String, Never>? = nil,
    completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> AccountVerificationFlowModel {
    return factory(
      login,
      mode,
      verificationMethod,
      deviceInfo,
      debugTokenPublisher,
      completion
    )
  }
}

extension AccountVerificationFlowModel {
  public typealias Factory = InjectedFactory<_AccountVerificationFlowModelFactory>
}

public typealias _BiometryViewModelFactory = @MainActor (
  _ login: Login,
  _ biometryType: Biometry,
  _ manualLockOrigin: Bool,
  _ unlocker: UnlockSessionHandler,
  _ context: LoginUnlockContext,
  _ userSettings: UserSettings,
  _ completion: @escaping (_ isSuccess: Bool) -> Void
) -> BiometryViewModel

extension InjectedFactory where T == _BiometryViewModelFactory {
  @MainActor
  public func make(
    login: Login, biometryType: Biometry, manualLockOrigin: Bool = false,
    unlocker: UnlockSessionHandler, context: LoginUnlockContext, userSettings: UserSettings,
    completion: @escaping (_ isSuccess: Bool) -> Void
  ) -> BiometryViewModel {
    return factory(
      login,
      biometryType,
      manualLockOrigin,
      unlocker,
      context,
      userSettings,
      completion
    )
  }
}

extension BiometryViewModel {
  public typealias Factory = InjectedFactory<_BiometryViewModelFactory>
}

public typealias _ConfidentialSSOViewModelFactory = @MainActor (
  _ login: Login,
  _ completion: @escaping Completion<SSOCompletion>
) -> ConfidentialSSOViewModel

extension InjectedFactory where T == _ConfidentialSSOViewModelFactory {
  @MainActor
  public func make(login: Login, completion: @escaping Completion<SSOCompletion>)
    -> ConfidentialSSOViewModel
  {
    return factory(
      login,
      completion
    )
  }
}

extension ConfidentialSSOViewModel {
  public typealias Factory = InjectedFactory<_ConfidentialSSOViewModelFactory>
}

public typealias _DebugAccountListViewModelFactory = (
) -> DebugAccountListViewModel

extension InjectedFactory where T == _DebugAccountListViewModelFactory {

  public func make() -> DebugAccountListViewModel {
    return factory()
  }
}

extension DebugAccountListViewModel {
  public typealias Factory = InjectedFactory<_DebugAccountListViewModelFactory>
}

public typealias _DeviceTransferLoginFlowModelFactory = @MainActor (
  _ login: Login?,
  _ deviceInfo: DeviceInfo,
  _ completion: @MainActor @escaping (Result<DeviceTransferQRCodeFlowModel.Completion, Error>) ->
    Void
) -> DeviceTransferLoginFlowModel

extension InjectedFactory where T == _DeviceTransferLoginFlowModelFactory {
  @MainActor
  public func make(
    login: Login?, deviceInfo: DeviceInfo,
    completion: @MainActor @escaping (Result<DeviceTransferQRCodeFlowModel.Completion, Error>) ->
      Void
  ) -> DeviceTransferLoginFlowModel {
    return factory(
      login,
      deviceInfo,
      completion
    )
  }
}

extension DeviceTransferLoginFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferLoginFlowModelFactory>
}

public typealias _DeviceTransferLoginFlowStateMachineFactory = @MainActor (
  _ login: Login?,
  _ deviceInfo: DeviceInfo
) -> DeviceTransferLoginFlowStateMachine

extension InjectedFactory where T == _DeviceTransferLoginFlowStateMachineFactory {
  @MainActor
  public func make(login: Login?, deviceInfo: DeviceInfo) -> DeviceTransferLoginFlowStateMachine {
    return factory(
      login,
      deviceInfo
    )
  }
}

extension DeviceTransferLoginFlowStateMachine {
  public typealias Factory = InjectedFactory<_DeviceTransferLoginFlowStateMachineFactory>
}

public typealias _DeviceTransferOTPLoginViewModelFactory = @MainActor (
  _ initialState: ThirdPartyOTPLoginStateMachine.State,
  _ login: Login,
  _ option: ThirdPartyOTPOption,
  _ completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
) -> DeviceTransferOTPLoginViewModel

extension InjectedFactory where T == _DeviceTransferOTPLoginViewModelFactory {
  @MainActor
  public func make(
    initialState: ThirdPartyOTPLoginStateMachine.State, login: Login, option: ThirdPartyOTPOption,
    completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
  ) -> DeviceTransferOTPLoginViewModel {
    return factory(
      initialState,
      login,
      option,
      completion
    )
  }
}

extension DeviceTransferOTPLoginViewModel {
  public typealias Factory = InjectedFactory<_DeviceTransferOTPLoginViewModelFactory>
}

public typealias _DeviceTransferPassphraseViewModelFactory = @MainActor (
  _ initialState: PassphraseVerificationStateMachine.State,
  _ words: [String],
  _ transferId: String,
  _ secretBox: DeviceTransferSecretBox,
  _ completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
) -> DeviceTransferPassphraseViewModel

extension InjectedFactory where T == _DeviceTransferPassphraseViewModelFactory {
  @MainActor
  public func make(
    initialState: PassphraseVerificationStateMachine.State, words: [String], transferId: String,
    secretBox: DeviceTransferSecretBox,
    completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
  ) -> DeviceTransferPassphraseViewModel {
    return factory(
      initialState,
      words,
      transferId,
      secretBox,
      completion
    )
  }
}

extension DeviceTransferPassphraseViewModel {
  public typealias Factory = InjectedFactory<_DeviceTransferPassphraseViewModelFactory>
}

public typealias _DeviceTransferQRCodeFlowModelFactory = @MainActor (
  _ login: Login?,
  _ state: QRCodeFlowStateMachine.State,
  _ completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
) -> DeviceTransferQRCodeFlowModel

extension InjectedFactory where T == _DeviceTransferQRCodeFlowModelFactory {
  @MainActor
  public func make(
    login: Login?, state: QRCodeFlowStateMachine.State,
    completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQRCodeFlowModel {
    return factory(
      login,
      state,
      completion
    )
  }
}

extension DeviceTransferQRCodeFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferQRCodeFlowModelFactory>
}

public typealias _DeviceTransferQrCodeViewModelFactory = @MainActor (
  _ login: Login?,
  _ state: QRCodeScanStateMachine.State,
  _ completion: @escaping (DeviceTransferCompletion) -> Void
) -> DeviceTransferQrCodeViewModel

extension InjectedFactory where T == _DeviceTransferQrCodeViewModelFactory {
  @MainActor
  public func make(
    login: Login?, state: QRCodeScanStateMachine.State,
    completion: @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQrCodeViewModel {
    return factory(
      login,
      state,
      completion
    )
  }
}

extension DeviceTransferQrCodeViewModel {
  public typealias Factory = InjectedFactory<_DeviceTransferQrCodeViewModelFactory>
}

public typealias _DeviceTransferRecoveryFlowModelFactory = @MainActor (
  _ accountRecoveryInfo: AccountRecoveryInfo,
  _ deviceInfo: DeviceInfo,
  _ completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
) -> DeviceTransferRecoveryFlowModel

extension InjectedFactory where T == _DeviceTransferRecoveryFlowModelFactory {
  @MainActor
  public func make(
    accountRecoveryInfo: AccountRecoveryInfo, deviceInfo: DeviceInfo,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> DeviceTransferRecoveryFlowModel {
    return factory(
      accountRecoveryInfo,
      deviceInfo,
      completion
    )
  }
}

extension DeviceTransferRecoveryFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferRecoveryFlowModelFactory>
}

public typealias _DeviceTransferSecurityChallengeFlowModelFactory = @MainActor (
  _ login: Login,
  _ completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
) -> DeviceTransferSecurityChallengeFlowModel

extension InjectedFactory where T == _DeviceTransferSecurityChallengeFlowModelFactory {
  @MainActor
  public func make(
    login: Login, completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferSecurityChallengeFlowModel {
    return factory(
      login,
      completion
    )
  }
}

extension DeviceTransferSecurityChallengeFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferSecurityChallengeFlowModelFactory>
}

public typealias _DeviceTransferSecurityChallengeIntroViewModelFactory = @MainActor (
  _ login: Login,
  _ completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
) -> DeviceTransferSecurityChallengeIntroViewModel

extension InjectedFactory where T == _DeviceTransferSecurityChallengeIntroViewModelFactory {
  @MainActor
  public func make(
    login: Login,
    completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
  ) -> DeviceTransferSecurityChallengeIntroViewModel {
    return factory(
      login,
      completion
    )
  }
}

extension DeviceTransferSecurityChallengeIntroViewModel {
  public typealias Factory = InjectedFactory<_DeviceTransferSecurityChallengeIntroViewModelFactory>
}

public typealias _DeviceUnlinkingFlowViewModelFactory = @MainActor (
  _ deviceUnlinker: DeviceUnlinker,
  _ login: Login,
  _ session: RemoteLoginSession,
  _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
  _ sessionActivityReporterProvider: SessionActivityReporterProvider,
  _ completion: @MainActor @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
) -> DeviceUnlinkingFlowViewModel

extension InjectedFactory where T == _DeviceUnlinkingFlowViewModelFactory {
  @MainActor
  public func make(
    deviceUnlinker: DeviceUnlinker, login: Login, session: RemoteLoginSession,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    completion: @MainActor @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
  ) -> DeviceUnlinkingFlowViewModel {
    return factory(
      deviceUnlinker,
      login,
      session,
      purchasePlanFlowProvider,
      sessionActivityReporterProvider,
      completion
    )
  }
}

extension DeviceUnlinkingFlowViewModel {
  public typealias Factory = InjectedFactory<_DeviceUnlinkingFlowViewModelFactory>
}

public typealias _DeviceUnlinkingFlowViewModelSecondFactory = @MainActor (
  _ deviceUnlinker: DeviceUnlinker,
  _ login: Login,
  _ authentication: ServerAuthentication,
  _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
  _ completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
) -> DeviceUnlinkingFlowViewModel

extension InjectedFactory where T == _DeviceUnlinkingFlowViewModelSecondFactory {
  @MainActor
  public func make(
    deviceUnlinker: DeviceUnlinker, login: Login, authentication: ServerAuthentication,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
  ) -> DeviceUnlinkingFlowViewModel {
    return factory(
      deviceUnlinker,
      login,
      authentication,
      purchasePlanFlowProvider,
      completion
    )
  }
}

extension DeviceUnlinkingFlowViewModel {
  public typealias SecondFactory = InjectedFactory<_DeviceUnlinkingFlowViewModelSecondFactory>
}

public typealias _LocalLoginFlowViewModelFactory = @MainActor (
  _ localLoginHandler: LocalLoginHandler,
  _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
  _ userSettings: UserSettings,
  _ email: String,
  _ context: LocalLoginFlowContext,
  _ completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
) -> LocalLoginFlowViewModel

extension InjectedFactory where T == _LocalLoginFlowViewModelFactory {
  @MainActor
  public func make(
    localLoginHandler: LocalLoginHandler,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings,
    email: String, context: LocalLoginFlowContext,
    completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
  ) -> LocalLoginFlowViewModel {
    return factory(
      localLoginHandler,
      resetMasterPasswordService,
      userSettings,
      email,
      context,
      completion
    )
  }
}

extension LocalLoginFlowViewModel {
  public typealias Factory = InjectedFactory<_LocalLoginFlowViewModelFactory>
}

public typealias _LocalLoginUnlockViewModelFactory = @MainActor (
  _ login: Login,
  _ accountType: CoreSession.AccountType,
  _ unlockType: UnlockType,
  _ secureLockMode: SecureLockMode,
  _ unlocker: UnlockSessionHandler,
  _ context: LoginUnlockContext,
  _ userSettings: UserSettings,
  _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
  _ localLoginHandler: LocalLoginHandler,
  _ completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
) -> LocalLoginUnlockViewModel

extension InjectedFactory where T == _LocalLoginUnlockViewModelFactory {
  @MainActor
  public func make(
    login: Login, accountType: CoreSession.AccountType, unlockType: UnlockType,
    secureLockMode: SecureLockMode, unlocker: UnlockSessionHandler, context: LoginUnlockContext,
    userSettings: UserSettings, resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    localLoginHandler: LocalLoginHandler,
    completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
  ) -> LocalLoginUnlockViewModel {
    return factory(
      login,
      accountType,
      unlockType,
      secureLockMode,
      unlocker,
      context,
      userSettings,
      resetMasterPasswordService,
      localLoginHandler,
      completion
    )
  }
}

extension LocalLoginUnlockViewModel {
  public typealias Factory = InjectedFactory<_LocalLoginUnlockViewModelFactory>
}

public typealias _LockPinCodeAndBiometryViewModelFactory = @MainActor (
  _ login: Login,
  _ accountType: CoreSession.AccountType,
  _ pinCodeLock: SecureLockMode.PinCodeLock,
  _ biometryType: Biometry?,
  _ context: LoginUnlockContext,
  _ unlocker: UnlockSessionHandler,
  _ completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void
) -> LockPinCodeAndBiometryViewModel

extension InjectedFactory where T == _LockPinCodeAndBiometryViewModelFactory {
  @MainActor
  public func make(
    login: Login, accountType: CoreSession.AccountType, pinCodeLock: SecureLockMode.PinCodeLock,
    biometryType: Biometry? = nil, context: LoginUnlockContext, unlocker: UnlockSessionHandler,
    completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void
  ) -> LockPinCodeAndBiometryViewModel {
    return factory(
      login,
      accountType,
      pinCodeLock,
      biometryType,
      context,
      unlocker,
      completion
    )
  }
}

extension LockPinCodeAndBiometryViewModel {
  public typealias Factory = InjectedFactory<_LockPinCodeAndBiometryViewModelFactory>
}

public typealias _LoginFlowViewModelFactory = @MainActor (
  _ login: Login?,
  _ deviceId: String?,
  _ loginHandler: LoginHandler,
  _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
  _ sessionActivityReporterProvider: SessionActivityReporterProvider,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ versionValidityAlertProvider: AlertContent,
  _ context: LocalLoginFlowContext,
  _ completion: @escaping (LoginFlowViewModel.Completion) -> Void
) -> LoginFlowViewModel

extension InjectedFactory where T == _LoginFlowViewModelFactory {
  @MainActor
  public func make(
    login: Login?, deviceId: String?, loginHandler: LoginHandler,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>, versionValidityAlertProvider: AlertContent,
    context: LocalLoginFlowContext, completion: @escaping (LoginFlowViewModel.Completion) -> Void
  ) -> LoginFlowViewModel {
    return factory(
      login,
      deviceId,
      loginHandler,
      purchasePlanFlowProvider,
      sessionActivityReporterProvider,
      tokenPublisher,
      versionValidityAlertProvider,
      context,
      completion
    )
  }
}

extension LoginFlowViewModel {
  public typealias Factory = InjectedFactory<_LoginFlowViewModelFactory>
}

public typealias _LoginViewModelFactory = @MainActor (
  _ email: String?,
  _ loginHandler: LoginHandler,
  _ staticErrorPublisher: AnyPublisher<Error?, Never>,
  _ versionValidityAlertProvider: AlertContent,
  _ completion: @escaping (LoginHandler.LoginResult?) -> Void
) -> LoginViewModel

extension InjectedFactory where T == _LoginViewModelFactory {
  @MainActor
  public func make(
    email: String?, loginHandler: LoginHandler, staticErrorPublisher: AnyPublisher<Error?, Never>,
    versionValidityAlertProvider: AlertContent,
    completion: @escaping (LoginHandler.LoginResult?) -> Void
  ) -> LoginViewModel {
    return factory(
      email,
      loginHandler,
      staticErrorPublisher,
      versionValidityAlertProvider,
      completion
    )
  }
}

extension LoginViewModel {
  public typealias Factory = InjectedFactory<_LoginViewModelFactory>
}

public typealias _MasterPasswordFlowRemoteStateMachineFactory = @MainActor (
  _ state: MasterPasswordFlowRemoteStateMachine.State,
  _ verificationMethod: VerificationMethod,
  _ deviceInfo: DeviceInfo,
  _ login: Login
) -> MasterPasswordFlowRemoteStateMachine

extension InjectedFactory where T == _MasterPasswordFlowRemoteStateMachineFactory {
  @MainActor
  public func make(
    state: MasterPasswordFlowRemoteStateMachine.State, verificationMethod: VerificationMethod,
    deviceInfo: DeviceInfo, login: Login
  ) -> MasterPasswordFlowRemoteStateMachine {
    return factory(
      state,
      verificationMethod,
      deviceInfo,
      login
    )
  }
}

extension MasterPasswordFlowRemoteStateMachine {
  public typealias Factory = InjectedFactory<_MasterPasswordFlowRemoteStateMachineFactory>
}

public typealias _MasterPasswordInputRemoteViewModelFactory = @MainActor (
  _ state: MasterPasswordRemoteStateMachine.State,
  _ login: Login,
  _ data: DeviceRegistrationData,
  _ completion: @escaping (RemoteLoginSession) -> Void
) -> MasterPasswordInputRemoteViewModel

extension InjectedFactory where T == _MasterPasswordInputRemoteViewModelFactory {
  @MainActor
  public func make(
    state: MasterPasswordRemoteStateMachine.State, login: Login, data: DeviceRegistrationData,
    completion: @escaping (RemoteLoginSession) -> Void
  ) -> MasterPasswordInputRemoteViewModel {
    return factory(
      state,
      login,
      data,
      completion
    )
  }
}

extension MasterPasswordInputRemoteViewModel {
  public typealias Factory = InjectedFactory<_MasterPasswordInputRemoteViewModelFactory>
}

public typealias _MasterPasswordLocalLoginStateMachineFactory = @MainActor (
  _ login: Login,
  _ unlocker: UnlockSessionHandler,
  _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
  _ loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
) -> MasterPasswordLocalLoginStateMachine

extension InjectedFactory where T == _MasterPasswordLocalLoginStateMachineFactory {
  @MainActor
  public func make(
    login: Login, unlocker: UnlockSessionHandler,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    loginType: AccountRecoveryKeyLoginFlowStateMachine.LoginType
  ) -> MasterPasswordLocalLoginStateMachine {
    return factory(
      login,
      unlocker,
      resetMasterPasswordService,
      loginType
    )
  }
}

extension MasterPasswordLocalLoginStateMachine {
  public typealias Factory = InjectedFactory<_MasterPasswordLocalLoginStateMachineFactory>
}

public typealias _MasterPasswordLocalViewModelFactory = @MainActor (
  _ login: Login,
  _ biometry: Biometry?,
  _ user: AccountRecoveryKeyLoginFlowStateMachine.User,
  _ unlocker: UnlockSessionHandler,
  _ context: LoginUnlockContext,
  _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
  _ userSettings: UserSettings,
  _ completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
) -> MasterPasswordLocalViewModel

extension InjectedFactory where T == _MasterPasswordLocalViewModelFactory {
  @MainActor
  public func make(
    login: Login, biometry: Biometry?, user: AccountRecoveryKeyLoginFlowStateMachine.User,
    unlocker: UnlockSessionHandler, context: LoginUnlockContext,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings,
    completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
  ) -> MasterPasswordLocalViewModel {
    return factory(
      login,
      biometry,
      user,
      unlocker,
      context,
      resetMasterPasswordService,
      userSettings,
      completion
    )
  }
}

extension MasterPasswordLocalViewModel {
  public typealias Factory = InjectedFactory<_MasterPasswordLocalViewModelFactory>
}

public typealias _MasterPasswordRemoteLoginFlowModelFactory = @MainActor (
  _ login: Login,
  _ deviceInfo: DeviceInfo,
  _ verificationMethod: VerificationMethod,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
    -> Void
) -> MasterPasswordRemoteLoginFlowModel

extension InjectedFactory where T == _MasterPasswordRemoteLoginFlowModelFactory {
  @MainActor
  public func make(
    login: Login, deviceInfo: DeviceInfo, verificationMethod: VerificationMethod,
    tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) -> MasterPasswordRemoteLoginFlowModel {
    return factory(
      login,
      deviceInfo,
      verificationMethod,
      tokenPublisher,
      completion
    )
  }
}

extension MasterPasswordRemoteLoginFlowModel {
  public typealias Factory = InjectedFactory<_MasterPasswordRemoteLoginFlowModelFactory>
}

public typealias _MasterPasswordRemoteStateMachineFactory = @MainActor (
  _ state: MasterPasswordRemoteStateMachine.State,
  _ login: Login,
  _ data: DeviceRegistrationData
) -> MasterPasswordRemoteStateMachine

extension InjectedFactory where T == _MasterPasswordRemoteStateMachineFactory {
  @MainActor
  public func make(
    state: MasterPasswordRemoteStateMachine.State, login: Login, data: DeviceRegistrationData
  ) -> MasterPasswordRemoteStateMachine {
    return factory(
      state,
      login,
      data
    )
  }
}

extension MasterPasswordRemoteStateMachine {
  public typealias Factory = InjectedFactory<_MasterPasswordRemoteStateMachineFactory>
}

public typealias _NewMasterPasswordViewModelFactory = (
  _ mode: NewMasterPasswordViewModel.Mode,
  _ masterPassword: String?,
  _ login: Login?,
  _ step: NewMasterPasswordViewModel.Step,
  _ completion: @escaping (NewMasterPasswordViewModel.Completion) -> Void
) -> NewMasterPasswordViewModel

extension InjectedFactory where T == _NewMasterPasswordViewModelFactory {

  public func make(
    mode: NewMasterPasswordViewModel.Mode, masterPassword: String? = "", login: Login? = nil,
    step: NewMasterPasswordViewModel.Step = .masterPasswordCreation,
    completion: @escaping (NewMasterPasswordViewModel.Completion) -> Void
  ) -> NewMasterPasswordViewModel {
    return factory(
      mode,
      masterPassword,
      login,
      step,
      completion
    )
  }
}

extension NewMasterPasswordViewModel {
  public typealias Factory = InjectedFactory<_NewMasterPasswordViewModelFactory>
}

public typealias _PassphraseVerificationStateMachineFactory = @MainActor (
  _ initialState: PassphraseVerificationStateMachine.State,
  _ transferId: String,
  _ secretBox: DeviceTransferSecretBox
) -> PassphraseVerificationStateMachine

extension InjectedFactory where T == _PassphraseVerificationStateMachineFactory {
  @MainActor
  public func make(
    initialState: PassphraseVerificationStateMachine.State, transferId: String,
    secretBox: DeviceTransferSecretBox
  ) -> PassphraseVerificationStateMachine {
    return factory(
      initialState,
      transferId,
      secretBox
    )
  }
}

extension PassphraseVerificationStateMachine {
  public typealias Factory = InjectedFactory<_PassphraseVerificationStateMachineFactory>
}

public typealias _PasswordLessRecoveryViewModelFactory = @MainActor (
  _ login: Login,
  _ recoverFromFailure: Bool,
  _ completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void
) -> PasswordLessRecoveryViewModel

extension InjectedFactory where T == _PasswordLessRecoveryViewModelFactory {
  @MainActor
  public func make(
    login: Login, recoverFromFailure: Bool,
    completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void
  ) -> PasswordLessRecoveryViewModel {
    return factory(
      login,
      recoverFromFailure,
      completion
    )
  }
}

extension PasswordLessRecoveryViewModel {
  public typealias Factory = InjectedFactory<_PasswordLessRecoveryViewModelFactory>
}

public typealias _QRCodeFlowStateMachineFactory = @MainActor (
  _ state: QRCodeFlowStateMachine.State
) -> QRCodeFlowStateMachine

extension InjectedFactory where T == _QRCodeFlowStateMachineFactory {
  @MainActor
  public func make(state: QRCodeFlowStateMachine.State) -> QRCodeFlowStateMachine {
    return factory(
      state
    )
  }
}

extension QRCodeFlowStateMachine {
  public typealias Factory = InjectedFactory<_QRCodeFlowStateMachineFactory>
}

public typealias _QRCodeScanStateMachineFactory = @MainActor (
  _ login: Login?,
  _ state: QRCodeScanStateMachine.State,
  _ qrDeviceTransferCrypto: ECDHProtocol
) -> QRCodeScanStateMachine

extension InjectedFactory where T == _QRCodeScanStateMachineFactory {
  @MainActor
  public func make(
    login: Login?, state: QRCodeScanStateMachine.State, qrDeviceTransferCrypto: ECDHProtocol
  ) -> QRCodeScanStateMachine {
    return factory(
      login,
      state,
      qrDeviceTransferCrypto
    )
  }
}

extension QRCodeScanStateMachine {
  public typealias Factory = InjectedFactory<_QRCodeScanStateMachineFactory>
}

public typealias _RegularRemoteLoginFlowViewModelFactory = @MainActor (
  _ login: Login,
  _ deviceRegistrationMethod: LoginMethod,
  _ deviceInfo: DeviceInfo,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ steps: [RegularRemoteLoginFlowViewModel.Step],
  _ completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
    -> Void
) -> RegularRemoteLoginFlowViewModel

extension InjectedFactory where T == _RegularRemoteLoginFlowViewModelFactory {
  @MainActor
  public func make(
    login: Login, deviceRegistrationMethod: LoginMethod, deviceInfo: DeviceInfo,
    tokenPublisher: AnyPublisher<String, Never>, steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) -> RegularRemoteLoginFlowViewModel {
    return factory(
      login,
      deviceRegistrationMethod,
      deviceInfo,
      tokenPublisher,
      steps,
      completion
    )
  }
}

extension RegularRemoteLoginFlowViewModel {
  public typealias Factory = InjectedFactory<_RegularRemoteLoginFlowViewModelFactory>
}

public typealias _RegularRemoteLoginStateMachineFactory = @MainActor (
  _ login: Login,
  _ deviceRegistrationMethod: LoginMethod,
  _ deviceInfo: DeviceInfo,
  _ ssoInfo: SSOInfo?
) -> RegularRemoteLoginStateMachine

extension InjectedFactory where T == _RegularRemoteLoginStateMachineFactory {
  @MainActor
  public func make(
    login: Login, deviceRegistrationMethod: LoginMethod, deviceInfo: DeviceInfo,
    ssoInfo: SSOInfo? = nil
  ) -> RegularRemoteLoginStateMachine {
    return factory(
      login,
      deviceRegistrationMethod,
      deviceInfo,
      ssoInfo
    )
  }
}

extension RegularRemoteLoginStateMachine {
  public typealias Factory = InjectedFactory<_RegularRemoteLoginStateMachineFactory>
}

public typealias _RemoteLoginFlowViewModelFactory = @MainActor (
  _ type: RemoteLoginType,
  _ deviceInfo: DeviceInfo,
  _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
  _ sessionActivityReporterProvider: SessionActivityReporterProvider,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
) -> RemoteLoginFlowViewModel

extension InjectedFactory where T == _RemoteLoginFlowViewModelFactory {
  @MainActor
  public func make(
    type: RemoteLoginType, deviceInfo: DeviceInfo,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  ) -> RemoteLoginFlowViewModel {
    return factory(
      type,
      deviceInfo,
      purchasePlanFlowProvider,
      sessionActivityReporterProvider,
      tokenPublisher,
      completion
    )
  }
}

extension RemoteLoginFlowViewModel {
  public typealias Factory = InjectedFactory<_RemoteLoginFlowViewModelFactory>
}

public typealias _RemoteLoginStateMachineFactory = @MainActor (
  _ type: RemoteLoginType,
  _ deviceInfo: DeviceInfo,
  _ ssoInfo: SSOInfo?
) -> RemoteLoginStateMachine

extension InjectedFactory where T == _RemoteLoginStateMachineFactory {
  @MainActor
  public func make(type: RemoteLoginType, deviceInfo: DeviceInfo, ssoInfo: SSOInfo? = nil)
    -> RemoteLoginStateMachine
  {
    return factory(
      type,
      deviceInfo,
      ssoInfo
    )
  }
}

extension RemoteLoginStateMachine {
  public typealias Factory = InjectedFactory<_RemoteLoginStateMachineFactory>
}

public typealias _SSOLocalLoginViewModelFactory = @MainActor (
  _ deviceAccessKey: String,
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
) -> SSOLocalLoginViewModel

extension InjectedFactory where T == _SSOLocalLoginViewModelFactory {
  @MainActor
  public func make(
    deviceAccessKey: String, ssoAuthenticationInfo: SSOAuthenticationInfo,
    completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
  ) -> SSOLocalLoginViewModel {
    return factory(
      deviceAccessKey,
      ssoAuthenticationInfo,
      completion
    )
  }
}

extension SSOLocalLoginViewModel {
  public typealias Factory = InjectedFactory<_SSOLocalLoginViewModelFactory>
}

public typealias _SSOLocalStateMachineFactory = @MainActor (
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ deviceAccessKey: String
) -> SSOLocalStateMachine

extension InjectedFactory where T == _SSOLocalStateMachineFactory {
  @MainActor
  public func make(ssoAuthenticationInfo: SSOAuthenticationInfo, deviceAccessKey: String)
    -> SSOLocalStateMachine
  {
    return factory(
      ssoAuthenticationInfo,
      deviceAccessKey
    )
  }
}

extension SSOLocalStateMachine {
  public typealias Factory = InjectedFactory<_SSOLocalStateMachineFactory>
}

public typealias _SSORemoteLoginViewModelFactory = @MainActor (
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ deviceInfo: DeviceInfo,
  _ completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
) -> SSORemoteLoginViewModel

extension InjectedFactory where T == _SSORemoteLoginViewModelFactory {
  @MainActor
  public func make(
    ssoAuthenticationInfo: SSOAuthenticationInfo, deviceInfo: DeviceInfo,
    completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
  ) -> SSORemoteLoginViewModel {
    return factory(
      ssoAuthenticationInfo,
      deviceInfo,
      completion
    )
  }
}

extension SSORemoteLoginViewModel {
  public typealias Factory = InjectedFactory<_SSORemoteLoginViewModelFactory>
}

public typealias _SSORemoteStateMachineFactory = @MainActor (
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ deviceInfo: DeviceInfo
) -> SSORemoteStateMachine

extension InjectedFactory where T == _SSORemoteStateMachineFactory {
  @MainActor
  public func make(ssoAuthenticationInfo: SSOAuthenticationInfo, deviceInfo: DeviceInfo)
    -> SSORemoteStateMachine
  {
    return factory(
      ssoAuthenticationInfo,
      deviceInfo
    )
  }
}

extension SSORemoteStateMachine {
  public typealias Factory = InjectedFactory<_SSORemoteStateMachineFactory>
}

public typealias _SSOUnlockViewModelFactory = @MainActor (
  _ login: Login,
  _ deviceAccessKey: String,
  _ completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
) -> SSOUnlockViewModel

extension InjectedFactory where T == _SSOUnlockViewModelFactory {
  @MainActor
  public func make(
    login: Login, deviceAccessKey: String,
    completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
  ) -> SSOUnlockViewModel {
    return factory(
      login,
      deviceAccessKey,
      completion
    )
  }
}

extension SSOUnlockViewModel {
  public typealias Factory = InjectedFactory<_SSOUnlockViewModelFactory>
}

public typealias _SSOViewModelFactory = @MainActor (
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ completion: @escaping Completion<SSOCompletion>
) -> SSOViewModel

extension InjectedFactory where T == _SSOViewModelFactory {
  @MainActor
  public func make(
    ssoAuthenticationInfo: SSOAuthenticationInfo, completion: @escaping Completion<SSOCompletion>
  ) -> SSOViewModel {
    return factory(
      ssoAuthenticationInfo,
      completion
    )
  }
}

extension SSOViewModel {
  public typealias Factory = InjectedFactory<_SSOViewModelFactory>
}

public typealias _SecurityChallengeFlowStateMachineFactory = @MainActor (
  _ state: SecurityChallengeFlowStateMachine.State
) -> SecurityChallengeFlowStateMachine

extension InjectedFactory where T == _SecurityChallengeFlowStateMachineFactory {
  @MainActor
  public func make(state: SecurityChallengeFlowStateMachine.State)
    -> SecurityChallengeFlowStateMachine
  {
    return factory(
      state
    )
  }
}

extension SecurityChallengeFlowStateMachine {
  public typealias Factory = InjectedFactory<_SecurityChallengeFlowStateMachineFactory>
}

public typealias _SecurityChallengeTransferStateMachineFactory = @MainActor (
  _ login: Login,
  _ cryptoProvider: DeviceTransferCryptoKeysProvider
) -> SecurityChallengeTransferStateMachine

extension InjectedFactory where T == _SecurityChallengeTransferStateMachineFactory {
  @MainActor
  public func make(login: Login, cryptoProvider: DeviceTransferCryptoKeysProvider)
    -> SecurityChallengeTransferStateMachine
  {
    return factory(
      login,
      cryptoProvider
    )
  }
}

extension SecurityChallengeTransferStateMachine {
  public typealias Factory = InjectedFactory<_SecurityChallengeTransferStateMachineFactory>
}

public typealias _SelfHostedSSOViewModelFactory = @MainActor (
  _ login: Login,
  _ authorisationURL: URL,
  _ completion: @escaping Completion<SSOCompletion>
) -> SelfHostedSSOViewModel

extension InjectedFactory where T == _SelfHostedSSOViewModelFactory {
  @MainActor
  public func make(
    login: Login, authorisationURL: URL, completion: @escaping Completion<SSOCompletion>
  ) -> SelfHostedSSOViewModel {
    return factory(
      login,
      authorisationURL,
      completion
    )
  }
}

extension SelfHostedSSOViewModel {
  public typealias Factory = InjectedFactory<_SelfHostedSSOViewModelFactory>
}

public typealias _TOTPVerificationViewModelFactory = @MainActor (
  _ accountVerificationService: AccountVerificationService,
  _ pushType: VerificationMethod.PushType?,
  _ completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
) -> TOTPVerificationViewModel

extension InjectedFactory where T == _TOTPVerificationViewModelFactory {
  @MainActor
  public func make(
    accountVerificationService: AccountVerificationService, pushType: VerificationMethod.PushType?,
    completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> TOTPVerificationViewModel {
    return factory(
      accountVerificationService,
      pushType,
      completion
    )
  }
}

extension TOTPVerificationViewModel {
  public typealias Factory = InjectedFactory<_TOTPVerificationViewModelFactory>
}

public typealias _ThirdPartyOTPLoginStateMachineFactory = @MainActor (
  _ initialState: ThirdPartyOTPLoginStateMachine.State,
  _ login: Login,
  _ option: ThirdPartyOTPOption
) -> ThirdPartyOTPLoginStateMachine

extension InjectedFactory where T == _ThirdPartyOTPLoginStateMachineFactory {
  @MainActor
  public func make(
    initialState: ThirdPartyOTPLoginStateMachine.State, login: Login, option: ThirdPartyOTPOption
  ) -> ThirdPartyOTPLoginStateMachine {
    return factory(
      initialState,
      login,
      option
    )
  }
}

extension ThirdPartyOTPLoginStateMachine {
  public typealias Factory = InjectedFactory<_ThirdPartyOTPLoginStateMachineFactory>
}

public typealias _TokenVerificationViewModelFactory = @MainActor (
  _ tokenPublisher: AnyPublisher<String, Never>?,
  _ accountVerificationService: AccountVerificationService,
  _ mode: Definition.Mode,
  _ completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
) -> TokenVerificationViewModel

extension InjectedFactory where T == _TokenVerificationViewModelFactory {
  @MainActor
  public func make(
    tokenPublisher: AnyPublisher<String, Never>?,
    accountVerificationService: AccountVerificationService, mode: Definition.Mode,
    completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
  ) -> TokenVerificationViewModel {
    return factory(
      tokenPublisher,
      accountVerificationService,
      mode,
      completion
    )
  }
}

extension TokenVerificationViewModel {
  public typealias Factory = InjectedFactory<_TokenVerificationViewModelFactory>
}
