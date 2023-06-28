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
#if canImport(DashlaneCrypto)
import DashlaneCrypto
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

public protocol LoginKitServicesInjecting { }

 
extension LoginKitServicesContainer {
        @MainActor
        public func makeAccountRecoveryKeyLoginFlowModel(login: String, accountType: AccountType, context: AccountRecoveryKeyLoginFlowModel.Context, completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void) -> AccountRecoveryKeyLoginFlowModel {
            return AccountRecoveryKeyLoginFlowModel(
                            login: login,
                            appAPIClient: appAPIClient,
                            accountType: accountType,
                            passwordEvaluator: passwordEvaluvator,
                            activityReporter: activityReporter,
                            context: context,
                            accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeAccountRecoveryKeyLoginViewModel(login: String, authTicket: AuthTicket, accountType: AccountType, recoveryKey: String = "", showNoMatchError: Bool = false, completion: @MainActor @escaping (CoreSession.MasterKey, AuthTicket) -> Void) -> AccountRecoveryKeyLoginViewModel {
            return AccountRecoveryKeyLoginViewModel(
                            login: login,
                            appAPIClient: appAPIClient,
                            authTicket: authTicket,
                            accountType: accountType,
                            recoveryKey: recoveryKey,
                            showNoMatchError: showNoMatchError,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeAccountVerificationFlowModel(login: String, verificationMethod: VerificationMethod, deviceInfo: DeviceInfo, debugTokenPublisher: AnyPublisher<String, Never>? = nil, completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void) -> AccountVerificationFlowModel {
            return AccountVerificationFlowModel(
                            login: login,
                            verificationMethod: verificationMethod,
                            appAPIClient: appAPIClient,
                            deviceInfo: deviceInfo,
                            debugTokenPublisher: debugTokenPublisher,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            tokenVerificationViewModelFactory: InjectedFactory(makeTokenVerificationViewModel),
                            totpVerificationViewModelFactory: InjectedFactory(makeTOTPVerificationViewModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeAuthenticatorPushVerificationViewModel(login: Login, accountVerificationService: AccountVerificationService, completion: @escaping (AuthenticatorPushVerificationViewModel.CompletionType) -> Void) -> AuthenticatorPushVerificationViewModel {
            return AuthenticatorPushVerificationViewModel(
                            login: login,
                            accountVerificationService: accountVerificationService,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeBiometryViewModel(login: Login, biometryType: Biometry, manualLockOrigin: Bool = false, unlocker: UnlockSessionHandler, context: LoginUnlockContext, userSettings: UserSettings, completion: @escaping (_ isSuccess: Bool) -> Void) -> BiometryViewModel {
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
        
        public func makeDebugAccountListViewModel() -> DebugAccountListViewModel {
            return DebugAccountListViewModel(
                            sessionCleaner: sessionCleaner,
                            sessionsContainer: sessionContainer
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeDeviceToDeviceLoginFlowViewModel(loginHandler: DeviceToDeviceLoginHandler, sessionActivityReporterProvider: SessionActivityReporterProvider, completion: @MainActor @escaping (Result<DeviceToDeviceLoginFlowViewModel.Completion, Error>) -> Void) -> DeviceToDeviceLoginFlowViewModel {
            return DeviceToDeviceLoginFlowViewModel(
                            appAPIClient: appAPIClient,
                            loginHandler: loginHandler,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            remoteLoginInfoProvider: remoteLoginInfoProvider,
                            keychainService: keychainService,
                            deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
                            sessionActivityReporterProvider: sessionActivityReporterProvider,
                            totpFactory: InjectedFactory(makeDeviceToDeviceOTPLoginViewModel),
                            deviceToDeviceLoginQrCodeViewModelFactory: InjectedFactory(makeDeviceToDeviceLoginQrCodeViewModel),
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            sessionCleaner: sessionCleaner,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeDeviceToDeviceLoginQrCodeViewModel(loginHandler: DeviceToDeviceLoginHandler, completion: @escaping (DeviceToDeviceLoginQrCodeViewModel.CompletionType) -> Void) -> DeviceToDeviceLoginQrCodeViewModel {
            return DeviceToDeviceLoginQrCodeViewModel(
                            loginHandler: loginHandler,
                            apiClient: appAPIClient,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            accountRecoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeDeviceToDeviceOTPLoginViewModel(validator: ThirdPartyOTPDeviceRegistrationValidator, recover2faWebService: Recover2FAWebService, completion: @escaping (DeviceToDeviceOTPLoginViewModel.CompletionType) -> Void) -> DeviceToDeviceOTPLoginViewModel {
            return DeviceToDeviceOTPLoginViewModel(
                            validator: validator,
                            activityReporter: activityReporter,
                            recover2faWebService: recover2faWebService,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeDeviceUnlinkingFlowViewModel(deviceUnlinker: DeviceUnlinker, login: Login, session: RemoteLoginSession, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) -> DeviceUnlinkingFlowViewModel {
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
        public func makeDeviceUnlinkingFlowViewModel(deviceUnlinker: DeviceUnlinker, login: Login, authentication: ServerAuthentication, purchasePlanFlowProvider: PurchasePlanFlowProvider, completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) -> DeviceUnlinkingFlowViewModel {
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
        public func makeLocalLoginFlowViewModel(localLoginHandler: LocalLoginHandler, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings, email: String, context: LocalLoginFlowContext, completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void) -> LocalLoginFlowViewModel {
            return LocalLoginFlowViewModel(
                            localLoginHandler: localLoginHandler,
                            settingsManager: settingsManager,
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            sessionContainer: sessionContainer,
                            logger: rootLogger,
                            resetMasterPasswordService: resetMasterPasswordService,
                            userSettings: userSettings,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            keychainService: keychainService,
                            email: email,
                            context: context,
                            nitroWebService: nitroWebService,
                            accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
                            recoveryLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
                            localLoginUnlockViewModelFactory: InjectedFactory(makeLocalLoginUnlockViewModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeLocalLoginUnlockViewModel(login: Login, accountType: AccountType, unlockType: UnlockType, secureLockMode: SecureLockMode, unlocker: UnlockSessionHandler, context: LoginUnlockContext, userSettings: UserSettings, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void) -> LocalLoginUnlockViewModel {
            return LocalLoginUnlockViewModel(
                            login: login,
                            accountType: accountType,
                            unlockType: unlockType,
                            secureLockMode: secureLockMode,
                            unlocker: unlocker,
                            context: context,
                            userSettings: userSettings,
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            resetMasterPasswordService: resetMasterPasswordService,
                            appAPIClient: appAPIClient,
                            sessionCleaner: sessionCleaner,
                            keychainService: keychainService,
                            masterPasswordLocalViewModelFactory: InjectedFactory(makeMasterPasswordLocalViewModel),
                            biometryViewModelFactory: InjectedFactory(makeBiometryViewModel),
                            lockPinCodeAndBiometryViewModelFactory: InjectedFactory(makeLockPinCodeAndBiometryViewModel),
                            passwordLessRecoveryViewModelFactory: InjectedFactory(makePasswordLessRecoveryViewModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeLockPinCodeAndBiometryViewModel(login: Login, accountType: AccountType, pinCodeLock: SecureLockMode.PinCodeLock, biometryType: Biometry? = nil, context: LoginUnlockContext, unlocker: UnlockSessionHandler, completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void) -> LockPinCodeAndBiometryViewModel {
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
        public func makeLoginFlowViewModel(login: Login?, deviceId: String?, loginHandler: LoginHandler, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, versionValidityAlertProvider: AlertContent, context: LocalLoginFlowContext, completion: @escaping (LoginFlowViewModel.Completion) -> Void) -> LoginFlowViewModel {
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
        public func makeLoginViewModel(email: String?, loginHandler: LoginHandler, staticErrorPublisher: AnyPublisher<Error?, Never>, versionValidityAlertProvider: AlertContent, completion: @escaping (LoginHandler.LoginResult?) -> Void) -> LoginViewModel {
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
        public func makeMasterPasswordLocalViewModel(login: Login, biometry: Biometry?, authTicket: AuthTicket?, unlocker: UnlockSessionHandler, context: LoginUnlockContext, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings, completion: @escaping (MasterPasswordLocalViewModel.CompletionMode?) -> Void) -> MasterPasswordLocalViewModel {
            return MasterPasswordLocalViewModel(
                            login: login,
                            biometry: biometry,
                            authTicket: authTicket,
                            unlocker: unlocker,
                            context: context,
                            resetMasterPasswordService: resetMasterPasswordService,
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            appAPIClient: appAPIClient,
                            userSettings: userSettings,
                            recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeMasterPasswordRemoteViewModel(login: Login, verificationMode: Definition.VerificationMode, isBackupCode: Bool, isExtension: Bool, validator: RegularRemoteLoginHandler, keys: LoginKeys, completion: @escaping () -> Void) -> MasterPasswordRemoteViewModel {
            return MasterPasswordRemoteViewModel(
                            login: login,
                            appAPIClient: appAPIClient,
                            verificationMode: verificationMode,
                            isBackupCode: isBackupCode,
                            isExtension: isExtension,
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            validator: validator,
                            logger: rootLogger,
                            remoteLoginDelegate: remoteLoginInfoProvider,
                            keys: keys,
                            recoveryKeyLoginFlowModelFactory: InjectedFactory(makeAccountRecoveryKeyLoginFlowModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeNitroSSOLoginViewModel(login: String, completion: @escaping Completion<SSOCallbackInfos>) -> NitroSSOLoginViewModel {
            return NitroSSOLoginViewModel(
                            login: login,
                            nitroWebService: nitroWebService,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makePasswordLessRecoveryViewModel(login: Login, recoverFromFailure: Bool, completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void) -> PasswordLessRecoveryViewModel {
            return PasswordLessRecoveryViewModel(
                            login: login,
                            recoverFromFailure: recoverFromFailure,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeRegularRemoteLoginFlowViewModel(remoteLoginHandler: RegularRemoteLoginHandler, email: String, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, steps: [RegularRemoteLoginFlowViewModel.Step] = [], completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.Completion, Error>) -> Void) -> RegularRemoteLoginFlowViewModel {
            return RegularRemoteLoginFlowViewModel(
                            remoteLoginHandler: remoteLoginHandler,
                            settingsManager: settingsManager,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            activityReporter: activityReporter,
                            remoteLoginInfoProvider: remoteLoginInfoProvider,
                            logger: rootLogger,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            appAPIClient: appAPIClient,
                            keychainService: keychainService,
                            email: email,
                            sessionActivityReporterProvider: sessionActivityReporterProvider,
                            tokenPublisher: tokenPublisher,
                            deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
                            masterPasswordFactory: InjectedFactory(makeMasterPasswordRemoteViewModel),
                            nitroFactory: InjectedFactory(makeNitroSSOLoginViewModel),
                            accountVerificationFlowModelFactory: InjectedFactory(makeAccountVerificationFlowModel),
                            steps: steps,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeRemoteLoginFlowViewModel(type: LoginFlowViewModel.RemoteLoginType, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void) -> RemoteLoginFlowViewModel {
            return RemoteLoginFlowViewModel(
                            type: type,
                            loginMetricsReporter: loginMetricsReporter,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            remoteLoginInfoProvider: remoteLoginInfoProvider,
                            purchasePlanFlowProvider: purchasePlanFlowProvider,
                            remoteLoginViewModelFactory: InjectedFactory(makeRegularRemoteLoginFlowViewModel),
                            sessionActivityReporterProvider: sessionActivityReporterProvider,
                            deviceToDeviceLoginFlowViewModelFactory: InjectedFactory(makeDeviceToDeviceLoginFlowViewModel),
                            tokenPublisher: tokenPublisher,
                            deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeTOTPVerificationViewModel(accountVerificationService: AccountVerificationService, recover2faWebService: Recover2FAWebService, pushType: PushType?, completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void) -> TOTPVerificationViewModel {
            return TOTPVerificationViewModel(
                            accountVerificationService: accountVerificationService,
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            recover2faWebService: recover2faWebService,
                            pushType: pushType,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeTokenVerificationViewModel(tokenPublisher: AnyPublisher<String, Never>?, accountVerificationService: AccountVerificationService, completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void) -> TokenVerificationViewModel {
            return TokenVerificationViewModel(
                            tokenPublisher: tokenPublisher,
                            accountVerificationService: accountVerificationService,
                            activityReporter: activityReporter,
                            completion: completion
            )
        }
        
}


public typealias _AccountRecoveryKeyLoginFlowModelFactory = @MainActor (
    _ login: String,
    _ accountType: AccountType,
    _ context: AccountRecoveryKeyLoginFlowModel.Context,
    _ completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void
) -> AccountRecoveryKeyLoginFlowModel

public extension InjectedFactory where T == _AccountRecoveryKeyLoginFlowModelFactory {
    @MainActor
    func make(login: String, accountType: AccountType, context: AccountRecoveryKeyLoginFlowModel.Context, completion: @MainActor @escaping (AccountRecoveryKeyLoginFlowModel.Completion) -> Void) -> AccountRecoveryKeyLoginFlowModel {
       return factory(
              login,
              accountType,
              context,
              completion
       )
    }
}

extension AccountRecoveryKeyLoginFlowModel {
        public typealias Factory = InjectedFactory<_AccountRecoveryKeyLoginFlowModelFactory>
}


public typealias _AccountRecoveryKeyLoginViewModelFactory = @MainActor (
    _ login: String,
    _ authTicket: AuthTicket,
    _ accountType: AccountType,
    _ recoveryKey: String,
    _ showNoMatchError: Bool,
    _ completion: @MainActor @escaping (CoreSession.MasterKey, AuthTicket) -> Void
) -> AccountRecoveryKeyLoginViewModel

public extension InjectedFactory where T == _AccountRecoveryKeyLoginViewModelFactory {
    @MainActor
    func make(login: String, authTicket: AuthTicket, accountType: AccountType, recoveryKey: String = "", showNoMatchError: Bool = false, completion: @MainActor @escaping (CoreSession.MasterKey, AuthTicket) -> Void) -> AccountRecoveryKeyLoginViewModel {
       return factory(
              login,
              authTicket,
              accountType,
              recoveryKey,
              showNoMatchError,
              completion
       )
    }
}

extension AccountRecoveryKeyLoginViewModel {
        public typealias Factory = InjectedFactory<_AccountRecoveryKeyLoginViewModelFactory>
}


public typealias _AccountVerificationFlowModelFactory = @MainActor (
    _ login: String,
    _ verificationMethod: VerificationMethod,
    _ deviceInfo: DeviceInfo,
    _ debugTokenPublisher: AnyPublisher<String, Never>?,
    _ completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void
) -> AccountVerificationFlowModel

public extension InjectedFactory where T == _AccountVerificationFlowModelFactory {
    @MainActor
    func make(login: String, verificationMethod: VerificationMethod, deviceInfo: DeviceInfo, debugTokenPublisher: AnyPublisher<String, Never>? = nil, completion: @MainActor @escaping (Result<(AuthTicket, Bool), Error>) -> Void) -> AccountVerificationFlowModel {
       return factory(
              login,
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


public typealias _AuthenticatorPushVerificationViewModelFactory = @MainActor (
    _ login: Login,
    _ accountVerificationService: AccountVerificationService,
    _ completion: @escaping (AuthenticatorPushVerificationViewModel.CompletionType) -> Void
) -> AuthenticatorPushVerificationViewModel

public extension InjectedFactory where T == _AuthenticatorPushVerificationViewModelFactory {
    @MainActor
    func make(login: Login, accountVerificationService: AccountVerificationService, completion: @escaping (AuthenticatorPushVerificationViewModel.CompletionType) -> Void) -> AuthenticatorPushVerificationViewModel {
       return factory(
              login,
              accountVerificationService,
              completion
       )
    }
}

extension AuthenticatorPushVerificationViewModel {
        public typealias Factory = InjectedFactory<_AuthenticatorPushVerificationViewModelFactory>
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

public extension InjectedFactory where T == _BiometryViewModelFactory {
    @MainActor
    func make(login: Login, biometryType: Biometry, manualLockOrigin: Bool = false, unlocker: UnlockSessionHandler, context: LoginUnlockContext, userSettings: UserSettings, completion: @escaping (_ isSuccess: Bool) -> Void) -> BiometryViewModel {
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


public typealias _DebugAccountListViewModelFactory =  (
) -> DebugAccountListViewModel

public extension InjectedFactory where T == _DebugAccountListViewModelFactory {
    
    func make() -> DebugAccountListViewModel {
       return factory(
       )
    }
}

extension DebugAccountListViewModel {
        public typealias Factory = InjectedFactory<_DebugAccountListViewModelFactory>
}


public typealias _DeviceToDeviceLoginFlowViewModelFactory = @MainActor (
    _ loginHandler: DeviceToDeviceLoginHandler,
    _ sessionActivityReporterProvider: SessionActivityReporterProvider,
    _ completion: @MainActor @escaping (Result<DeviceToDeviceLoginFlowViewModel.Completion, Error>) -> Void
) -> DeviceToDeviceLoginFlowViewModel

public extension InjectedFactory where T == _DeviceToDeviceLoginFlowViewModelFactory {
    @MainActor
    func make(loginHandler: DeviceToDeviceLoginHandler, sessionActivityReporterProvider: SessionActivityReporterProvider, completion: @MainActor @escaping (Result<DeviceToDeviceLoginFlowViewModel.Completion, Error>) -> Void) -> DeviceToDeviceLoginFlowViewModel {
       return factory(
              loginHandler,
              sessionActivityReporterProvider,
              completion
       )
    }
}

extension DeviceToDeviceLoginFlowViewModel {
        public typealias Factory = InjectedFactory<_DeviceToDeviceLoginFlowViewModelFactory>
}


public typealias _DeviceToDeviceLoginQrCodeViewModelFactory = @MainActor (
    _ loginHandler: DeviceToDeviceLoginHandler,
    _ completion: @escaping (DeviceToDeviceLoginQrCodeViewModel.CompletionType) -> Void
) -> DeviceToDeviceLoginQrCodeViewModel

public extension InjectedFactory where T == _DeviceToDeviceLoginQrCodeViewModelFactory {
    @MainActor
    func make(loginHandler: DeviceToDeviceLoginHandler, completion: @escaping (DeviceToDeviceLoginQrCodeViewModel.CompletionType) -> Void) -> DeviceToDeviceLoginQrCodeViewModel {
       return factory(
              loginHandler,
              completion
       )
    }
}

extension DeviceToDeviceLoginQrCodeViewModel {
        public typealias Factory = InjectedFactory<_DeviceToDeviceLoginQrCodeViewModelFactory>
}


public typealias _DeviceToDeviceOTPLoginViewModelFactory = @MainActor (
    _ validator: ThirdPartyOTPDeviceRegistrationValidator,
    _ recover2faWebService: Recover2FAWebService,
    _ completion: @escaping (DeviceToDeviceOTPLoginViewModel.CompletionType) -> Void
) -> DeviceToDeviceOTPLoginViewModel

public extension InjectedFactory where T == _DeviceToDeviceOTPLoginViewModelFactory {
    @MainActor
    func make(validator: ThirdPartyOTPDeviceRegistrationValidator, recover2faWebService: Recover2FAWebService, completion: @escaping (DeviceToDeviceOTPLoginViewModel.CompletionType) -> Void) -> DeviceToDeviceOTPLoginViewModel {
       return factory(
              validator,
              recover2faWebService,
              completion
       )
    }
}

extension DeviceToDeviceOTPLoginViewModel {
        public typealias Factory = InjectedFactory<_DeviceToDeviceOTPLoginViewModelFactory>
}


public typealias _DeviceUnlinkingFlowViewModelFactory = @MainActor (
    _ deviceUnlinker: DeviceUnlinker,
    _ login: Login,
    _ session: RemoteLoginSession,
    _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
    _ sessionActivityReporterProvider: SessionActivityReporterProvider,
    _ completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void
) -> DeviceUnlinkingFlowViewModel

public extension InjectedFactory where T == _DeviceUnlinkingFlowViewModelFactory {
    @MainActor
    func make(deviceUnlinker: DeviceUnlinker, login: Login, session: RemoteLoginSession, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) -> DeviceUnlinkingFlowViewModel {
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

public extension InjectedFactory where T == _DeviceUnlinkingFlowViewModelSecondFactory {
    @MainActor
    func make(deviceUnlinker: DeviceUnlinker, login: Login, authentication: ServerAuthentication, purchasePlanFlowProvider: PurchasePlanFlowProvider, completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) -> DeviceUnlinkingFlowViewModel {
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

public extension InjectedFactory where T == _LocalLoginFlowViewModelFactory {
    @MainActor
    func make(localLoginHandler: LocalLoginHandler, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings, email: String, context: LocalLoginFlowContext, completion: @MainActor @escaping (Result<LocalLoginFlowViewModel.Completion, Error>) -> Void) -> LocalLoginFlowViewModel {
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
    _ accountType: AccountType,
    _ unlockType: UnlockType,
    _ secureLockMode: SecureLockMode,
    _ unlocker: UnlockSessionHandler,
    _ context: LoginUnlockContext,
    _ userSettings: UserSettings,
    _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    _ completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void
) -> LocalLoginUnlockViewModel

public extension InjectedFactory where T == _LocalLoginUnlockViewModelFactory {
    @MainActor
    func make(login: Login, accountType: AccountType, unlockType: UnlockType, secureLockMode: SecureLockMode, unlocker: UnlockSessionHandler, context: LoginUnlockContext, userSettings: UserSettings, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, completion: @escaping (LocalLoginUnlockViewModel.Completion) -> Void) -> LocalLoginUnlockViewModel {
       return factory(
              login,
              accountType,
              unlockType,
              secureLockMode,
              unlocker,
              context,
              userSettings,
              resetMasterPasswordService,
              completion
       )
    }
}

extension LocalLoginUnlockViewModel {
        public typealias Factory = InjectedFactory<_LocalLoginUnlockViewModelFactory>
}


public typealias _LockPinCodeAndBiometryViewModelFactory = @MainActor (
    _ login: Login,
    _ accountType: AccountType,
    _ pinCodeLock: SecureLockMode.PinCodeLock,
    _ biometryType: Biometry?,
    _ context: LoginUnlockContext,
    _ unlocker: UnlockSessionHandler,
    _ completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void
) -> LockPinCodeAndBiometryViewModel

public extension InjectedFactory where T == _LockPinCodeAndBiometryViewModelFactory {
    @MainActor
    func make(login: Login, accountType: AccountType, pinCodeLock: SecureLockMode.PinCodeLock, biometryType: Biometry? = nil, context: LoginUnlockContext, unlocker: UnlockSessionHandler, completion: @escaping (LockPinCodeAndBiometryViewModel.Completion) -> Void) -> LockPinCodeAndBiometryViewModel {
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

public extension InjectedFactory where T == _LoginFlowViewModelFactory {
    @MainActor
    func make(login: Login?, deviceId: String?, loginHandler: LoginHandler, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, versionValidityAlertProvider: AlertContent, context: LocalLoginFlowContext, completion: @escaping (LoginFlowViewModel.Completion) -> Void) -> LoginFlowViewModel {
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

public extension InjectedFactory where T == _LoginViewModelFactory {
    @MainActor
    func make(email: String?, loginHandler: LoginHandler, staticErrorPublisher: AnyPublisher<Error?, Never>, versionValidityAlertProvider: AlertContent, completion: @escaping (LoginHandler.LoginResult?) -> Void) -> LoginViewModel {
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


public typealias _MasterPasswordLocalViewModelFactory = @MainActor (
    _ login: Login,
    _ biometry: Biometry?,
    _ authTicket: AuthTicket?,
    _ unlocker: UnlockSessionHandler,
    _ context: LoginUnlockContext,
    _ resetMasterPasswordService: ResetMasterPasswordServiceProtocol,
    _ userSettings: UserSettings,
    _ completion: @escaping (MasterPasswordLocalViewModel.CompletionMode?) -> Void
) -> MasterPasswordLocalViewModel

public extension InjectedFactory where T == _MasterPasswordLocalViewModelFactory {
    @MainActor
    func make(login: Login, biometry: Biometry?, authTicket: AuthTicket?, unlocker: UnlockSessionHandler, context: LoginUnlockContext, resetMasterPasswordService: ResetMasterPasswordServiceProtocol, userSettings: UserSettings, completion: @escaping (MasterPasswordLocalViewModel.CompletionMode?) -> Void) -> MasterPasswordLocalViewModel {
       return factory(
              login,
              biometry,
              authTicket,
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


public typealias _MasterPasswordRemoteViewModelFactory = @MainActor (
    _ login: Login,
    _ verificationMode: Definition.VerificationMode,
    _ isBackupCode: Bool,
    _ isExtension: Bool,
    _ validator: RegularRemoteLoginHandler,
    _ keys: LoginKeys,
    _ completion: @escaping () -> Void
) -> MasterPasswordRemoteViewModel

public extension InjectedFactory where T == _MasterPasswordRemoteViewModelFactory {
    @MainActor
    func make(login: Login, verificationMode: Definition.VerificationMode, isBackupCode: Bool, isExtension: Bool, validator: RegularRemoteLoginHandler, keys: LoginKeys, completion: @escaping () -> Void) -> MasterPasswordRemoteViewModel {
       return factory(
              login,
              verificationMode,
              isBackupCode,
              isExtension,
              validator,
              keys,
              completion
       )
    }
}

extension MasterPasswordRemoteViewModel {
        public typealias Factory = InjectedFactory<_MasterPasswordRemoteViewModelFactory>
}


public typealias _NitroSSOLoginViewModelFactory = @MainActor (
    _ login: String,
    _ completion: @escaping Completion<SSOCallbackInfos>
) -> NitroSSOLoginViewModel

public extension InjectedFactory where T == _NitroSSOLoginViewModelFactory {
    @MainActor
    func make(login: String, completion: @escaping Completion<SSOCallbackInfos>) -> NitroSSOLoginViewModel {
       return factory(
              login,
              completion
       )
    }
}

extension NitroSSOLoginViewModel {
        public typealias Factory = InjectedFactory<_NitroSSOLoginViewModelFactory>
}


public typealias _PasswordLessRecoveryViewModelFactory = @MainActor (
    _ login: Login,
    _ recoverFromFailure: Bool,
    _ completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void
) -> PasswordLessRecoveryViewModel

public extension InjectedFactory where T == _PasswordLessRecoveryViewModelFactory {
    @MainActor
    func make(login: Login, recoverFromFailure: Bool, completion: @escaping (PasswordLessRecoveryViewModel.CompletionResult) -> Void) -> PasswordLessRecoveryViewModel {
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


public typealias _RegularRemoteLoginFlowViewModelFactory = @MainActor (
    _ remoteLoginHandler: RegularRemoteLoginHandler,
    _ email: String,
    _ sessionActivityReporterProvider: SessionActivityReporterProvider,
    _ tokenPublisher: AnyPublisher<String, Never>,
    _ steps: [RegularRemoteLoginFlowViewModel.Step],
    _ completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.Completion, Error>) -> Void
) -> RegularRemoteLoginFlowViewModel

public extension InjectedFactory where T == _RegularRemoteLoginFlowViewModelFactory {
    @MainActor
    func make(remoteLoginHandler: RegularRemoteLoginHandler, email: String, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, steps: [RegularRemoteLoginFlowViewModel.Step] = [], completion: @MainActor @escaping (Result<RegularRemoteLoginFlowViewModel.Completion, Error>) -> Void) -> RegularRemoteLoginFlowViewModel {
       return factory(
              remoteLoginHandler,
              email,
              sessionActivityReporterProvider,
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
    _ type: LoginFlowViewModel.RemoteLoginType,
    _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
    _ sessionActivityReporterProvider: SessionActivityReporterProvider,
    _ tokenPublisher: AnyPublisher<String, Never>,
    _ completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
) -> RemoteLoginFlowViewModel

public extension InjectedFactory where T == _RemoteLoginFlowViewModelFactory {
    @MainActor
    func make(type: LoginFlowViewModel.RemoteLoginType, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void) -> RemoteLoginFlowViewModel {
       return factory(
              type,
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


public typealias _TOTPVerificationViewModelFactory = @MainActor (
    _ accountVerificationService: AccountVerificationService,
    _ recover2faWebService: Recover2FAWebService,
    _ pushType: PushType?,
    _ completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void
) -> TOTPVerificationViewModel

public extension InjectedFactory where T == _TOTPVerificationViewModelFactory {
    @MainActor
    func make(accountVerificationService: AccountVerificationService, recover2faWebService: Recover2FAWebService, pushType: PushType?, completion: @escaping (Result<(AuthTicket, Bool), Error>) -> Void) -> TOTPVerificationViewModel {
       return factory(
              accountVerificationService,
              recover2faWebService,
              pushType,
              completion
       )
    }
}

extension TOTPVerificationViewModel {
        public typealias Factory = InjectedFactory<_TOTPVerificationViewModelFactory>
}


public typealias _TokenVerificationViewModelFactory = @MainActor (
    _ tokenPublisher: AnyPublisher<String, Never>?,
    _ accountVerificationService: AccountVerificationService,
    _ completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void
) -> TokenVerificationViewModel

public extension InjectedFactory where T == _TokenVerificationViewModelFactory {
    @MainActor
    func make(tokenPublisher: AnyPublisher<String, Never>?, accountVerificationService: AccountVerificationService, completion: @MainActor @escaping (Result<AuthTicket, Error>) -> Void) -> TokenVerificationViewModel {
       return factory(
              tokenPublisher,
              accountVerificationService,
              completion
       )
    }
}

extension TokenVerificationViewModel {
        public typealias Factory = InjectedFactory<_TokenVerificationViewModelFactory>
}

