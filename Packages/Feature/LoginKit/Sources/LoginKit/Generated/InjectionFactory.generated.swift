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
#if canImport(CoreTypes)
  import CoreTypes
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
#if canImport(UserTrackingFoundation)
  import UserTrackingFoundation
#endif

public protocol LoginKitServicesInjecting {}

extension LoginKitServicesContainer {
  @MainActor
  public func makeAccountRecoveryKeyLoginFlowModel(
    login: Login, stateMachine: AccountRecoveryKeyLoginFlowStateMachine,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> AccountRecoveryKeyLoginFlowModel {
    return AccountRecoveryKeyLoginFlowModel(
      login: login,
      stateMachine: stateMachine,
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
    login: Login, mode: Definition.Mode, stateMachine: AccountVerificationStateMachine,
    debugTokenPublisher: AnyPublisher<String, Never>? = nil,
    completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> AccountVerificationFlowModel {
    return AccountVerificationFlowModel(
      login: login,
      mode: mode,
      stateMachine: stateMachine,
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
    context: LoginUnlockContext, biometryUnlockStateMachine: BiometryUnlockStateMachine,
    completion: @escaping (Session?) -> Void
  ) -> BiometryViewModel {
    return BiometryViewModel(
      login: login,
      biometryType: biometryType,
      manualLockOrigin: manualLockOrigin,
      context: context,
      biometryUnlockStateMachine: biometryUnlockStateMachine,
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
    login: Login?, deviceInfo: DeviceInfo, stateMachine: DeviceTransferLoginFlowStateMachine,
    completion: @MainActor @escaping (Result<DeviceTransferQRCodeFlowModel.Completion, Error>) ->
      Void
  ) -> DeviceTransferLoginFlowModel {
    return DeviceTransferLoginFlowModel(
      login: login,
      deviceInfo: deviceInfo,
      stateMachine: stateMachine,
      activityReporter: activityReporter,
      totpFactory: InjectedFactory(makeDeviceTransferOTPLoginViewModel),
      deviceToDeviceLoginFlowViewModelFactory: InjectedFactory(makeDeviceTransferQRCodeFlowModel),
      securityChallengeFlowModelFactory: InjectedFactory(
        makeDeviceTransferSecurityChallengeFlowModel),
      deviceTransferRecoveryFlowModelFactory: InjectedFactory(makeDeviceTransferRecoveryFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferOTPLoginViewModel(
    stateMachine: ThirdPartyOTPLoginStateMachine, login: Login, option: ThirdPartyOTPOption,
    completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
  ) -> DeviceTransferOTPLoginViewModel {
    return DeviceTransferOTPLoginViewModel(
      stateMachine: stateMachine,
      login: login,
      option: option,
      activityReporter: activityReporter,
      appAPIClient: appAPIClient,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferPassphraseViewModel(
    stateMachine: PassphraseVerificationStateMachine, words: [String],
    completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
  ) -> DeviceTransferPassphraseViewModel {
    return DeviceTransferPassphraseViewModel(
      stateMachine: stateMachine,
      words: words,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferQRCodeFlowModel(
    login: Login?, stateMachine: QRCodeFlowStateMachine,
    completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQRCodeFlowModel {
    return DeviceTransferQRCodeFlowModel(
      login: login,
      stateMachine: stateMachine,
      qrCodeLoginViewModelFactory: InjectedFactory(makeDeviceTransferQrCodeViewModel),
      accountRecoveryKeyLoginFlowModelFactory: InjectedFactory(
        makeAccountRecoveryKeyLoginFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferQrCodeViewModel(
    login: Login?, stateMachine: QRCodeScanStateMachine,
    completion: @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQrCodeViewModel {
    return DeviceTransferQrCodeViewModel(
      login: login,
      stateMachine: stateMachine,
      activityReporter: activityReporter,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferRecoveryFlowModel(
    login: Login, stateMachine: DeviceTransferRecoveryFlowStateMachine,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> DeviceTransferRecoveryFlowModel {
    return DeviceTransferRecoveryFlowModel(
      login: login,
      stateMachine: stateMachine,
      recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferSecurityChallengeFlowModel(
    login: Login, stateMachine: SecurityChallengeFlowStateMachine,
    completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferSecurityChallengeFlowModel {
    return DeviceTransferSecurityChallengeFlowModel(
      login: login,
      stateMachine: stateMachine,
      securityChallengeIntroViewModelFactory: InjectedFactory(
        makeDeviceTransferSecurityChallengeIntroViewModel),
      passphraseViewModelFactory: InjectedFactory(makeDeviceTransferPassphraseViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeDeviceTransferSecurityChallengeIntroViewModel(
    login: Login, stateMachine: SecurityChallengeTransferStateMachine,
    completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
  ) -> DeviceTransferSecurityChallengeIntroViewModel {
    return DeviceTransferSecurityChallengeIntroViewModel(
      login: login,
      stateMachine: stateMachine,
      apiClient: appAPIClient,
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

  public func makeForgotMasterPasswordSheetModel(
    login: String, hasMasterPasswordReset: Bool, didTapResetMP: (() -> Void)? = nil,
    didTapAccountRecovery: (() -> Void)? = nil
  ) -> ForgotMasterPasswordSheetModel {
    return ForgotMasterPasswordSheetModel(
      login: login,
      activityReporter: activityReporter,
      hasMasterPasswordReset: hasMasterPasswordReset,
      didTapResetMP: didTapResetMP,
      didTapAccountRecovery: didTapAccountRecovery
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLocalLoginFlowViewModel(
    stateMachine: LocalLoginStateMachine,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings,
    login: Login, context: UnlockOriginProcess,
    completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
  ) -> LocalLoginFlowViewModel {
    return LocalLoginFlowViewModel(
      stateMachine: stateMachine,
      settingsManager: settingsManager,
      activityReporter: activityReporter,
      sessionContainer: sessionContainer,
      logger: rootLogger,
      resetMasterPasswordService: resetMasterPasswordService,
      userSettings: userSettings,
      keychainService: keychainService,
      login: login,
      context: context,
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      recoveryLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      localLoginUnlockViewModelFactory: InjectedFactory(makeLocalLoginUnlockViewModel),
      masterPasswordLocalViewModelFactory: InjectedFactory(makeMasterPasswordLocalViewModel),
      ssoLoginViewModelFactory: InjectedFactory(makeSSOLocalLoginViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLocalLoginUnlockViewModel(
    login: Login, context: LoginUnlockContext, userSettings: UserSettings,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    localLoginUnlockStateMachine: LocalLoginUnlockStateMachine,
    completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
  ) -> LocalLoginUnlockViewModel {
    return LocalLoginUnlockViewModel(
      login: login,
      context: context,
      userSettings: userSettings,
      resetMasterPasswordService: resetMasterPasswordService,
      logger: rootLogger,
      masterPasswordLocalViewModelFactory: InjectedFactory(makeMasterPasswordLocalViewModel),
      biometryViewModelFactory: InjectedFactory(makeBiometryViewModel),
      pinCodeAndBiometryViewModelFactory: InjectedFactory(makePinCodeAndBiometryViewModel),
      passwordLessRecoveryViewModelFactory: InjectedFactory(makePasswordLessRecoveryViewModel),
      localLoginUnlockStateMachine: localLoginUnlockStateMachine,
      ssoUnlockViewModelFactory: InjectedFactory(makeSSOUnlockViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLoginFlowViewModel(
    login: Login?, deviceId: String?, loginHandler: LoginStateMachine,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>, context: UnlockOriginProcess,
    completion: @escaping (LoginFlowViewModel.Completion) -> Void
  ) -> LoginFlowViewModel {
    return LoginFlowViewModel(
      login: login,
      deviceId: deviceId,
      logger: rootLogger,
      loginHandler: loginHandler,
      keychainService: keychainService,
      cryptoEngineProvider: cryptoEngineProvider,
      spiegelSettingsManager: settingsManager,
      localLoginViewModelFactory: InjectedFactory(makeLocalLoginFlowViewModel),
      remoteLoginViewModelFactory: InjectedFactory(makeRemoteLoginFlowViewModel),
      loginViewModelFactory: InjectedFactory(makeLoginInputViewModel),
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      tokenPublisher: tokenPublisher,
      context: context,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeLoginInputViewModel(
    email: String?, loginHandler: LoginStateMachine,
    staticErrorPublisher: AnyPublisher<Error?, Never>,
    completion: @escaping (LoginStateMachine.LoginResult?) -> Void
  ) -> LoginInputViewModel {
    return LoginInputViewModel(
      email: email,
      loginHandler: loginHandler,
      activityReporter: activityReporter,
      debugAccountsListFactory: InjectedFactory(makeDebugAccountListViewModel),
      staticErrorPublisher: staticErrorPublisher,
      appAPIClient: appAPIClient,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordInputRemoteViewModel(
    stateMachine: MasterPasswordInputRemoteStateMachine, login: Login, data: DeviceRegistrationData,
    completion: @escaping (RemoteLoginSession) -> Void
  ) -> MasterPasswordInputRemoteViewModel {
    return MasterPasswordInputRemoteViewModel(
      stateMachine: stateMachine,
      login: login,
      activityReporter: activityReporter,
      data: data,
      logger: rootLogger,
      recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordLocalViewModel(
    login: Login, biometry: Biometry?, context: LoginUnlockContext,
    masterPasswordLocalStateMachine: MasterPasswordLocalLoginStateMachine,
    completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
  ) -> MasterPasswordLocalViewModel {
    return MasterPasswordLocalViewModel(
      login: login,
      biometry: biometry,
      context: context,
      masterPasswordLocalStateMachine: masterPasswordLocalStateMachine,
      logger: rootLogger,
      recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
      forgotMasterPasswordSheetModelFactory: InjectedFactory(makeForgotMasterPasswordSheetModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeMasterPasswordRemoteLoginFlowModel(
    login: Login, deviceInfo: DeviceInfo, verificationMethod: VerificationMethod,
    stateMachine: MasterPasswordFlowRemoteStateMachine, tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (
      Result<MasterPasswordRemoteLoginFlowModel.CompletionType, Error>
    ) -> Void
  ) -> MasterPasswordRemoteLoginFlowModel {
    return MasterPasswordRemoteLoginFlowModel(
      login: login,
      deviceInfo: deviceInfo,
      verificationMethod: verificationMethod,
      stateMachine: stateMachine,
      tokenPublisher: tokenPublisher,
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      masterPasswordFactory: InjectedFactory(makeMasterPasswordInputRemoteViewModel),
      completion: completion
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
  public func makePinCodeAndBiometryViewModel(
    login: Login, accountType: CoreSession.AccountType, pincode: String,
    lockPinCodeAndBiometryStateMachine: LockPinCodeAndBiometryStateMachine,
    completion: @escaping (PinCodeAndBiometryViewModel.Completion) -> Void
  ) -> PinCodeAndBiometryViewModel {
    return PinCodeAndBiometryViewModel(
      login: login,
      accountType: accountType,
      pincode: pincode,
      lockPinCodeAndBiometryStateMachine: lockPinCodeAndBiometryStateMachine,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeRegularRemoteLoginFlowViewModel(
    login: Login, deviceRegistrationMethod: LoginMethod,
    stateMachine: RegularRemoteLoginStateMachine, tokenPublisher: AnyPublisher<String, Never>,
    steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) -> RegularRemoteLoginFlowViewModel {
    return RegularRemoteLoginFlowViewModel(
      login: login,
      deviceRegistrationMethod: deviceRegistrationMethod,
      stateMachine: stateMachine,
      settingsManager: settingsManager,
      activityReporter: activityReporter,
      logger: rootLogger,
      tokenPublisher: tokenPublisher,
      accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
      steps: steps,
      ssoRemoteLoginViewModelFactory: InjectedFactory(makeSSORemoteLoginViewModel),
      masterPasswordRemoteLoginFlowModelFactory: InjectedFactory(
        makeMasterPasswordRemoteLoginFlowModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeRemoteLoginFlowViewModel(
    type: RemoteLoginType, deviceInfo: DeviceInfo, stateMachine: RemoteLoginStateMachine,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  ) -> RemoteLoginFlowViewModel {
    return RemoteLoginFlowViewModel(
      type: type,
      deviceInfo: deviceInfo,
      stateMachine: stateMachine,
      purchasePlanFlowProvider: purchasePlanFlowProvider,
      remoteLoginViewModelFactory: InjectedFactory(makeRegularRemoteLoginFlowViewModel),
      sessionActivityReporterProvider: sessionActivityReporterProvider,
      deviceToDeviceLoginFlowViewModelFactory: InjectedFactory(makeDeviceTransferQRCodeFlowModel),
      deviceTransferLoginFlowModelFactory: InjectedFactory(makeDeviceTransferLoginFlowModel),
      tokenPublisher: tokenPublisher,
      deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSOLocalLoginViewModel(
    stateMachine: SSOLocalStateMachine, ssoAuthenticationInfo: SSOAuthenticationInfo,
    completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
  ) -> SSOLocalLoginViewModel {
    return SSOLocalLoginViewModel(
      stateMachine: stateMachine,
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      ssoViewModelFactory: InjectedFactory(makeSSOViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSORemoteLoginViewModel(
    ssoAuthenticationInfo: SSOAuthenticationInfo, stateMachine: SSORemoteStateMachine,
    completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
  ) -> SSORemoteLoginViewModel {
    return SSORemoteLoginViewModel(
      ssoAuthenticationInfo: ssoAuthenticationInfo,
      stateMachine: stateMachine,
      ssoViewModelFactory: InjectedFactory(makeSSOViewModel),
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {

  public func makeSSOUnlockStateMachine(
    state: SSOUnlockStateMachine.State, login: Login, deviceAccessKey: String
  ) -> SSOUnlockStateMachine {
    return SSOUnlockStateMachine(
      state: state,
      login: login,
      apiClient: appAPIClient,
      nitroClient: nitroClient,
      deviceAccessKey: deviceAccessKey,
      cryptoEngineProvider: cryptoEngineProvider,
      logger: rootLogger,
      activityReporter: activityReporter
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeSSOUnlockViewModel(
    login: Login, deviceAccessKey: String, stateMachine: SSOUnlockStateMachine,
    completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
  ) -> SSOUnlockViewModel {
    return SSOUnlockViewModel(
      login: login,
      deviceAccessKey: deviceAccessKey,
      stateMachine: stateMachine,
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
    login: Login, stateMachine: TOTPVerificationStateMachine,
    pushType: VerificationMethod.PushType?,
    completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> TOTPVerificationViewModel {
    return TOTPVerificationViewModel(
      login: login,
      stateMachine: stateMachine,
      appAPIClient: appAPIClient,
      activityReporter: activityReporter,
      pushType: pushType,
      completion: completion
    )
  }

}

extension LoginKitServicesContainer {
  @MainActor
  public func makeTokenVerificationViewModel(
    login: Login, tokenPublisher: AnyPublisher<String, Never>?,
    stateMachine: TokenVerificationStateMachine, mode: Definition.Mode,
    completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
  ) -> TokenVerificationViewModel {
    return TokenVerificationViewModel(
      login: login,
      tokenPublisher: tokenPublisher,
      stateMachine: stateMachine,
      activityReporter: activityReporter,
      mode: mode,
      completion: completion
    )
  }

}

public typealias _AccountRecoveryKeyLoginFlowModelFactory = @MainActor (
  _ login: Login,
  _ stateMachine: AccountRecoveryKeyLoginFlowStateMachine,
  _ completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
) -> AccountRecoveryKeyLoginFlowModel

extension InjectedFactory where T == _AccountRecoveryKeyLoginFlowModelFactory {
  @MainActor
  public func make(
    login: Login, stateMachine: AccountRecoveryKeyLoginFlowStateMachine,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> AccountRecoveryKeyLoginFlowModel {
    return factory(
      login,
      stateMachine,
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
  _ stateMachine: AccountVerificationStateMachine,
  _ debugTokenPublisher: AnyPublisher<String, Never>?,
  _ completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
) -> AccountVerificationFlowModel

extension InjectedFactory where T == _AccountVerificationFlowModelFactory {
  @MainActor
  public func make(
    login: Login, mode: Definition.Mode, stateMachine: AccountVerificationStateMachine,
    debugTokenPublisher: AnyPublisher<String, Never>? = nil,
    completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> AccountVerificationFlowModel {
    return factory(
      login,
      mode,
      stateMachine,
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
  _ context: LoginUnlockContext,
  _ biometryUnlockStateMachine: BiometryUnlockStateMachine,
  _ completion: @escaping (Session?) -> Void
) -> BiometryViewModel

extension InjectedFactory where T == _BiometryViewModelFactory {
  @MainActor
  public func make(
    login: Login, biometryType: Biometry, manualLockOrigin: Bool = false,
    context: LoginUnlockContext, biometryUnlockStateMachine: BiometryUnlockStateMachine,
    completion: @escaping (Session?) -> Void
  ) -> BiometryViewModel {
    return factory(
      login,
      biometryType,
      manualLockOrigin,
      context,
      biometryUnlockStateMachine,
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
  _ stateMachine: DeviceTransferLoginFlowStateMachine,
  _ completion: @MainActor @escaping (Result<DeviceTransferQRCodeFlowModel.Completion, Error>) ->
    Void
) -> DeviceTransferLoginFlowModel

extension InjectedFactory where T == _DeviceTransferLoginFlowModelFactory {
  @MainActor
  public func make(
    login: Login?, deviceInfo: DeviceInfo, stateMachine: DeviceTransferLoginFlowStateMachine,
    completion: @MainActor @escaping (Result<DeviceTransferQRCodeFlowModel.Completion, Error>) ->
      Void
  ) -> DeviceTransferLoginFlowModel {
    return factory(
      login,
      deviceInfo,
      stateMachine,
      completion
    )
  }
}

extension DeviceTransferLoginFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferLoginFlowModelFactory>
}

public typealias _DeviceTransferOTPLoginViewModelFactory = @MainActor (
  _ stateMachine: ThirdPartyOTPLoginStateMachine,
  _ login: Login,
  _ option: ThirdPartyOTPOption,
  _ completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
) -> DeviceTransferOTPLoginViewModel

extension InjectedFactory where T == _DeviceTransferOTPLoginViewModelFactory {
  @MainActor
  public func make(
    stateMachine: ThirdPartyOTPLoginStateMachine, login: Login, option: ThirdPartyOTPOption,
    completion: @escaping (DeviceTransferOTPLoginViewModel.CompletionType) -> Void
  ) -> DeviceTransferOTPLoginViewModel {
    return factory(
      stateMachine,
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
  _ stateMachine: PassphraseVerificationStateMachine,
  _ words: [String],
  _ completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
) -> DeviceTransferPassphraseViewModel

extension InjectedFactory where T == _DeviceTransferPassphraseViewModelFactory {
  @MainActor
  public func make(
    stateMachine: PassphraseVerificationStateMachine, words: [String],
    completion: @escaping (DeviceTransferPassphraseViewModel.CompletionType) -> Void
  ) -> DeviceTransferPassphraseViewModel {
    return factory(
      stateMachine,
      words,
      completion
    )
  }
}

extension DeviceTransferPassphraseViewModel {
  public typealias Factory = InjectedFactory<_DeviceTransferPassphraseViewModelFactory>
}

public typealias _DeviceTransferQRCodeFlowModelFactory = @MainActor (
  _ login: Login?,
  _ stateMachine: QRCodeFlowStateMachine,
  _ completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
) -> DeviceTransferQRCodeFlowModel

extension InjectedFactory where T == _DeviceTransferQRCodeFlowModelFactory {
  @MainActor
  public func make(
    login: Login?, stateMachine: QRCodeFlowStateMachine,
    completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQRCodeFlowModel {
    return factory(
      login,
      stateMachine,
      completion
    )
  }
}

extension DeviceTransferQRCodeFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferQRCodeFlowModelFactory>
}

public typealias _DeviceTransferQrCodeViewModelFactory = @MainActor (
  _ login: Login?,
  _ stateMachine: QRCodeScanStateMachine,
  _ completion: @escaping (DeviceTransferCompletion) -> Void
) -> DeviceTransferQrCodeViewModel

extension InjectedFactory where T == _DeviceTransferQrCodeViewModelFactory {
  @MainActor
  public func make(
    login: Login?, stateMachine: QRCodeScanStateMachine,
    completion: @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferQrCodeViewModel {
    return factory(
      login,
      stateMachine,
      completion
    )
  }
}

extension DeviceTransferQrCodeViewModel {
  public typealias Factory = InjectedFactory<_DeviceTransferQrCodeViewModelFactory>
}

public typealias _DeviceTransferRecoveryFlowModelFactory = @MainActor (
  _ login: Login,
  _ stateMachine: DeviceTransferRecoveryFlowStateMachine,
  _ completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
) -> DeviceTransferRecoveryFlowModel

extension InjectedFactory where T == _DeviceTransferRecoveryFlowModelFactory {
  @MainActor
  public func make(
    login: Login, stateMachine: DeviceTransferRecoveryFlowStateMachine,
    completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
  ) -> DeviceTransferRecoveryFlowModel {
    return factory(
      login,
      stateMachine,
      completion
    )
  }
}

extension DeviceTransferRecoveryFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferRecoveryFlowModelFactory>
}

public typealias _DeviceTransferSecurityChallengeFlowModelFactory = @MainActor (
  _ login: Login,
  _ stateMachine: SecurityChallengeFlowStateMachine,
  _ completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
) -> DeviceTransferSecurityChallengeFlowModel

extension InjectedFactory where T == _DeviceTransferSecurityChallengeFlowModelFactory {
  @MainActor
  public func make(
    login: Login, stateMachine: SecurityChallengeFlowStateMachine,
    completion: @MainActor @escaping (DeviceTransferCompletion) -> Void
  ) -> DeviceTransferSecurityChallengeFlowModel {
    return factory(
      login,
      stateMachine,
      completion
    )
  }
}

extension DeviceTransferSecurityChallengeFlowModel {
  public typealias Factory = InjectedFactory<_DeviceTransferSecurityChallengeFlowModelFactory>
}

public typealias _DeviceTransferSecurityChallengeIntroViewModelFactory = @MainActor (
  _ login: Login,
  _ stateMachine: SecurityChallengeTransferStateMachine,
  _ completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
) -> DeviceTransferSecurityChallengeIntroViewModel

extension InjectedFactory where T == _DeviceTransferSecurityChallengeIntroViewModelFactory {
  @MainActor
  public func make(
    login: Login, stateMachine: SecurityChallengeTransferStateMachine,
    completion: @escaping (DeviceTransferSecurityChallengeIntroViewModel.CompletionType) -> Void
  ) -> DeviceTransferSecurityChallengeIntroViewModel {
    return factory(
      login,
      stateMachine,
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

public typealias _ForgotMasterPasswordSheetModelFactory = (
  _ login: String,
  _ hasMasterPasswordReset: Bool,
  _ didTapResetMP: (() -> Void)?,
  _ didTapAccountRecovery: (() -> Void)?
) -> ForgotMasterPasswordSheetModel

extension InjectedFactory where T == _ForgotMasterPasswordSheetModelFactory {

  public func make(
    login: String, hasMasterPasswordReset: Bool, didTapResetMP: (() -> Void)? = nil,
    didTapAccountRecovery: (() -> Void)? = nil
  ) -> ForgotMasterPasswordSheetModel {
    return factory(
      login,
      hasMasterPasswordReset,
      didTapResetMP,
      didTapAccountRecovery
    )
  }
}

extension ForgotMasterPasswordSheetModel {
  public typealias Factory = InjectedFactory<_ForgotMasterPasswordSheetModelFactory>
}

public typealias _LocalLoginFlowViewModelFactory = @MainActor (
  _ stateMachine: LocalLoginStateMachine,
  _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
  _ userSettings: UserSettings,
  _ login: Login,
  _ context: UnlockOriginProcess,
  _ completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
) -> LocalLoginFlowViewModel

extension InjectedFactory where T == _LocalLoginFlowViewModelFactory {
  @MainActor
  public func make(
    stateMachine: LocalLoginStateMachine,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings,
    login: Login, context: UnlockOriginProcess,
    completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void
  ) -> LocalLoginFlowViewModel {
    return factory(
      stateMachine,
      resetMasterPasswordService,
      userSettings,
      login,
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
  _ context: LoginUnlockContext,
  _ userSettings: UserSettings,
  _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
  _ localLoginUnlockStateMachine: LocalLoginUnlockStateMachine,
  _ completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
) -> LocalLoginUnlockViewModel

extension InjectedFactory where T == _LocalLoginUnlockViewModelFactory {
  @MainActor
  public func make(
    login: Login, context: LoginUnlockContext, userSettings: UserSettings,
    resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    localLoginUnlockStateMachine: LocalLoginUnlockStateMachine,
    completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
  ) -> LocalLoginUnlockViewModel {
    return factory(
      login,
      context,
      userSettings,
      resetMasterPasswordService,
      localLoginUnlockStateMachine,
      completion
    )
  }
}

extension LocalLoginUnlockViewModel {
  public typealias Factory = InjectedFactory<_LocalLoginUnlockViewModelFactory>
}

public typealias _LoginFlowViewModelFactory = @MainActor (
  _ login: Login?,
  _ deviceId: String?,
  _ loginHandler: LoginStateMachine,
  _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
  _ sessionActivityReporterProvider: SessionActivityReporterProvider,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ context: UnlockOriginProcess,
  _ completion: @escaping (LoginFlowViewModel.Completion) -> Void
) -> LoginFlowViewModel

extension InjectedFactory where T == _LoginFlowViewModelFactory {
  @MainActor
  public func make(
    login: Login?, deviceId: String?, loginHandler: LoginStateMachine,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>, context: UnlockOriginProcess,
    completion: @escaping (LoginFlowViewModel.Completion) -> Void
  ) -> LoginFlowViewModel {
    return factory(
      login,
      deviceId,
      loginHandler,
      purchasePlanFlowProvider,
      sessionActivityReporterProvider,
      tokenPublisher,
      context,
      completion
    )
  }
}

extension LoginFlowViewModel {
  public typealias Factory = InjectedFactory<_LoginFlowViewModelFactory>
}

public typealias _LoginInputViewModelFactory = @MainActor (
  _ email: String?,
  _ loginHandler: LoginStateMachine,
  _ staticErrorPublisher: AnyPublisher<Error?, Never>,
  _ completion: @escaping (LoginStateMachine.LoginResult?) -> Void
) -> LoginInputViewModel

extension InjectedFactory where T == _LoginInputViewModelFactory {
  @MainActor
  public func make(
    email: String?, loginHandler: LoginStateMachine,
    staticErrorPublisher: AnyPublisher<Error?, Never>,
    completion: @escaping (LoginStateMachine.LoginResult?) -> Void
  ) -> LoginInputViewModel {
    return factory(
      email,
      loginHandler,
      staticErrorPublisher,
      completion
    )
  }
}

extension LoginInputViewModel {
  public typealias Factory = InjectedFactory<_LoginInputViewModelFactory>
}

public typealias _MasterPasswordInputRemoteViewModelFactory = @MainActor (
  _ stateMachine: MasterPasswordInputRemoteStateMachine,
  _ login: Login,
  _ data: DeviceRegistrationData,
  _ completion: @escaping (RemoteLoginSession) -> Void
) -> MasterPasswordInputRemoteViewModel

extension InjectedFactory where T == _MasterPasswordInputRemoteViewModelFactory {
  @MainActor
  public func make(
    stateMachine: MasterPasswordInputRemoteStateMachine, login: Login, data: DeviceRegistrationData,
    completion: @escaping (RemoteLoginSession) -> Void
  ) -> MasterPasswordInputRemoteViewModel {
    return factory(
      stateMachine,
      login,
      data,
      completion
    )
  }
}

extension MasterPasswordInputRemoteViewModel {
  public typealias Factory = InjectedFactory<_MasterPasswordInputRemoteViewModelFactory>
}

public typealias _MasterPasswordLocalViewModelFactory = @MainActor (
  _ login: Login,
  _ biometry: Biometry?,
  _ context: LoginUnlockContext,
  _ masterPasswordLocalStateMachine: MasterPasswordLocalLoginStateMachine,
  _ completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
) -> MasterPasswordLocalViewModel

extension InjectedFactory where T == _MasterPasswordLocalViewModelFactory {
  @MainActor
  public func make(
    login: Login, biometry: Biometry?, context: LoginUnlockContext,
    masterPasswordLocalStateMachine: MasterPasswordLocalLoginStateMachine,
    completion: @escaping (MasterPasswordLocalViewModel.CompletionType) -> Void
  ) -> MasterPasswordLocalViewModel {
    return factory(
      login,
      biometry,
      context,
      masterPasswordLocalStateMachine,
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
  _ stateMachine: MasterPasswordFlowRemoteStateMachine,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ completion: @MainActor @escaping (
    Result<MasterPasswordRemoteLoginFlowModel.CompletionType, Error>
  ) -> Void
) -> MasterPasswordRemoteLoginFlowModel

extension InjectedFactory where T == _MasterPasswordRemoteLoginFlowModelFactory {
  @MainActor
  public func make(
    login: Login, deviceInfo: DeviceInfo, verificationMethod: VerificationMethod,
    stateMachine: MasterPasswordFlowRemoteStateMachine, tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (
      Result<MasterPasswordRemoteLoginFlowModel.CompletionType, Error>
    ) -> Void
  ) -> MasterPasswordRemoteLoginFlowModel {
    return factory(
      login,
      deviceInfo,
      verificationMethod,
      stateMachine,
      tokenPublisher,
      completion
    )
  }
}

extension MasterPasswordRemoteLoginFlowModel {
  public typealias Factory = InjectedFactory<_MasterPasswordRemoteLoginFlowModelFactory>
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

public typealias _PinCodeAndBiometryViewModelFactory = @MainActor (
  _ login: Login,
  _ accountType: CoreSession.AccountType,
  _ pincode: String,
  _ lockPinCodeAndBiometryStateMachine: LockPinCodeAndBiometryStateMachine,
  _ completion: @escaping (PinCodeAndBiometryViewModel.Completion) -> Void
) -> PinCodeAndBiometryViewModel

extension InjectedFactory where T == _PinCodeAndBiometryViewModelFactory {
  @MainActor
  public func make(
    login: Login, accountType: CoreSession.AccountType, pincode: String,
    lockPinCodeAndBiometryStateMachine: LockPinCodeAndBiometryStateMachine,
    completion: @escaping (PinCodeAndBiometryViewModel.Completion) -> Void
  ) -> PinCodeAndBiometryViewModel {
    return factory(
      login,
      accountType,
      pincode,
      lockPinCodeAndBiometryStateMachine,
      completion
    )
  }
}

extension PinCodeAndBiometryViewModel {
  public typealias Factory = InjectedFactory<_PinCodeAndBiometryViewModelFactory>
}

public typealias _RegularRemoteLoginFlowViewModelFactory = @MainActor (
  _ login: Login,
  _ deviceRegistrationMethod: LoginMethod,
  _ stateMachine: RegularRemoteLoginStateMachine,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ steps: [RegularRemoteLoginFlowViewModel.Step],
  _ completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
    -> Void
) -> RegularRemoteLoginFlowViewModel

extension InjectedFactory where T == _RegularRemoteLoginFlowViewModelFactory {
  @MainActor
  public func make(
    login: Login, deviceRegistrationMethod: LoginMethod,
    stateMachine: RegularRemoteLoginStateMachine, tokenPublisher: AnyPublisher<String, Never>,
    steps: [RegularRemoteLoginFlowViewModel.Step] = [],
    completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.CompletionType, Error>)
      -> Void
  ) -> RegularRemoteLoginFlowViewModel {
    return factory(
      login,
      deviceRegistrationMethod,
      stateMachine,
      tokenPublisher,
      steps,
      completion
    )
  }
}

extension RegularRemoteLoginFlowViewModel {
  public typealias Factory = InjectedFactory<_RegularRemoteLoginFlowViewModelFactory>
}

public typealias _RemoteLoginFlowViewModelFactory = @MainActor (
  _ type: RemoteLoginType,
  _ deviceInfo: DeviceInfo,
  _ stateMachine: RemoteLoginStateMachine,
  _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
  _ sessionActivityReporterProvider: SessionActivityReporterProvider,
  _ tokenPublisher: AnyPublisher<String, Never>,
  _ completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
) -> RemoteLoginFlowViewModel

extension InjectedFactory where T == _RemoteLoginFlowViewModelFactory {
  @MainActor
  public func make(
    type: RemoteLoginType, deviceInfo: DeviceInfo, stateMachine: RemoteLoginStateMachine,
    purchasePlanFlowProvider: PurchasePlanFlowProvider,
    sessionActivityReporterProvider: SessionActivityReporterProvider,
    tokenPublisher: AnyPublisher<String, Never>,
    completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
  ) -> RemoteLoginFlowViewModel {
    return factory(
      type,
      deviceInfo,
      stateMachine,
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

public typealias _SSOLocalLoginViewModelFactory = @MainActor (
  _ stateMachine: SSOLocalStateMachine,
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
) -> SSOLocalLoginViewModel

extension InjectedFactory where T == _SSOLocalLoginViewModelFactory {
  @MainActor
  public func make(
    stateMachine: SSOLocalStateMachine, ssoAuthenticationInfo: SSOAuthenticationInfo,
    completion: @escaping Completion<SSOLocalLoginViewModel.CompletionType>
  ) -> SSOLocalLoginViewModel {
    return factory(
      stateMachine,
      ssoAuthenticationInfo,
      completion
    )
  }
}

extension SSOLocalLoginViewModel {
  public typealias Factory = InjectedFactory<_SSOLocalLoginViewModelFactory>
}

public typealias _SSORemoteLoginViewModelFactory = @MainActor (
  _ ssoAuthenticationInfo: SSOAuthenticationInfo,
  _ stateMachine: SSORemoteStateMachine,
  _ completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
) -> SSORemoteLoginViewModel

extension InjectedFactory where T == _SSORemoteLoginViewModelFactory {
  @MainActor
  public func make(
    ssoAuthenticationInfo: SSOAuthenticationInfo, stateMachine: SSORemoteStateMachine,
    completion: @escaping Completion<SSORemoteLoginViewModel.CompletionType>
  ) -> SSORemoteLoginViewModel {
    return factory(
      ssoAuthenticationInfo,
      stateMachine,
      completion
    )
  }
}

extension SSORemoteLoginViewModel {
  public typealias Factory = InjectedFactory<_SSORemoteLoginViewModelFactory>
}

public typealias _SSOUnlockStateMachineFactory = (
  _ state: SSOUnlockStateMachine.State,
  _ login: Login,
  _ deviceAccessKey: String
) -> SSOUnlockStateMachine

extension InjectedFactory where T == _SSOUnlockStateMachineFactory {

  public func make(state: SSOUnlockStateMachine.State, login: Login, deviceAccessKey: String)
    -> SSOUnlockStateMachine
  {
    return factory(
      state,
      login,
      deviceAccessKey
    )
  }
}

extension SSOUnlockStateMachine {
  public typealias Factory = InjectedFactory<_SSOUnlockStateMachineFactory>
}

public typealias _SSOUnlockViewModelFactory = @MainActor (
  _ login: Login,
  _ deviceAccessKey: String,
  _ stateMachine: SSOUnlockStateMachine,
  _ completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
) -> SSOUnlockViewModel

extension InjectedFactory where T == _SSOUnlockViewModelFactory {
  @MainActor
  public func make(
    login: Login, deviceAccessKey: String, stateMachine: SSOUnlockStateMachine,
    completion: @escaping Completion<SSOUnlockViewModel.CompletionType>
  ) -> SSOUnlockViewModel {
    return factory(
      login,
      deviceAccessKey,
      stateMachine,
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
  _ login: Login,
  _ stateMachine: TOTPVerificationStateMachine,
  _ pushType: VerificationMethod.PushType?,
  _ completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
) -> TOTPVerificationViewModel

extension InjectedFactory where T == _TOTPVerificationViewModelFactory {
  @MainActor
  public func make(
    login: Login, stateMachine: TOTPVerificationStateMachine,
    pushType: VerificationMethod.PushType?,
    completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
  ) -> TOTPVerificationViewModel {
    return factory(
      login,
      stateMachine,
      pushType,
      completion
    )
  }
}

extension TOTPVerificationViewModel {
  public typealias Factory = InjectedFactory<_TOTPVerificationViewModelFactory>
}

public typealias _TokenVerificationViewModelFactory = @MainActor (
  _ login: Login,
  _ tokenPublisher: AnyPublisher<String, Never>?,
  _ stateMachine: TokenVerificationStateMachine,
  _ mode: Definition.Mode,
  _ completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
) -> TokenVerificationViewModel

extension InjectedFactory where T == _TokenVerificationViewModelFactory {
  @MainActor
  public func make(
    login: Login, tokenPublisher: AnyPublisher<String, Never>?,
    stateMachine: TokenVerificationStateMachine, mode: Definition.Mode,
    completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
  ) -> TokenVerificationViewModel {
    return factory(
      login,
      tokenPublisher,
      stateMachine,
      mode,
      completion
    )
  }
}

extension TokenVerificationViewModel {
  public typealias Factory = InjectedFactory<_TokenVerificationViewModelFactory>
}
