#if canImport(Cocoa)
import Cocoa
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(CoreFeature)
import CoreFeature
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
#if canImport(DashlaneReportKit)
import DashlaneReportKit
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
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(TOTPGenerator)
import TOTPGenerator
#endif
#if canImport(UIDelight)
import UIDelight
#endif
#if canImport(VaultKit)
import VaultKit
#endif

internal protocol SessionServicesInjecting { }

 
extension SessionServicesContainer {
        
        internal func makeAskForBiometryHandler(maverickOrderMessage: MaverickOrderMessage) -> AskForBiometryHandler {
            return AskForBiometryHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            localAuthenticationService: localAuthenticationInformationService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAuthenticatedAnalysisStatusHandler() -> AuthenticatedAnalysisStatusHandler {
            return AuthenticatedAnalysisStatusHandler(
                            premiumService: premiumService,
                            userEncryptedSettings: spiegelUserEncryptedSettings,
                            domainParser: appServices.domainParser,
                            killSwitchService: appServices.killSwitchService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAutofillTabViewModel() -> AutofillTabViewModel {
            return AutofillTabViewModel(
                            domainParser: appServices.domainParser,
                            userEncryptedSettings: spiegelUserEncryptedSettings,
                            popoverOpeningService: appServices.popoverOpeningService,
                            autofillService: appServices.autofillService,
                            premiumService: premiumService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCheckMasterPasswordHandler(maverickOrderMessage: MaverickOrderMessage) -> CheckMasterPasswordHandler {
            return CheckMasterPasswordHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            localAuthenticationService: localAuthenticationInformationService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCredentialDetailsViewModel(credential: Credential, iconViewModel: VaultItemIconViewModel) -> CredentialDetailsViewModel {
            return CredentialDetailsViewModel(
                            credential: credential,
                            iconViewModel: iconViewModel,
                            pasteboardService: pasteboardService,
                            sharingService: sharingService,
                            vaultItemService: vaultItemsService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCredentialRowViewModel(item: Credential) -> CredentialRowViewModel {
            return CredentialRowViewModel(
                            item: item,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            featureService: featureService,
                            usageLogService: usageLogService,
                            vaultItemsService: vaultItemsService,
                            activityReporter: activityReporter,
                            pasteboardService: pasteboardService,
                            iconViewModelProvider: makeVaultItemIconViewModel
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCredentialsListViewModel(makeCredentialsRowViewModels: @escaping ([Credential]) -> [CredentialRowViewModel]) -> CredentialsListViewModel {
            return CredentialsListViewModel(
                            vaultItemsService: vaultItemsService,
                            syncService: syncService,
                            iconService: iconService,
                            popoverOpeningService: appServices.popoverOpeningService,
                            makeCredentialsRowViewModels: makeCredentialsRowViewModels,
                            makeCredentialDetailsViewModel: makeCredentialDetailsViewModel
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDataRequestHandler(maverickOrderMessage: MaverickOrderMessage) -> DataRequestHandler {
            return DataRequestHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            domainParser: appServices.domainParser,
                            premiumService: premiumService,
                            vaultItemsService: vaultItemsService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeEvaluatePasswordHandler(maverickOrderMessage: MaverickOrderMessage) -> EvaluatePasswordHandler {
            return EvaluatePasswordHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            passwordEvaluator: appServices.passwordEvaluator
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeFetchSpacesInfoHandler(maverickOrderMessage: MaverickOrderMessage) -> FetchSpacesInfoHandler {
            return FetchSpacesInfoHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            premiumService: premiumService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGenerateAndEvaluatePasswordHandler(maverickOrderMessage: MaverickOrderMessage) -> GenerateAndEvaluatePasswordHandler {
            return GenerateAndEvaluatePasswordHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            passwordEvaluator: appServices.passwordEvaluator,
                            personalDataURLDecoder: appServices.personalDataURLDecoder,
                            database: database,
                            userSettings: spiegelUserSettings
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGeneratePasswordHandler(maverickOrderMessage: MaverickOrderMessage) -> GeneratePasswordHandler {
            return GeneratePasswordHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            passwordEvaluator: appServices.passwordEvaluator
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGetOTPForCredentialHandler(maverickOrderMessage: MaverickOrderMessage) -> GetOTPForCredentialHandler {
            return GetOTPForCredentialHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            vaultItemsService: vaultItemsService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGetPasswordGenerationSettingsHandler(maverickOrderMessage: MaverickOrderMessage) -> GetPasswordGenerationSettingsHandler {
            return GetPasswordGenerationSettingsHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            userSettings: spiegelUserSettings
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeIsAutofillPasswordProtectedHandler(maverickOrderMessage: MaverickOrderMessage) -> IsAutofillPasswordProtectedHandler {
            return IsAutofillPasswordProtectedHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            localAuthenticationService: localAuthenticationInformationService,
                            vaultItemsService: vaultItemsService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeIsPasswordLimitReachedHandler(maverickOrderMessage: MaverickOrderMessage) -> IsPasswordLimitReachedHandler {
            return IsPasswordLimitReachedHandler(
                            maverickOrderMessage: maverickOrderMessage
            )
        }
        
}

extension SessionServicesContainer {

}

extension SessionServicesContainer {
        
        internal func makeMaverickUsageLogHandler(maverickOrderMessage: MaverickOrderMessage) -> MaverickUsageLogHandler {
            return MaverickUsageLogHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            usageLogService: usageLogService,
                            logger: appServices.rootLogger
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeMoreTabViewModel(login: String) -> MoreTabViewModel {
            return MoreTabViewModel(
                            communicationService: appServices.communicationService,
                            login: login
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeObjectsAutofilledHandler(maverickOrderMessage: MaverickOrderMessage) -> ObjectsAutofilledHandler {
            return ObjectsAutofilledHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            database: database
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordGeneratorTabViewModel() -> PasswordGeneratorTabViewModel {
            return PasswordGeneratorTabViewModel(
                            passwordGeneratorViewModelFactory: InjectedFactory(makePasswordGeneratorViewModel),
                            database: database,
                            userSettings: spiegelUserSettings,
                            activityReporter: activityReporter,
                            iconService: iconService,
                            popoverOpeningService: appServices.popoverOpeningService,
                            pasteboardService: pasteboardService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            saveGeneratedPassword: saveGeneratedPassword,
                            passwordEvaluator: appServices.passwordEvaluator,
                            usageLogService: usageLogService,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            savePreferencesOnChange: savePreferencesOnChange
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: appServices.passwordEvaluator,
                            usageLogService: usageLogService,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            savePreferencesOnChange: savePreferencesOnChange
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: appServices.passwordEvaluator,
                            usageLogService: usageLogService,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordHistoryRowViewModel(generatedPassword: GeneratedPassword) -> PasswordHistoryRowViewModel {
            return PasswordHistoryRowViewModel(
                            generatedPassword: generatedPassword,
                            pasteboardService: pasteboardService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSaveCredentialDisabledHandler(maverickOrderMessage: MaverickOrderMessage) -> SaveCredentialDisabledHandler {
            return SaveCredentialDisabledHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            spiegelUserSettings: spiegelUserSettings
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSaveGeneratedPasswordHandler(maverickOrderMessage: MaverickOrderMessage) -> SaveGeneratedPasswordHandler {
            return SaveGeneratedPasswordHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            personalDataURLDecoder: appServices.personalDataURLDecoder,
                            database: database
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSaveRequestHandler(maverickOrderMessage: MaverickOrderMessage) -> SaveRequestHandler {
            return SaveRequestHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            database: database,
                            vaultItemsService: vaultItemsService,
                            personalDataURLDecoder: appServices.personalDataURLDecoder,
                            regionInformationService: appServices.regionInformationService,
                            logger: appServices.rootLogger
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSignalSaveCredentialDisabledHandler(maverickOrderMessage: MaverickOrderMessage) -> SignalSaveCredentialDisabledHandler {
            return SignalSaveCredentialDisabledHandler(
                            maverickOrderMessage: maverickOrderMessage,
                            spiegelUserSettings: spiegelUserSettings
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVaultItemIconViewModel(item: VaultItem) -> VaultItemIconViewModel {
            return VaultItemIconViewModel(
                            item: item,
                            iconService: iconService
            )
        }
                
        internal func makeVaultItemIconViewModel(item: VaultItem, iconLibrary: DomainIconLibraryProtocol) -> VaultItemIconViewModel {
            return VaultItemIconViewModel(
                            item: item,
                            iconLibrary: iconLibrary
            )
        }
        
}


internal typealias _AskForBiometryHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> AskForBiometryHandler

internal extension InjectedFactory where T == _AskForBiometryHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> AskForBiometryHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension AskForBiometryHandler {
        internal typealias Factory = InjectedFactory<_AskForBiometryHandlerFactory>
}


internal typealias _AuthenticatedAnalysisStatusHandlerFactory =  (
) -> AuthenticatedAnalysisStatusHandler

internal extension InjectedFactory where T == _AuthenticatedAnalysisStatusHandlerFactory {
    
    func make() -> AuthenticatedAnalysisStatusHandler {
       return factory(
       )
    }
}

extension AuthenticatedAnalysisStatusHandler {
        internal typealias Factory = InjectedFactory<_AuthenticatedAnalysisStatusHandlerFactory>
}


internal typealias _AutofillTabViewModelFactory =  (
) -> AutofillTabViewModel

internal extension InjectedFactory where T == _AutofillTabViewModelFactory {
    
    func make() -> AutofillTabViewModel {
       return factory(
       )
    }
}

extension AutofillTabViewModel {
        internal typealias Factory = InjectedFactory<_AutofillTabViewModelFactory>
}


internal typealias _CheckMasterPasswordHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> CheckMasterPasswordHandler

internal extension InjectedFactory where T == _CheckMasterPasswordHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> CheckMasterPasswordHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension CheckMasterPasswordHandler {
        internal typealias Factory = InjectedFactory<_CheckMasterPasswordHandlerFactory>
}


internal typealias _CredentialDetailsViewModelFactory =  (
    _ credential: Credential,
    _ iconViewModel: VaultItemIconViewModel
) -> CredentialDetailsViewModel

internal extension InjectedFactory where T == _CredentialDetailsViewModelFactory {
    
    func make(credential: Credential, iconViewModel: VaultItemIconViewModel) -> CredentialDetailsViewModel {
       return factory(
              credential,
              iconViewModel
       )
    }
}

extension CredentialDetailsViewModel {
        internal typealias Factory = InjectedFactory<_CredentialDetailsViewModelFactory>
}


internal typealias _CredentialRowViewModelFactory =  (
    _ item: Credential
) -> CredentialRowViewModel

internal extension InjectedFactory where T == _CredentialRowViewModelFactory {
    
    func make(item: Credential) -> CredentialRowViewModel {
       return factory(
              item
       )
    }
}

extension CredentialRowViewModel {
        internal typealias Factory = InjectedFactory<_CredentialRowViewModelFactory>
}


internal typealias _CredentialsListViewModelFactory =  (
    _ makeCredentialsRowViewModels: @escaping ([Credential]) -> [CredentialRowViewModel]
) -> CredentialsListViewModel

internal extension InjectedFactory where T == _CredentialsListViewModelFactory {
    
    func make(makeCredentialsRowViewModels: @escaping ([Credential]) -> [CredentialRowViewModel]) -> CredentialsListViewModel {
       return factory(
              makeCredentialsRowViewModels
       )
    }
}

extension CredentialsListViewModel {
        internal typealias Factory = InjectedFactory<_CredentialsListViewModelFactory>
}


internal typealias _DataRequestHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> DataRequestHandler

internal extension InjectedFactory where T == _DataRequestHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> DataRequestHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension DataRequestHandler {
        internal typealias Factory = InjectedFactory<_DataRequestHandlerFactory>
}


internal typealias _EvaluatePasswordHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> EvaluatePasswordHandler

internal extension InjectedFactory where T == _EvaluatePasswordHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> EvaluatePasswordHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension EvaluatePasswordHandler {
        internal typealias Factory = InjectedFactory<_EvaluatePasswordHandlerFactory>
}


internal typealias _FetchSpacesInfoHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> FetchSpacesInfoHandler

internal extension InjectedFactory where T == _FetchSpacesInfoHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> FetchSpacesInfoHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension FetchSpacesInfoHandler {
        internal typealias Factory = InjectedFactory<_FetchSpacesInfoHandlerFactory>
}


internal typealias _GenerateAndEvaluatePasswordHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> GenerateAndEvaluatePasswordHandler

internal extension InjectedFactory where T == _GenerateAndEvaluatePasswordHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> GenerateAndEvaluatePasswordHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension GenerateAndEvaluatePasswordHandler {
        internal typealias Factory = InjectedFactory<_GenerateAndEvaluatePasswordHandlerFactory>
}


internal typealias _GeneratePasswordHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> GeneratePasswordHandler

internal extension InjectedFactory where T == _GeneratePasswordHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> GeneratePasswordHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension GeneratePasswordHandler {
        internal typealias Factory = InjectedFactory<_GeneratePasswordHandlerFactory>
}


internal typealias _GetOTPForCredentialHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> GetOTPForCredentialHandler

internal extension InjectedFactory where T == _GetOTPForCredentialHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> GetOTPForCredentialHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension GetOTPForCredentialHandler {
        internal typealias Factory = InjectedFactory<_GetOTPForCredentialHandlerFactory>
}


internal typealias _GetPasswordGenerationSettingsHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> GetPasswordGenerationSettingsHandler

internal extension InjectedFactory where T == _GetPasswordGenerationSettingsHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> GetPasswordGenerationSettingsHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension GetPasswordGenerationSettingsHandler {
        internal typealias Factory = InjectedFactory<_GetPasswordGenerationSettingsHandlerFactory>
}


internal typealias _IsAutofillPasswordProtectedHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> IsAutofillPasswordProtectedHandler

internal extension InjectedFactory where T == _IsAutofillPasswordProtectedHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> IsAutofillPasswordProtectedHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension IsAutofillPasswordProtectedHandler {
        internal typealias Factory = InjectedFactory<_IsAutofillPasswordProtectedHandlerFactory>
}


internal typealias _IsPasswordLimitReachedHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> IsPasswordLimitReachedHandler

internal extension InjectedFactory where T == _IsPasswordLimitReachedHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> IsPasswordLimitReachedHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension IsPasswordLimitReachedHandler {
        internal typealias Factory = InjectedFactory<_IsPasswordLimitReachedHandlerFactory>
}


internal typealias _MaverickUsageLogHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> MaverickUsageLogHandler

internal extension InjectedFactory where T == _MaverickUsageLogHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> MaverickUsageLogHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension MaverickUsageLogHandler {
        internal typealias Factory = InjectedFactory<_MaverickUsageLogHandlerFactory>
}


internal typealias _MoreTabViewModelFactory =  (
    _ login: String
) -> MoreTabViewModel

internal extension InjectedFactory where T == _MoreTabViewModelFactory {
    
    func make(login: String) -> MoreTabViewModel {
       return factory(
              login
       )
    }
}

extension MoreTabViewModel {
        internal typealias Factory = InjectedFactory<_MoreTabViewModelFactory>
}


internal typealias _ObjectsAutofilledHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> ObjectsAutofilledHandler

internal extension InjectedFactory where T == _ObjectsAutofilledHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> ObjectsAutofilledHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension ObjectsAutofilledHandler {
        internal typealias Factory = InjectedFactory<_ObjectsAutofilledHandlerFactory>
}


internal typealias _PasswordGeneratorTabViewModelFactory =  (
) -> PasswordGeneratorTabViewModel

internal extension InjectedFactory where T == _PasswordGeneratorTabViewModelFactory {
    
    func make() -> PasswordGeneratorTabViewModel {
       return factory(
       )
    }
}

extension PasswordGeneratorTabViewModel {
        internal typealias Factory = InjectedFactory<_PasswordGeneratorTabViewModelFactory>
}


internal typealias _PasswordGeneratorViewModelFactory =  (
    _ mode: PasswordGeneratorMode,
    _ saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
    _ savePreferencesOnChange: Bool
) -> PasswordGeneratorViewModel

internal extension InjectedFactory where T == _PasswordGeneratorViewModelFactory {
    
    func make(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
       return factory(
              mode,
              saveGeneratedPassword,
              savePreferencesOnChange
       )
    }
}

extension PasswordGeneratorViewModel {
        internal typealias Factory = InjectedFactory<_PasswordGeneratorViewModelFactory>
}


internal typealias _PasswordGeneratorViewModelSecondFactory =  (
    _ mode: PasswordGeneratorMode,
    _ savePreferencesOnChange: Bool
) -> PasswordGeneratorViewModel

internal extension InjectedFactory where T == _PasswordGeneratorViewModelSecondFactory {
    
    func make(mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
       return factory(
              mode,
              savePreferencesOnChange
       )
    }
}

extension PasswordGeneratorViewModel {
        internal typealias SecondFactory = InjectedFactory<_PasswordGeneratorViewModelSecondFactory>
}


internal typealias _PasswordGeneratorViewModelThirdFactory =  (
    _ mode: PasswordGeneratorMode
) -> PasswordGeneratorViewModel

internal extension InjectedFactory where T == _PasswordGeneratorViewModelThirdFactory {
    
    func make(mode: PasswordGeneratorMode) -> PasswordGeneratorViewModel {
       return factory(
              mode
       )
    }
}

extension PasswordGeneratorViewModel {
        internal typealias ThirdFactory = InjectedFactory<_PasswordGeneratorViewModelThirdFactory>
}


internal typealias _PasswordHistoryRowViewModelFactory =  (
    _ generatedPassword: GeneratedPassword
) -> PasswordHistoryRowViewModel

internal extension InjectedFactory where T == _PasswordHistoryRowViewModelFactory {
    
    func make(generatedPassword: GeneratedPassword) -> PasswordHistoryRowViewModel {
       return factory(
              generatedPassword
       )
    }
}

extension PasswordHistoryRowViewModel {
        internal typealias Factory = InjectedFactory<_PasswordHistoryRowViewModelFactory>
}


internal typealias _SaveCredentialDisabledHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> SaveCredentialDisabledHandler

internal extension InjectedFactory where T == _SaveCredentialDisabledHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> SaveCredentialDisabledHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension SaveCredentialDisabledHandler {
        internal typealias Factory = InjectedFactory<_SaveCredentialDisabledHandlerFactory>
}


internal typealias _SaveGeneratedPasswordHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> SaveGeneratedPasswordHandler

internal extension InjectedFactory where T == _SaveGeneratedPasswordHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> SaveGeneratedPasswordHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension SaveGeneratedPasswordHandler {
        internal typealias Factory = InjectedFactory<_SaveGeneratedPasswordHandlerFactory>
}


internal typealias _SaveRequestHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> SaveRequestHandler

internal extension InjectedFactory where T == _SaveRequestHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> SaveRequestHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension SaveRequestHandler {
        internal typealias Factory = InjectedFactory<_SaveRequestHandlerFactory>
}


internal typealias _SignalSaveCredentialDisabledHandlerFactory =  (
    _ maverickOrderMessage: MaverickOrderMessage
) -> SignalSaveCredentialDisabledHandler

internal extension InjectedFactory where T == _SignalSaveCredentialDisabledHandlerFactory {
    
    func make(maverickOrderMessage: MaverickOrderMessage) -> SignalSaveCredentialDisabledHandler {
       return factory(
              maverickOrderMessage
       )
    }
}

extension SignalSaveCredentialDisabledHandler {
        internal typealias Factory = InjectedFactory<_SignalSaveCredentialDisabledHandlerFactory>
}


public typealias _VaultItemIconViewModelFactory =  (
    _ item: VaultItem
) -> VaultItemIconViewModel

public extension InjectedFactory where T == _VaultItemIconViewModelFactory {
    
    func make(item: VaultItem) -> VaultItemIconViewModel {
       return factory(
              item
       )
    }
}

extension VaultItemIconViewModel {
        public typealias Factory = InjectedFactory<_VaultItemIconViewModelFactory>
}


public typealias _VaultItemIconViewModelSecondFactory =  (
    _ item: VaultItem,
    _ iconLibrary: DomainIconLibraryProtocol
) -> VaultItemIconViewModel

public extension InjectedFactory where T == _VaultItemIconViewModelSecondFactory {
    
    func make(item: VaultItem, iconLibrary: DomainIconLibraryProtocol) -> VaultItemIconViewModel {
       return factory(
              item,
              iconLibrary
       )
    }
}

extension VaultItemIconViewModel {
        public typealias SecondFactory = InjectedFactory<_VaultItemIconViewModelSecondFactory>
}

