#if canImport(Combine)
import Combine
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
#if canImport(DashlaneCrypto)
import DashlaneCrypto
#endif
#if canImport(Foundation)
import Foundation
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
#if canImport(UIDelight)
import UIDelight
#endif
#if canImport(UIKit)
import UIKit
#endif

public protocol LoginKitServicesInjecting { }

 
extension LoginKitServicesContainer {
        @MainActor
        public func makeAuthenticatorPushViewModel(login: Login, validator: @escaping () async throws -> Void, completion: @escaping (AuthenticatorPushViewModel.CompletionType) -> Void) -> AuthenticatorPushViewModel {
            return AuthenticatorPushViewModel(
                            login: login,
                            validator: validator,
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
        public func makeDeviceUnlinkingFlowViewModel(deviceUnlinker: DeviceUnlinker, login: Login, session: RemoteLoginSession, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, completion: @escaping (DeviceUnlinkingFlowViewModel.Completion) -> Void) -> DeviceUnlinkingFlowViewModel {
            return DeviceUnlinkingFlowViewModel(
                            deviceUnlinker: deviceUnlinker,
                            login: login,
                            session: session,
                            loginUsageLogService: loginUsageLogService,
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
                            loginUsageLogService: loginUsageLogService,
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
                            loginUsageLogService: loginUsageLogService,
                            installerLogService: installerLogService,
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
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeLoginFlowViewModel(login: Login?, deviceId: String?, loginHandler: LoginHandler, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, versionValidityAlertProvider: AlertContent, completion: @escaping (LoginFlowViewModel.Completion) -> ()) -> LoginFlowViewModel {
            return LoginFlowViewModel(
                            login: login,
                            deviceId: deviceId,
                            logger: rootLogger,
                            loginHandler: loginHandler,
                            loginUsageLogService: loginUsageLogService,
                            keychainService: keychainService,
                            spiegelSettingsManager: settingsManager,
                            installerLogService: installerLogService,
                            localLoginViewModelFactory: InjectedFactory(makeLocalLoginFlowViewModel),
                            remoteLoginViewModelFactory: InjectedFactory(makeRemoteLoginFlowViewModel),
                            loginViewModelFactory: InjectedFactory(makeLoginViewModel),
                            purchasePlanFlowProvider: purchasePlanFlowProvider,
                            sessionActivityReporterProvider: sessionActivityReporterProvider,
                            tokenPublisher: tokenPublisher,
                            versionValidityAlertProvider: versionValidityAlertProvider,
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
                            sessionsContainer: sessionContainer,
                            activityReporter: activityReporter,
                            installerLogService: installerLogService,
                            loginUsageLogService: loginUsageLogService,
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
        public func makeMasterPasswordRemoteViewModel(login: Login, verificationMode: Definition.VerificationMode, isBackupCode: Bool, isExtension: Bool, validator: RemoteLoginHandler, keys: LoginKeys, completion: @escaping () -> Void) -> MasterPasswordRemoteViewModel {
            return MasterPasswordRemoteViewModel(
                            login: login,
                            verificationMode: verificationMode,
                            isBackupCode: isBackupCode,
                            isExtension: isExtension,
                            usageLogService: loginUsageLogService,
                            activityReporter: activityReporter,
                            validator: validator,
                            logger: rootLogger,
                            remoteLoginDelegate: remoteLoginInfoProvider,
                            installerLogService: installerLogService,
                            keys: keys,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeRemoteLoginFlowViewModel(remoteLoginHandler: RemoteLoginHandler, email: String, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void) -> RemoteLoginFlowViewModel {
            return RemoteLoginFlowViewModel(
                            remoteLoginHandler: remoteLoginHandler,
                            settingsManager: settingsManager,
                            loginUsageLogService: loginUsageLogService,
                            installerLogService: installerLogService,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            activityReporter: activityReporter,
                            remoteLoginInfoProvider: remoteLoginInfoProvider,
                            logger: rootLogger,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            appAPIClient: appAPIClient,
                            nitroWebService: nitroWebService,
                            keychainService: keychainService,
                            email: email,
                            purchasePlanFlowProvider: purchasePlanFlowProvider,
                            sessionActivityReporterProvider: sessionActivityReporterProvider,
                            tokenPublisher: tokenPublisher,
                            tokenFactory: InjectedFactory(makeTokenViewModel),
                            deviceUnlinkingFactory: InjectedFactory(makeDeviceUnlinkingFlowViewModel),
                            totpFactory: InjectedFactory(makeTOTPRemoteLoginViewModel),
                            authenticatorFactory: InjectedFactory(makeAuthenticatorPushViewModel),
                            masterPasswordFactory: InjectedFactory(makeMasterPasswordRemoteViewModel),
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeTOTPRemoteLoginViewModel(validator: ThirdPartyOTPDeviceRegistrationValidator, recover2faWebService: Recover2FAWebService, completion: @escaping (TOTPRemoteLoginViewModel.CompletionType) -> Void) -> TOTPRemoteLoginViewModel {
            return TOTPRemoteLoginViewModel(
                            validator: validator,
                            usageLogService: loginUsageLogService,
                            activityReporter: activityReporter,
                            recover2faWebService: recover2faWebService,
                            loginInstallerLogger: logger,
                            completion: completion
            )
        }
        
}

extension LoginKitServicesContainer {
        @MainActor
        public func makeTokenViewModel(tokenPublisher: AnyPublisher<String, Never>, validator: TokenDeviceRegistrationValidator, completion: @escaping (TokenViewModel.CompletionType) -> Void) -> TokenViewModel {
            return TokenViewModel(
                            tokenPublisher: tokenPublisher,
                            validator: validator,
                            networkEngine: appAPIClient,
                            activityReporter: activityReporter,
                            logger: logger,
                            completion: completion
            )
        }
        
}


public typealias _AuthenticatorPushViewModelFactory = @MainActor (
    _ login: Login,
    _ validator: @escaping () async throws -> Void,
    _ completion: @escaping (AuthenticatorPushViewModel.CompletionType) -> Void
) -> AuthenticatorPushViewModel

public extension InjectedFactory where T == _AuthenticatorPushViewModelFactory {
    @MainActor
    func make(login: Login, validator: @escaping () async throws -> Void, completion: @escaping (AuthenticatorPushViewModel.CompletionType) -> Void) -> AuthenticatorPushViewModel {
       return factory(
              login,
              validator,
              completion
       )
    }
}

extension AuthenticatorPushViewModel {
        public typealias Factory = InjectedFactory<_AuthenticatorPushViewModelFactory>
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


public typealias _LoginFlowViewModelFactory = @MainActor (
    _ login: Login?,
    _ deviceId: String?,
    _ loginHandler: LoginHandler,
    _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
    _ sessionActivityReporterProvider: SessionActivityReporterProvider,
    _ tokenPublisher: AnyPublisher<String, Never>,
    _ versionValidityAlertProvider: AlertContent,
    _ completion: @escaping (LoginFlowViewModel.Completion) -> ()
) -> LoginFlowViewModel

public extension InjectedFactory where T == _LoginFlowViewModelFactory {
    @MainActor
    func make(login: Login?, deviceId: String?, loginHandler: LoginHandler, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, versionValidityAlertProvider: AlertContent, completion: @escaping (LoginFlowViewModel.Completion) -> ()) -> LoginFlowViewModel {
       return factory(
              login,
              deviceId,
              loginHandler,
              purchasePlanFlowProvider,
              sessionActivityReporterProvider,
              tokenPublisher,
              versionValidityAlertProvider,
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


public typealias _MasterPasswordRemoteViewModelFactory = @MainActor (
    _ login: Login,
    _ verificationMode: Definition.VerificationMode,
    _ isBackupCode: Bool,
    _ isExtension: Bool,
    _ validator: RemoteLoginHandler,
    _ keys: LoginKeys,
    _ completion: @escaping () -> Void
) -> MasterPasswordRemoteViewModel

public extension InjectedFactory where T == _MasterPasswordRemoteViewModelFactory {
    @MainActor
    func make(login: Login, verificationMode: Definition.VerificationMode, isBackupCode: Bool, isExtension: Bool, validator: RemoteLoginHandler, keys: LoginKeys, completion: @escaping () -> Void) -> MasterPasswordRemoteViewModel {
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


public typealias _RemoteLoginFlowViewModelFactory = @MainActor (
    _ remoteLoginHandler: RemoteLoginHandler,
    _ email: String,
    _ purchasePlanFlowProvider: PurchasePlanFlowProvider,
    _ sessionActivityReporterProvider: SessionActivityReporterProvider,
    _ tokenPublisher: AnyPublisher<String, Never>,
    _ completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void
) -> RemoteLoginFlowViewModel

public extension InjectedFactory where T == _RemoteLoginFlowViewModelFactory {
    @MainActor
    func make(remoteLoginHandler: RemoteLoginHandler, email: String, purchasePlanFlowProvider: PurchasePlanFlowProvider, sessionActivityReporterProvider: SessionActivityReporterProvider, tokenPublisher: AnyPublisher<String, Never>, completion: @MainActor @escaping (Result<RemoteLoginFlowViewModel.Completion, Error>) -> Void) -> RemoteLoginFlowViewModel {
       return factory(
              remoteLoginHandler,
              email,
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


public typealias _TOTPRemoteLoginViewModelFactory = @MainActor (
    _ validator: ThirdPartyOTPDeviceRegistrationValidator,
    _ recover2faWebService: Recover2FAWebService,
    _ completion: @escaping (TOTPRemoteLoginViewModel.CompletionType) -> Void
) -> TOTPRemoteLoginViewModel

public extension InjectedFactory where T == _TOTPRemoteLoginViewModelFactory {
    @MainActor
    func make(validator: ThirdPartyOTPDeviceRegistrationValidator, recover2faWebService: Recover2FAWebService, completion: @escaping (TOTPRemoteLoginViewModel.CompletionType) -> Void) -> TOTPRemoteLoginViewModel {
       return factory(
              validator,
              recover2faWebService,
              completion
       )
    }
}

extension TOTPRemoteLoginViewModel {
        public typealias Factory = InjectedFactory<_TOTPRemoteLoginViewModelFactory>
}


public typealias _TokenViewModelFactory = @MainActor (
    _ tokenPublisher: AnyPublisher<String, Never>,
    _ validator: TokenDeviceRegistrationValidator,
    _ completion: @escaping (TokenViewModel.CompletionType) -> Void
) -> TokenViewModel

public extension InjectedFactory where T == _TokenViewModelFactory {
    @MainActor
    func make(tokenPublisher: AnyPublisher<String, Never>, validator: TokenDeviceRegistrationValidator, completion: @escaping (TokenViewModel.CompletionType) -> Void) -> TokenViewModel {
       return factory(
              tokenPublisher,
              validator,
              completion
       )
    }
}

extension TokenViewModel {
        public typealias Factory = InjectedFactory<_TokenViewModelFactory>
}

