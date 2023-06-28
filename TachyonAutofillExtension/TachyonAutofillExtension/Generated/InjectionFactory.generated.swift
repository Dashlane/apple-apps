#if canImport(AuthenticationServices)
import AuthenticationServices
#endif
#if canImport(AutofillKit)
import AutofillKit
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(CoreActivityLogs)
import CoreActivityLogs
#endif
#if canImport(CoreFeature)
import CoreFeature
#endif
#if canImport(CoreKeychain)
import CoreKeychain
#endif
#if canImport(CoreNetworking)
import CoreNetworking
#endif
#if canImport(CorePasswords)
import CorePasswords
#endif
#if canImport(CorePersonalData)
import CorePersonalData
#endif
#if canImport(CorePremium)
import CorePremium
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
#if canImport(DashlaneAppKit)
import DashlaneAppKit
#endif
#if canImport(DomainParser)
import DomainParser
#endif
#if canImport(Foundation)
import Foundation
#endif
#if canImport(IconLibrary)
import IconLibrary
#endif
#if canImport(Logger)
import Logger
#endif
#if canImport(LoginKit)
import LoginKit
#endif
#if canImport(PremiumKit)
import PremiumKit
#endif
#if canImport(SwiftTreats)
import SwiftTreats
#endif
#if canImport(VaultKit)
import VaultKit
#endif

internal protocol AppServicesInjecting { }

 
extension AppServicesContainer {
        
        internal func makeLoginKitServicesContainer() -> LoginKitServicesContainer {
            return LoginKitServicesContainer(
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            sessionCleaner: sessionCleaner,
                            settingsManager: settingsManager,
                            keychainService: keychainService,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            appAPIClient: appAPIClient,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            sessionContainer: sessionsContainer,
                            rootLogger: rootLogger,
                            nitroWebService: nitroWebService,
                            passwordEvaluvator: passwordEvaluator
            )
        }
        
}

internal protocol SessionServicesInjecting { }

 
extension SessionServicesContainer {
        
        internal func makeCredentialLinkingViewModel(credential: Credential, visitedWebsite: String, completion: @escaping () -> Void) -> CredentialLinkingViewModel {
            return CredentialLinkingViewModel(
                            credential: credential,
                            visitedWebsite: visitedWebsite,
                            database: database,
                            autofillService: autofillService,
                            domainLibrary: domainIconLibrary,
                            teamSpacesService: teamSpacesService,
                            sessionActivityReporter: activityReporter,
                            activityLogsService: activityLogsService,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeCredentialListViewModel(passwordEvaluator: PasswordEvaluator, serviceIdentifiers: [ASCredentialServiceIdentifier], domainParser: DomainParser, openUrl: @MainActor @escaping (URL) -> Bool, completion: @escaping (CredentialSelection?) -> Void) -> CredentialListViewModel {
            return CredentialListViewModel(
                            syncService: syncService,
                            database: database,
                            autofillService: autofillService,
                            domainIconLibrary: domainIconLibrary,
                            logger: appServices.rootLogger,
                            session: session,
                            sessionActivityReporter: activityReporter,
                            personalDataURLDecoder: appServices.personalDataURLDecoder,
                            passwordEvaluator: passwordEvaluator,
                            userSettings: userSettings,
                            serviceIdentifiers: serviceIdentifiers,
                            teamSpacesService: teamSpacesService,
                            credentialLinkingViewModelFactory: InjectedFactory(makeCredentialLinkingViewModel),
                            domainParser: domainParser,
                            premiumStatus: premiumStatus,
                            associatedDomainsService: appServices.linkedDomainService,
                            featureService: featureService,
                            activityLogsService: activityLogsService,
                            openUrl: openUrl,
                            completion: completion
            )
        }
        
}


internal typealias _CredentialLinkingViewModelFactory =  (
    _ credential: Credential,
    _ visitedWebsite: String,
    _ completion: @escaping () -> Void
) -> CredentialLinkingViewModel

internal extension InjectedFactory where T == _CredentialLinkingViewModelFactory {
    
    func make(credential: Credential, visitedWebsite: String, completion: @escaping () -> Void) -> CredentialLinkingViewModel {
       return factory(
              credential,
              visitedWebsite,
              completion
       )
    }
}

extension CredentialLinkingViewModel {
        internal typealias Factory = InjectedFactory<_CredentialLinkingViewModelFactory>
}


internal typealias _CredentialListViewModelFactory = @MainActor (
    _ passwordEvaluator: PasswordEvaluator,
    _ serviceIdentifiers: [ASCredentialServiceIdentifier],
    _ domainParser: DomainParser,
    _ openUrl: @MainActor @escaping (URL) -> Bool,
    _ completion: @escaping (CredentialSelection?) -> Void
) -> CredentialListViewModel

internal extension InjectedFactory where T == _CredentialListViewModelFactory {
    @MainActor
    func make(passwordEvaluator: PasswordEvaluator, serviceIdentifiers: [ASCredentialServiceIdentifier], domainParser: DomainParser, openUrl: @MainActor @escaping (URL) -> Bool, completion: @escaping (CredentialSelection?) -> Void) -> CredentialListViewModel {
       return factory(
              passwordEvaluator,
              serviceIdentifiers,
              domainParser,
              openUrl,
              completion
       )
    }
}

extension CredentialListViewModel {
        internal typealias Factory = InjectedFactory<_CredentialListViewModelFactory>
}


public typealias _LoginKitServicesContainerFactory =  (
) -> LoginKitServicesContainer

public extension InjectedFactory where T == _LoginKitServicesContainerFactory {
    
    func make() -> LoginKitServicesContainer {
       return factory(
       )
    }
}

extension LoginKitServicesContainer {
        public typealias Factory = InjectedFactory<_LoginKitServicesContainerFactory>
}

