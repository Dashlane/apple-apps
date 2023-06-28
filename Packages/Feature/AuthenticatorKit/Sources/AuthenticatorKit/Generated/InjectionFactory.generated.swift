#if canImport(Combine)
import Combine
#endif
#if canImport(CoreCategorizer)
import CoreCategorizer
#endif
#if canImport(CoreNetworking)
import CoreNetworking
#endif
#if canImport(CorePersonalData)
import CorePersonalData
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
#if canImport(Foundation)
import Foundation
#endif
#if canImport(IconLibrary)
import IconLibrary
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(TOTPGenerator)
import TOTPGenerator
#endif

public protocol AuthenticatorMockInjecting { }

 
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
        
        public func makePlaceholderWebsiteViewModel(website: String) -> PlaceholderWebsiteViewModel {
            return PlaceholderWebsiteViewModel(
                            website: website,
                            domainIconLibrary: domainIconLibrary
            )
        }
        
}

public protocol AuthenticatorServicesInjecting { }

 
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
        
        public func makePlaceholderWebsiteViewModel(website: String) -> PlaceholderWebsiteViewModel {
            return PlaceholderWebsiteViewModel(
                            website: website,
                            domainIconLibrary: domainIconLibrary
            )
        }
        
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

