#if canImport(AuthenticatorKit)
import AuthenticatorKit
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(CoreCategorizer)
import CoreCategorizer
#endif
#if canImport(CoreKeychain)
import CoreKeychain
#endif
#if canImport(CoreNetworking)
import CoreNetworking
#endif
#if canImport(CorePersonalData)
import CorePersonalData
#endif
#if canImport(CoreSession)
import CoreSession
#endif
#if canImport(CoreSync)
import CoreSync
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
#if canImport(SwiftTreats)
import SwiftTreats
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(TOTPGenerator)
import TOTPGenerator
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(VaultKit)
import VaultKit
#endif

public protocol AppServicesInjecting { }

 
public protocol AuthenticatorMockInjecting { }

 
extension AuthenticatorMockContainer {
        @MainActor
        internal func makeAddItemFlowViewModel(hasAtLeastOneTokenStoredInVault: Bool, mode: AddItemMode, skipIntro: Bool = false, completion: @escaping (OTPInfo) -> Void) -> AddItemFlowViewModel {
            return AddItemFlowViewModel(
                            databaseService: database,
                            hasAtLeastOneTokenStoredInVault: hasAtLeastOneTokenStoredInVault,
                            mode: mode,
                            legacyWebService: legacyWebService,
                            logger: logger,
                            activityReporter: activityReporter,
                            addItemViewModelFactory: InjectedFactory(makeAddItemManuallyFlowViewModel),
                            scanCodeViewModelFactory: InjectedFactory(makeAddItemScanCodeFlowViewModel),
                            skipIntro: skipIntro,
                            completion: completion
            )
        }
        
}

extension AuthenticatorMockContainer {
        @MainActor
        internal func makeAddItemManuallyFlowViewModel(mode: AddItemMode, isFirstToken: Bool, didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) -> AddItemManuallyFlowViewModel {
            return AddItemManuallyFlowViewModel(
                            databaseService: database,
                            chooseWebSiteViewModelFactory: InjectedFactory(makeChooseWebsiteViewModel),
                            addLoginDetailsViewModelFactory: InjectedFactory(makeAddLoginDetailsViewModel),
                            scanCodeViewModelFactory: InjectedFactory(makeAddItemScanCodeFlowViewModel),
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            tokenRowViewModelFactory: InjectedFactory(makeTokenRowViewModel),
                            mode: mode,
                            isFirstToken: isFirstToken,
                            didCreate: didCreate
            )
        }
        
}

extension AuthenticatorMockContainer {
        @MainActor
        internal func makeAddItemScanCodeFlowViewModel(otpInfo: OTPInfo? = nil, mode: AddItemMode, isFirstToken: Bool, didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) -> AddItemScanCodeFlowViewModel {
            return AddItemScanCodeFlowViewModel(
                            otpInfo: otpInfo,
                            databaseService: database,
                            tokenRowViewModelFactory: InjectedFactory(makeTokenRowViewModel),
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            addManuallyViewModelFactory: InjectedFactory(makeAddItemManuallyFlowViewModel),
                            mode: mode,
                            logger: logger,
                            isFirstToken: isFirstToken,
                            didCreate: didCreate
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        public func makeAddLoginDetailsViewModel(website: String, credential: Credential?, supportDashlane2FA: Bool, completion: @escaping (OTPInfo) -> Void) -> AddLoginDetailsViewModel {
            return AddLoginDetailsViewModel(
                            website: website,
                            credential: credential,
                            supportDashlane2FA: supportDashlane2FA,
                            completion: completion
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        public func makeChooseWebsiteViewModel(completion: @escaping (String) -> Void) -> ChooseWebsiteViewModel {
            return ChooseWebsiteViewModel(
                            categorizer: categorizer,
                            activityReporter: activityReporter,
                            placeholderViewModelFactory: InjectedFactory(makePlaceholderWebsiteViewModel),
                            completion: completion
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        internal func makeCredentialRowViewModel(item: VaultItem) -> CredentialRowViewModel {
            return CredentialRowViewModel(
                            item: item,
                            domainLibrary: domainIconLibrary
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        internal func makeMatchingCredentialListViewModel(website: String, matchingCredentials: [Credential], completion: @escaping (MatchingCredentialListViewModelCompletion) -> Void) -> MatchingCredentialListViewModel {
            return MatchingCredentialListViewModel(
                            website: website,
                            matchingCredentials: matchingCredentials,
                            credentialRowFactory: InjectedFactory(makeCredentialRowViewModel),
                            completion: completion
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        public func makePlaceholderWebsiteViewModel(website: String) -> PlaceholderWebsiteViewModel {
            return PlaceholderWebsiteViewModel(
                            website: website,
                            domainIconLibrary: domainIconLibrary
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        internal func makeTokenListViewModel(didDelete: @escaping (OTPInfo) -> Void) -> TokenListViewModel {
            return TokenListViewModel(
                            databaseService: database,
                            tokenRowViewModelFactory: InjectedFactory(makeTokenRowViewModel),
                            didDelete: didDelete
            )
        }
        
}

extension AuthenticatorMockContainer {
        
        internal func makeTokenRowViewModel(token: OTPInfo, dashlaneTokenCaption: String = "") -> TokenRowViewModel {
            return TokenRowViewModel(
                            token: token,
                            dashlaneTokenCaption: dashlaneTokenCaption,
                            domainIconLibrary: domainIconLibrary,
                            databaseService: database,
                            domainParser: domainParser
            )
        }
        
}

public protocol AuthenticatorServicesInjecting { }

 
extension AuthenticatorServicesContainer {
        @MainActor
        internal func makeAddItemFlowViewModel(hasAtLeastOneTokenStoredInVault: Bool, mode: AddItemMode, skipIntro: Bool = false, completion: @escaping (OTPInfo) -> Void) -> AddItemFlowViewModel {
            return AddItemFlowViewModel(
                            databaseService: databaseService,
                            hasAtLeastOneTokenStoredInVault: hasAtLeastOneTokenStoredInVault,
                            mode: mode,
                            legacyWebService: legacyWebservice,
                            logger: logger,
                            activityReporter: authenticatorActivityReporter,
                            addItemViewModelFactory: InjectedFactory(makeAddItemManuallyFlowViewModel),
                            scanCodeViewModelFactory: InjectedFactory(makeAddItemScanCodeFlowViewModel),
                            skipIntro: skipIntro,
                            completion: completion
            )
        }
        
}

extension AuthenticatorServicesContainer {
        @MainActor
        internal func makeAddItemManuallyFlowViewModel(mode: AddItemMode, isFirstToken: Bool, didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) -> AddItemManuallyFlowViewModel {
            return AddItemManuallyFlowViewModel(
                            databaseService: databaseService,
                            chooseWebSiteViewModelFactory: InjectedFactory(makeChooseWebsiteViewModel),
                            addLoginDetailsViewModelFactory: InjectedFactory(makeAddLoginDetailsViewModel),
                            scanCodeViewModelFactory: InjectedFactory(makeAddItemScanCodeFlowViewModel),
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            tokenRowViewModelFactory: InjectedFactory(makeTokenRowViewModel),
                            mode: mode,
                            isFirstToken: isFirstToken,
                            didCreate: didCreate
            )
        }
        
}

extension AuthenticatorServicesContainer {
        @MainActor
        internal func makeAddItemScanCodeFlowViewModel(otpInfo: OTPInfo? = nil, mode: AddItemMode, isFirstToken: Bool, didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) -> AddItemScanCodeFlowViewModel {
            return AddItemScanCodeFlowViewModel(
                            otpInfo: otpInfo,
                            databaseService: databaseService,
                            tokenRowViewModelFactory: InjectedFactory(makeTokenRowViewModel),
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            addManuallyViewModelFactory: InjectedFactory(makeAddItemManuallyFlowViewModel),
                            mode: mode,
                            logger: logger,
                            isFirstToken: isFirstToken,
                            didCreate: didCreate
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        public func makeAddLoginDetailsViewModel(website: String, credential: Credential?, supportDashlane2FA: Bool, completion: @escaping (OTPInfo) -> Void) -> AddLoginDetailsViewModel {
            return AddLoginDetailsViewModel(
                            website: website,
                            credential: credential,
                            supportDashlane2FA: supportDashlane2FA,
                            completion: completion
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        public func makeChooseWebsiteViewModel(completion: @escaping (String) -> Void) -> ChooseWebsiteViewModel {
            return ChooseWebsiteViewModel(
                            categorizer: authenticatorCategorizer,
                            activityReporter: authenticatorActivityReporter,
                            placeholderViewModelFactory: InjectedFactory(makePlaceholderWebsiteViewModel),
                            completion: completion
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        internal func makeCredentialRowViewModel(item: VaultItem) -> CredentialRowViewModel {
            return CredentialRowViewModel(
                            item: item,
                            domainLibrary: domainIconLibrary
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        internal func makeDownloadDashlaneViewModel(showAppStorePage: @escaping (AppStoreProductViewer) -> Void) -> DownloadDashlaneViewModel {
            return DownloadDashlaneViewModel(
                            activityReporter: authenticatorActivityReporter,
                            showAppStorePage: showAppStorePage
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        internal func makeMatchingCredentialListViewModel(website: String, matchingCredentials: [Credential], completion: @escaping (MatchingCredentialListViewModelCompletion) -> Void) -> MatchingCredentialListViewModel {
            return MatchingCredentialListViewModel(
                            website: website,
                            matchingCredentials: matchingCredentials,
                            credentialRowFactory: InjectedFactory(makeCredentialRowViewModel),
                            completion: completion
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        public func makePlaceholderWebsiteViewModel(website: String) -> PlaceholderWebsiteViewModel {
            return PlaceholderWebsiteViewModel(
                            website: website,
                            domainIconLibrary: domainIconLibrary
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        internal func makeTokenListViewModel(didDelete: @escaping (OTPInfo) -> Void) -> TokenListViewModel {
            return TokenListViewModel(
                            databaseService: databaseService,
                            tokenRowViewModelFactory: InjectedFactory(makeTokenRowViewModel),
                            didDelete: didDelete
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        internal func makeTokenRowViewModel(token: OTPInfo, dashlaneTokenCaption: String = "") -> TokenRowViewModel {
            return TokenRowViewModel(
                            token: token,
                            dashlaneTokenCaption: dashlaneTokenCaption,
                            domainIconLibrary: domainIconLibrary,
                            databaseService: databaseService,
                            domainParser: domainParser
            )
        }
        
}

extension AuthenticatorServicesContainer {
        
        internal func makeUnlockViewModel(login: Login, authenticationMode: AuthenticationMode, loginOTPOption: ThirdPartyOTPOption?, validateMasterKey: @escaping (CoreKeychain.MasterKey, Login, AuthenticationMode, ThirdPartyOTPOption?) async throws -> PairedServicesContainer, completion: @escaping (PairedServicesContainer) -> Void) -> UnlockViewModel {
            return UnlockViewModel(
                            login: login,
                            authenticationMode: authenticationMode,
                            loginOTPOption: loginOTPOption,
                            keychainService: keychainService,
                            sessionContainer: sessionsContainer,
                            validateMasterKey: validateMasterKey,
                            completion: completion
            )
        }
        
}

internal protocol PairedServicesInjecting { }

 
internal protocol StandAloneServicesInjecting { }

 

internal typealias _AddItemFlowViewModelFactory = @MainActor (
    _ hasAtLeastOneTokenStoredInVault: Bool,
    _ mode: AddItemMode,
    _ skipIntro: Bool,
    _ completion: @escaping (OTPInfo) -> Void
) -> AddItemFlowViewModel

internal extension InjectedFactory where T == _AddItemFlowViewModelFactory {
    @MainActor
    func make(hasAtLeastOneTokenStoredInVault: Bool, mode: AddItemMode, skipIntro: Bool = false, completion: @escaping (OTPInfo) -> Void) -> AddItemFlowViewModel {
       return factory(
              hasAtLeastOneTokenStoredInVault,
              mode,
              skipIntro,
              completion
       )
    }
}

extension AddItemFlowViewModel {
        internal typealias Factory = InjectedFactory<_AddItemFlowViewModelFactory>
}


internal typealias _AddItemManuallyFlowViewModelFactory = @MainActor (
    _ mode: AddItemMode,
    _ isFirstToken: Bool,
    _ didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void
) -> AddItemManuallyFlowViewModel

internal extension InjectedFactory where T == _AddItemManuallyFlowViewModelFactory {
    @MainActor
    func make(mode: AddItemMode, isFirstToken: Bool, didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) -> AddItemManuallyFlowViewModel {
       return factory(
              mode,
              isFirstToken,
              didCreate
       )
    }
}

extension AddItemManuallyFlowViewModel {
        internal typealias Factory = InjectedFactory<_AddItemManuallyFlowViewModelFactory>
}


internal typealias _AddItemScanCodeFlowViewModelFactory = @MainActor (
    _ otpInfo: OTPInfo?,
    _ mode: AddItemMode,
    _ isFirstToken: Bool,
    _ didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void
) -> AddItemScanCodeFlowViewModel

internal extension InjectedFactory where T == _AddItemScanCodeFlowViewModelFactory {
    @MainActor
    func make(otpInfo: OTPInfo? = nil, mode: AddItemMode, isFirstToken: Bool, didCreate: @escaping (OTPInfo, Definition.OtpAdditionMode) -> Void) -> AddItemScanCodeFlowViewModel {
       return factory(
              otpInfo,
              mode,
              isFirstToken,
              didCreate
       )
    }
}

extension AddItemScanCodeFlowViewModel {
        internal typealias Factory = InjectedFactory<_AddItemScanCodeFlowViewModelFactory>
}


public typealias _AddLoginDetailsViewModelFactory =  (
    _ website: String,
    _ credential: Credential?,
    _ supportDashlane2FA: Bool,
    _ completion: @escaping (OTPInfo) -> Void
) -> AddLoginDetailsViewModel

public extension InjectedFactory where T == _AddLoginDetailsViewModelFactory {
    
    func make(website: String, credential: Credential?, supportDashlane2FA: Bool, completion: @escaping (OTPInfo) -> Void) -> AddLoginDetailsViewModel {
       return factory(
              website,
              credential,
              supportDashlane2FA,
              completion
       )
    }
}

extension AddLoginDetailsViewModel {
        public typealias Factory = InjectedFactory<_AddLoginDetailsViewModelFactory>
}


public typealias _ChooseWebsiteViewModelFactory =  (
    _ completion: @escaping (String) -> Void
) -> ChooseWebsiteViewModel

public extension InjectedFactory where T == _ChooseWebsiteViewModelFactory {
    
    func make(completion: @escaping (String) -> Void) -> ChooseWebsiteViewModel {
       return factory(
              completion
       )
    }
}

extension ChooseWebsiteViewModel {
        public typealias Factory = InjectedFactory<_ChooseWebsiteViewModelFactory>
}


internal typealias _CredentialRowViewModelFactory =  (
    _ item: VaultItem
) -> CredentialRowViewModel

internal extension InjectedFactory where T == _CredentialRowViewModelFactory {
    
    func make(item: VaultItem) -> CredentialRowViewModel {
       return factory(
              item
       )
    }
}

extension CredentialRowViewModel {
        internal typealias Factory = InjectedFactory<_CredentialRowViewModelFactory>
}


internal typealias _DownloadDashlaneViewModelFactory =  (
    _ showAppStorePage: @escaping (AppStoreProductViewer) -> Void
) -> DownloadDashlaneViewModel

internal extension InjectedFactory where T == _DownloadDashlaneViewModelFactory {
    
    func make(showAppStorePage: @escaping (AppStoreProductViewer) -> Void) -> DownloadDashlaneViewModel {
       return factory(
              showAppStorePage
       )
    }
}

extension DownloadDashlaneViewModel {
        internal typealias Factory = InjectedFactory<_DownloadDashlaneViewModelFactory>
}


internal typealias _MatchingCredentialListViewModelFactory =  (
    _ website: String,
    _ matchingCredentials: [Credential],
    _ completion: @escaping (MatchingCredentialListViewModelCompletion) -> Void
) -> MatchingCredentialListViewModel

internal extension InjectedFactory where T == _MatchingCredentialListViewModelFactory {
    
    func make(website: String, matchingCredentials: [Credential], completion: @escaping (MatchingCredentialListViewModelCompletion) -> Void) -> MatchingCredentialListViewModel {
       return factory(
              website,
              matchingCredentials,
              completion
       )
    }
}

extension MatchingCredentialListViewModel {
        internal typealias Factory = InjectedFactory<_MatchingCredentialListViewModelFactory>
}


public typealias _PlaceholderWebsiteViewModelFactory =  (
    _ website: String
) -> PlaceholderWebsiteViewModel

public extension InjectedFactory where T == _PlaceholderWebsiteViewModelFactory {
    
    func make(website: String) -> PlaceholderWebsiteViewModel {
       return factory(
              website
       )
    }
}

extension PlaceholderWebsiteViewModel {
        public typealias Factory = InjectedFactory<_PlaceholderWebsiteViewModelFactory>
}


internal typealias _TokenListViewModelFactory =  (
    _ didDelete: @escaping (OTPInfo) -> Void
) -> TokenListViewModel

internal extension InjectedFactory where T == _TokenListViewModelFactory {
    
    func make(didDelete: @escaping (OTPInfo) -> Void) -> TokenListViewModel {
       return factory(
              didDelete
       )
    }
}

extension TokenListViewModel {
        internal typealias Factory = InjectedFactory<_TokenListViewModelFactory>
}


internal typealias _TokenRowViewModelFactory =  (
    _ token: OTPInfo,
    _ dashlaneTokenCaption: String
) -> TokenRowViewModel

internal extension InjectedFactory where T == _TokenRowViewModelFactory {
    
    func make(token: OTPInfo, dashlaneTokenCaption: String = "") -> TokenRowViewModel {
       return factory(
              token,
              dashlaneTokenCaption
       )
    }
}

extension TokenRowViewModel {
        internal typealias Factory = InjectedFactory<_TokenRowViewModelFactory>
}


internal typealias _UnlockViewModelFactory =  (
    _ login: Login,
    _ authenticationMode: AuthenticationMode,
    _ loginOTPOption: ThirdPartyOTPOption?,
    _ validateMasterKey: @escaping (CoreKeychain.MasterKey, Login, AuthenticationMode, ThirdPartyOTPOption?) async throws -> PairedServicesContainer,
    _ completion: @escaping (PairedServicesContainer) -> Void
) -> UnlockViewModel

internal extension InjectedFactory where T == _UnlockViewModelFactory {
    
    func make(login: Login, authenticationMode: AuthenticationMode, loginOTPOption: ThirdPartyOTPOption?, validateMasterKey: @escaping (CoreKeychain.MasterKey, Login, AuthenticationMode, ThirdPartyOTPOption?) async throws -> PairedServicesContainer, completion: @escaping (PairedServicesContainer) -> Void) -> UnlockViewModel {
       return factory(
              login,
              authenticationMode,
              loginOTPOption,
              validateMasterKey,
              completion
       )
    }
}

extension UnlockViewModel {
        internal typealias Factory = InjectedFactory<_UnlockViewModelFactory>
}

