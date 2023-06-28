#if canImport(AuthenticationServices)
import AuthenticationServices
#endif
#if canImport(AuthenticatorKit)
import AuthenticatorKit
#endif
#if canImport(AutofillKit)
import AutofillKit
#endif
#if canImport(Combine)
import Combine
#endif
#if canImport(Contacts)
import Contacts
#endif
#if canImport(CoreCategorizer)
import CoreCategorizer
#endif
#if canImport(CoreCrypto)
import CoreCrypto
#endif
#if canImport(CoreData)
import CoreData
#endif
#if canImport(CoreFeature)
import CoreFeature
#endif
#if canImport(CoreKeychain)
import CoreKeychain
#endif
#if canImport(CoreLocalization)
import CoreLocalization
#endif
#if canImport(CoreMedia)
import CoreMedia
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
#if canImport(CoreRegion)
import CoreRegion
#endif
#if canImport(CoreSession)
import CoreSession
#endif
#if canImport(CoreSettings)
import CoreSettings
#endif
#if canImport(CoreSharing)
import CoreSharing
#endif
#if canImport(CoreSync)
import CoreSync
#endif
#if canImport(CoreUserTracking)
import CoreUserTracking
#endif
#if canImport(CryptoKit)
import CryptoKit
#endif
#if canImport(DashTypes)
import DashTypes
#endif
#if canImport(DashlaneAPI)
import DashlaneAPI
#endif
#if canImport(DashlaneAppKit)
import DashlaneAppKit
#endif
#if canImport(DashlaneCrypto)
import DashlaneCrypto
#endif
#if canImport(DesignSystem)
import DesignSystem
#endif
#if canImport(DocumentServices)
import DocumentServices
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
#if canImport(ImportKit)
import ImportKit
#endif
#if canImport(LocalAuthentication)
import LocalAuthentication
#endif
#if canImport(Logger)
import Logger
#endif
#if canImport(LoginKit)
import LoginKit
#endif
#if canImport(Lottie)
import Lottie
#endif
#if canImport(NotificationKit)
import NotificationKit
#endif
#if canImport(PDFKit)
import PDFKit
#endif
#if canImport(QuickLook)
import QuickLook
#endif
#if canImport(SecurityDashboard)
import SecurityDashboard
#endif
#if canImport(StoreKit)
import StoreKit
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
#if canImport(UIComponents)
import UIComponents
#endif
#if canImport(UIDelight)
import UIDelight
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(UniformTypeIdentifiers)
import UniformTypeIdentifiers
#endif
#if canImport(VaultKit)
import VaultKit
#endif

internal protocol AccountCreationFlowDependenciesInjecting { }

 
extension AccountCreationFlowDependenciesContainer {
        @MainActor
        internal func makeAccountCreationFlowViewModel(completion: @MainActor @escaping (AccountCreationFlowViewModel.CompletionResult) -> Void) -> AccountCreationFlowViewModel {
            return AccountCreationFlowViewModel(
                            evaluator: passwordEvaluator,
                            activityReporter: activityReporter,
                            emailViewModelFactory: InjectedFactory(makeAccountEmailViewModel),
                            masterPasswordAccountCreationModelFactory: InjectedFactory(makeMasterPasswordAccountCreationFlowViewModel),
                            passwordLessAccountCreationModelFactory: InjectedFactory(makePasswordLessAccountCreationFlowViewModel),
                            completion: completion
            )
        }
        
}

extension AccountCreationFlowDependenciesContainer {
        @MainActor
        internal func makeAccountEmailViewModel(completion: @escaping (_ result: AccountEmailViewModel.CompletionResult) -> Void) -> AccountEmailViewModel {
            return AccountEmailViewModel(
                            appAPIClient: appAPIClient,
                            activityReporter: activityReporter,
                            completion: completion
            )
        }
        
}

extension AccountCreationFlowDependenciesContainer {
        
        internal func makeFastLocalSetupInAccountCreationViewModel(biometry: Biometry? = Device.biometryType, completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void) -> FastLocalSetupInAccountCreationViewModel {
            return FastLocalSetupInAccountCreationViewModel(
                            biometry: biometry,
                            completion: completion
            )
        }
        
}

extension AccountCreationFlowDependenciesContainer {
        
        internal func makeFastLocalSetupInLoginViewModel(masterPassword: String?, biometry: Biometry?, lockService: LockService, masterPasswordResetService: ResetMasterPasswordService, userSettings: UserSettings, completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void) -> FastLocalSetupInLoginViewModel {
            return FastLocalSetupInLoginViewModel(
                            masterPassword: masterPassword,
                            biometry: biometry,
                            lockService: lockService,
                            masterPasswordResetService: masterPasswordResetService,
                            userSettings: userSettings,
                            completion: completion
            )
        }
        
}

extension AccountCreationFlowDependenciesContainer {
        @MainActor
        internal func makeMasterPasswordAccountCreationFlowViewModel(configuration: AccountCreationConfiguration, completion: @MainActor @escaping (MasterPasswordAccountCreationFlowViewModel.CompletionResult) -> Void) -> MasterPasswordAccountCreationFlowViewModel {
            return MasterPasswordAccountCreationFlowViewModel(
                            configuration: configuration,
                            userCountryProvider: userCountryProvider,
                            accountCreationService: accountCreationService,
                            userConsentViewModelFactory: InjectedFactory(makeUserConsentViewModel),
                            fastLocalSetupViewModelFactory: InjectedFactory(makeFastLocalSetupInAccountCreationViewModel),
                            completion: completion
            )
        }
        
}

extension AccountCreationFlowDependenciesContainer {
        @MainActor
        internal func makePasswordLessAccountCreationFlowViewModel(configuration: AccountCreationConfiguration, completion: @MainActor @escaping (PasswordLessAccountCreationFlowViewModel.CompletionResult) -> Void) -> PasswordLessAccountCreationFlowViewModel {
            return PasswordLessAccountCreationFlowViewModel(
                            configuration: configuration,
                            userCountryProvider: userCountryProvider,
                            accountCreationService: accountCreationService,
                            userConsentViewModelFactory: InjectedFactory(makeUserConsentViewModel),
                            fastLocalSetupViewModelFactory: InjectedFactory(makeFastLocalSetupInAccountCreationViewModel),
                            completion: completion
            )
        }
        
}

extension AccountCreationFlowDependenciesContainer {
        
        internal func makeUserConsentViewModel(isEmailMarketingOptInRequired: Bool, completion: @escaping (UserConsentViewModel.Completion) -> Void) -> UserConsentViewModel {
            return UserConsentViewModel(
                            isEmailMarketingOptInRequired: isEmailMarketingOptInRequired,
                            completion: completion
            )
        }
        
}

internal protocol AppServicesInjecting { }

 
extension AppServicesContainer {
        
        internal func makeLoginKitServicesContainer() -> LoginKitServicesContainer {
            return LoginKitServicesContainer(
                            loginMetricsReporter: loginMetricsReporter,
                            activityReporter: activityReporter,
                            sessionCleaner: sessionCleaner,
                            settingsManager: spiegelSettingsManager,
                            keychainService: keychainService,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            appAPIClient: appAPIClient,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            sessionContainer: sessionContainer,
                            rootLogger: rootLogger,
                            nitroWebService: nitroWebService,
                            passwordEvaluvator: passwordEvaluator
            )
        }
        
}

internal protocol MockVaultConnectedInjecting { }

 
extension MockVaultConnectedContainer {
        
        internal func makeAddAttachmentButtonViewModel(editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
            return AddAttachmentButtonViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            editingItem: editingItem,
                            premiumService: premiumService,
                            shouldDisplayRenameAlert: shouldDisplayRenameAlert,
                            itemPublisher: itemPublisher
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAddLoginDetailsViewModel(website: String, credential: Credential?, supportDashlane2FA: Bool, completion: @escaping (OTPInfo) -> Void) -> AddLoginDetailsViewModel {
            return AddLoginDetailsViewModel(
                            website: website,
                            credential: credential,
                            supportDashlane2FA: supportDashlane2FA,
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAddOTPFlowViewModel(mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void) -> AddOTPFlowViewModel {
            return AddOTPFlowViewModel(
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            addOTPManuallyFlowViewModelFactory: InjectedFactory(makeAddOTPManuallyFlowViewModel),
                            mode: mode,
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAddOTPManuallyFlowViewModel(credential: Credential?, completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void) -> AddOTPManuallyFlowViewModel {
            return AddOTPManuallyFlowViewModel(
                            credential: credential,
                            vaultItemsService: vaultItemsService,
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            chooseWebsiteViewModelFactory: InjectedFactory(makeChooseWebsiteViewModel),
                            addLoginDetailsViewModelFactory: InjectedFactory(makeAddLoginDetailsViewModel),
                            credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAddressDetailViewModel(item: Address, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> AddressDetailViewModel {
            return AddressDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            regionInformationService: regionInformationService,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            dismiss: dismiss
            )
        }
                
        internal func makeAddressDetailViewModel(service: DetailService<Address>) -> AddressDetailViewModel {
            return AddressDetailViewModel(
                            service: service,
                            regionInformationService: regionInformationService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAttachmentRowViewModel(attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>, editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void) -> AttachmentRowViewModel {
            return AttachmentRowViewModel(
                            attachment: attachment,
                            attachmentPublisher: attachmentPublisher,
                            editingItem: editingItem,
                            database: database,
                            documentStorageService: documentStorageService,
                            deleteAction: deleteAction
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAttachmentsListViewModel(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
            return AttachmentsListViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: activityReporter,
                            database: database,
                            editingItem: editingItem,
                            makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
                            itemPublisher: itemPublisher
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAttachmentsSectionViewModel(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsSectionViewModel {
            return AttachmentsSectionViewModel(
                            vaultItemsService: vaultItemsService,
                            item: item,
                            documentStorageService: documentStorageService,
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
                            makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
                            itemPublisher: itemPublisher
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeBankAccountDetailViewModel(item: BankAccount, mode: DetailMode = .viewing) -> BankAccountDetailViewModel {
            return BankAccountDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            regionInformationService: regionInformationService,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeBankAccountDetailViewModel(service: DetailService<BankAccount>) -> BankAccountDetailViewModel {
            return BankAccountDetailViewModel(
                            service: service,
                            regionInformationService: regionInformationService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeChooseWebsiteViewModel(completion: @escaping (String) -> Void) -> ChooseWebsiteViewModel {
            return ChooseWebsiteViewModel(
                            categorizer: categorizer,
                            activityReporter: activityReporter,
                            placeholderViewModelFactory: InjectedFactory(makePlaceholderWebsiteViewModel),
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeCompanyDetailViewModel(item: Company, mode: DetailMode = .viewing) -> CompanyDetailViewModel {
            return CompanyDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeCompanyDetailViewModel(service: DetailService<Company>) -> CompanyDetailViewModel {
            return CompanyDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeCredentialDetailViewModel(item: Credential, mode: DetailMode = .viewing, generatedPasswordToLink: GeneratedPassword? = nil, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil) -> CredentialDetailViewModel {
            return CredentialDetailViewModel(
                            item: item,
                            session: session,
                            mode: mode,
                            generatedPasswordToLink: generatedPasswordToLink,
                            vaultItemsService: vaultItemsService,
                            actionPublisher: actionPublisher,
                            origin: origin,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            premiumService: premiumService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            iconService: iconService,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            passwordEvaluator: passwordEvaluator,
                            linkedDomainsService: linkedDomainsService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            didSave: didSave,
                            credentialMainSectionModelFactory: InjectedFactory(makeCredentialMainSectionModel),
                            passwordHealthSectionModelFactory: InjectedFactory(makePasswordHealthSectionModel),
                            passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel),
                            notesSectionModelFactory: InjectedFactory(makeNotesSectionModel),
                            sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
                            domainsSectionModelFactory: InjectedFactory(makeDomainsSectionModel),
                            makePasswordGeneratorViewModel: InjectedFactory(makePasswordGeneratorViewModel),
                            addOTPFlowViewModelFactory: InjectedFactory(makeAddOTPFlowViewModel),
                            passwordGeneratorViewModelFactory: makePasswordGeneratorViewModel,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeCredentialDetailViewModel(generatedPasswordToLink: GeneratedPassword? = nil, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil, service: DetailService<Credential>) -> CredentialDetailViewModel {
            return CredentialDetailViewModel(
                            generatedPasswordToLink: generatedPasswordToLink,
                            vaultItemsService: vaultItemsService,
                            actionPublisher: actionPublisher,
                            origin: origin,
                            featureService: featureService,
                            iconService: iconService,
                            passwordEvaluator: passwordEvaluator,
                            linkedDomainsService: linkedDomainsService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            didSave: didSave,
                            credentialMainSectionModelFactory: InjectedFactory(makeCredentialMainSectionModel),
                            passwordHealthSectionModelFactory: InjectedFactory(makePasswordHealthSectionModel),
                            passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel),
                            notesSectionModelFactory: InjectedFactory(makeNotesSectionModel),
                            sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
                            domainsSectionModelFactory: InjectedFactory(makeDomainsSectionModel),
                            addOTPFlowViewModelFactory: InjectedFactory(makeAddOTPFlowViewModel),
                            passwordGeneratorViewModelFactory: makePasswordGeneratorViewModel,
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeCredentialMainSectionModel(service: DetailService<Credential>, code: Binding<String>, isAutoFillDemoModalShown: Binding<Bool>, isAdd2FAFlowPresented: Binding<Bool>) -> CredentialMainSectionModel {
            return CredentialMainSectionModel(
                            service: service,
                            code: code,
                            isAutoFillDemoModalShown: isAutoFillDemoModalShown,
                            isAdd2FAFlowPresented: isAdd2FAFlowPresented,
                            passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeCreditCardDetailViewModel(item: CreditCard, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> CreditCardDetailViewModel {
            return CreditCardDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            regionInformationService: regionInformationService,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            dismiss: dismiss
            )
        }
                
        internal func makeCreditCardDetailViewModel(service: DetailService<CreditCard>) -> CreditCardDetailViewModel {
            return CreditCardDetailViewModel(
                            service: service,
                            regionInformationService: regionInformationService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeDomainsSectionModel(service: DetailService<Credential>) -> DomainsSectionModel {
            return DomainsSectionModel(
                            service: service,
                            linkedDomainsService: linkedDomainsService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeDrivingLicenseDetailViewModel(item: DrivingLicence, mode: DetailMode = .viewing) -> DrivingLicenseDetailViewModel {
            return DrivingLicenseDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            regionInformationService: regionInformationService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeDrivingLicenseDetailViewModel(service: DetailService<DrivingLicence>) -> DrivingLicenseDetailViewModel {
            return DrivingLicenseDetailViewModel(
                            service: service,
                            regionInformationService: regionInformationService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeEmailDetailViewModel(item: CorePersonalData.Email, mode: DetailMode = .viewing) -> EmailDetailViewModel {
            return EmailDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeEmailDetailViewModel(service: DetailService<CorePersonalData.Email>) -> EmailDetailViewModel {
            return EmailDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeFiscalInformationDetailViewModel(item: FiscalInformation, mode: DetailMode = .viewing) -> FiscalInformationDetailViewModel {
            return FiscalInformationDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeFiscalInformationDetailViewModel(service: DetailService<FiscalInformation>) -> FiscalInformationDetailViewModel {
            return FiscalInformationDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeGravatarIconViewModel(email: String, iconLibrary: GravatarIconLibraryProtocol) -> GravatarIconViewModel {
            return GravatarIconViewModel(
                            email: email,
                            iconLibrary: iconLibrary
            )
        }
                
        internal func makeGravatarIconViewModel(email: String) -> GravatarIconViewModel {
            return GravatarIconViewModel(
                            email: email,
                            iconService: iconService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeIDCardDetailViewModel(item: IDCard, mode: DetailMode = .viewing) -> IDCardDetailViewModel {
            return IDCardDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeIDCardDetailViewModel(service: DetailService<IDCard>) -> IDCardDetailViewModel {
            return IDCardDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeIdentityDetailViewModel(item: Identity, mode: DetailMode = .viewing) -> IdentityDetailViewModel {
            return IdentityDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeIdentityDetailViewModel(service: DetailService<Identity>) -> IdentityDetailViewModel {
            return IdentityDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeMatchingCredentialListViewModel(website: String, matchingCredentials: [Credential], completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void) -> MatchingCredentialListViewModel {
            return MatchingCredentialListViewModel(
                            website: website,
                            matchingCredentials: matchingCredentials,
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel),
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeNotesSectionModel(service: DetailService<Credential>) -> NotesSectionModel {
            return NotesSectionModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePasskeyDetailViewModel(item: CorePersonalData.Passkey, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> PasskeyDetailViewModel {
            return PasskeyDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            dismiss: dismiss
            )
        }
                
        internal func makePasskeyDetailViewModel(service: DetailService<CorePersonalData.Passkey>) -> PasskeyDetailViewModel {
            return PasskeyDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePassportDetailViewModel(item: Passport, mode: DetailMode = .viewing) -> PassportDetailViewModel {
            return PassportDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makePassportDetailViewModel(service: DetailService<Passport>) -> PassportDetailViewModel {
            return PassportDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePasswordAccessorySectionModel(service: DetailService<Credential>) -> PasswordAccessorySectionModel {
            return PasswordAccessorySectionModel(
                            service: service,
                            passwordEvaluator: passwordEvaluator
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            saveGeneratedPassword: saveGeneratedPassword,
                            passwordEvaluator: passwordEvaluator,
                            sessionActivityReporter: activityReporter,
                            userSettings: userSettings,
                            savePreferencesOnChange: savePreferencesOnChange,
                            copyAction: copyAction
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: passwordEvaluator,
                            sessionActivityReporter: activityReporter,
                            userSettings: userSettings,
                            savePreferencesOnChange: savePreferencesOnChange,
                            copyAction: copyAction
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: passwordEvaluator,
                            sessionActivityReporter: activityReporter,
                            userSettings: userSettings,
                            copyAction: copyAction
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePasswordHealthSectionModel(service: DetailService<Credential>) -> PasswordHealthSectionModel {
            return PasswordHealthSectionModel(
                            service: service,
                            passwordEvaluator: passwordEvaluator,
                            identityDashboardService: identityDashboardService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePhoneDetailViewModel(item: Phone, mode: DetailMode = .viewing) -> PhoneDetailViewModel {
            return PhoneDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            regionInformationService: regionInformationService
            )
        }
                
        internal func makePhoneDetailViewModel(service: DetailService<Phone>) -> PhoneDetailViewModel {
            return PhoneDetailViewModel(
                            service: service,
                            regionInformationService: regionInformationService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makePlaceholderWebsiteViewModel(website: String) -> PlaceholderWebsiteViewModel {
            return PlaceholderWebsiteViewModel(
                            website: website,
                            domainIconLibrary: domainIconLibrary
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeQuickActionsMenuViewModel(item: VaultItem, origin: VaultItemRowModel.Origin, isSuggestedItem: Bool) -> QuickActionsMenuViewModel {
            return QuickActionsMenuViewModel(
                            item: item,
                            sharingService: sharedVaultHandling,
                            accessControl: accessControl,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            activityReporter: activityReporter,
                            shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel),
                            origin: origin,
                            pasteboardService: pasteboardService,
                            isSuggestedItem: isSuggestedItem
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeSecureNotesDetailFieldsModel(service: DetailService<SecureNote>) -> SecureNotesDetailFieldsModel {
            return SecureNotesDetailFieldsModel(
                            service: service,
                            featureService: featureService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeSecureNotesDetailNavigationBarModel(service: DetailService<SecureNote>, isEditingContent: FocusState<Bool>.Binding) -> SecureNotesDetailNavigationBarModel {
            return SecureNotesDetailNavigationBarModel(
                            service: service,
                            isEditingContent: isEditingContent,
                            featureService: featureService
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeSecureNotesDetailToolbarModel(service: DetailService<SecureNote>) -> SecureNotesDetailToolbarModel {
            return SecureNotesDetailToolbarModel(
                            service: service,
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeSecureNotesDetailViewModel(item: SecureNote, mode: DetailMode = .viewing) -> SecureNotesDetailViewModel {
            return SecureNotesDetailViewModel(
                            item: item,
                            session: session,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            pasteboardService: pasteboardService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarModelFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            logger: logger,
                            documentStorageService: documentStorageService,
                            accessControl: accessControl,
                            userSettings: userSettings
            )
        }
                
        internal func makeSecureNotesDetailViewModel(service: DetailService<SecureNote>) -> SecureNotesDetailViewModel {
            return SecureNotesDetailViewModel(
                            service: service,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeShareButtonViewModel(items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []) -> ShareButtonViewModel {
            return ShareButtonViewModel(
                            items: items,
                            userGroupIds: userGroupIds,
                            userEmails: userEmails,
                            teamSpacesService: teamSpacesService,
                            shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeShareFlowViewModel(items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []) -> ShareFlowViewModel {
            return ShareFlowViewModel(
                            items: items,
                            userGroupIds: userGroupIds,
                            userEmails: userEmails,
                            sharingService: sharingServiceProtocol,
                            premiumService: premiumService,
                            itemsViewModelFactory: InjectedFactory(makeShareItemsSelectionViewModel),
                            recipientsViewModelFactory: InjectedFactory(makeShareRecipientsSelectionViewModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeShareItemsSelectionViewModel(completion: @MainActor @escaping ([VaultItem]) -> Void) -> ShareItemsSelectionViewModel {
            return ShareItemsSelectionViewModel(
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            itemRowViewModelFactory: InjectedFactory(makeVaultItemRowModel),
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeShareRecipientsSelectionViewModel(configuration: RecipientsConfiguration = .init(), completion: @MainActor @escaping (RecipientsConfiguration) -> Void) -> ShareRecipientsSelectionViewModel {
            return ShareRecipientsSelectionViewModel(
                            session: session,
                            configuration: configuration,
                            sharingService: sharingServiceProtocol,
                            gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
                            completion: completion
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeSharingDetailSectionModel(item: VaultItem) -> SharingDetailSectionModel {
            return SharingDetailSectionModel(
                            item: item,
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonModelFactory: InjectedFactory(makeShareButtonViewModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeSharingMembersDetailLinkModel(item: VaultItem) -> SharingMembersDetailLinkModel {
            return SharingMembersDetailLinkModel(
                            item: item,
                            sharingService: sharingServiceProtocol,
                            detailViewModelFactory: InjectedFactory(makeSharingMembersDetailViewModel)
            )
        }
        
}

extension MockVaultConnectedContainer {
        @MainActor
        internal func makeSharingMembersDetailViewModel(members: ItemSharingMembers, item: VaultItem) -> SharingMembersDetailViewModel {
            return SharingMembersDetailViewModel(
                            members: members,
                            item: item,
                            session: session,
                            personalDataBD: database,
                            gravatarViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
                            shareButtonModelFactory: InjectedFactory(makeShareButtonViewModel),
                            sharingService: sharingServiceProtocol
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeSocialSecurityDetailViewModel(item: SocialSecurityInformation, mode: DetailMode = .viewing) -> SocialSecurityDetailViewModel {
            return SocialSecurityDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeSocialSecurityDetailViewModel(service: DetailService<SocialSecurityInformation>) -> SocialSecurityDetailViewModel {
            return SocialSecurityDetailViewModel(
                            service: service
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeVaultItemIconViewModel(item: VaultItem) -> VaultItemIconViewModel {
            return VaultItemIconViewModel(
                            item: item,
                            iconLibrary: domainIconLibrary
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeVaultItemRowModel(configuration: VaultItemRowModel.Configuration, additionalConfiguration: VaultItemRowModel.AdditionalConfiguration? = nil) -> VaultItemRowModel {
            return VaultItemRowModel(
                            configuration: configuration,
                            additionalConfiguration: additionalConfiguration,
                            vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
                            quickActionsMenuViewModelFactory: InjectedFactory(makeQuickActionsMenuViewModel),
                            userSettings: userSettings,
                            accessControl: accessControl,
                            pasteboardService: pasteboardService,
                            activityReporter: activityReporter,
                            teamSpacesService: teamSpacesService,
                            vaultItemsService: vaultItemsService,
                            sharingPermissionProvider: sharedVaultHandling
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeWebsiteDetailViewModel(item: PersonalWebsite, mode: DetailMode = .viewing) -> WebsiteDetailViewModel {
            return WebsiteDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeWebsiteDetailViewModel(service: DetailService<PersonalWebsite>) -> WebsiteDetailViewModel {
            return WebsiteDetailViewModel(
                            service: service
            )
        }
        
}

internal protocol SessionServicesInjecting { }

 
extension SessionServicesContainer {
        @MainActor
        internal func makeAccountRecoveryActivationEmbeddedFlowModel(context: AccountRecoveryActivationContext, completion: @MainActor @escaping () -> Void) -> AccountRecoveryActivationEmbeddedFlowModel {
            return AccountRecoveryActivationEmbeddedFlowModel(
                            accountRecoveryKeyService: accountRecoveryKeyService,
                            session: session,
                            context: context,
                            activityReporter: activityReporter,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeAccountRecoveryActivationFlowModel(context: AccountRecoveryActivationContext) -> AccountRecoveryActivationFlowModel {
            return AccountRecoveryActivationFlowModel(
                            context: context,
                            activityReporter: activityReporter,
                            recoveryActivationViewModelFactory: InjectedFactory(makeAccountRecoveryActivationEmbeddedFlowModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeAccountRecoveryKeyStatusDetailViewModel(isEnabled: Bool) -> AccountRecoveryKeyStatusDetailViewModel {
            return AccountRecoveryKeyStatusDetailViewModel(
                            isEnabled: isEnabled,
                            session: session,
                            accountRecoveryKeyService: accountRecoveryKeyService,
                            accountRecoveryActivationFlowModelFactory: InjectedFactory(makeAccountRecoveryActivationFlowModel),
                            activityReporter: activityReporter,
                            logger: appServices.rootLogger
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeAccountRecoveryKeyStatusViewModel() -> AccountRecoveryKeyStatusViewModel {
            return AccountRecoveryKeyStatusViewModel(
                            session: session,
                            appAPIClient: appServices.appAPIClient,
                            userAPIClient: userDeviceAPIClient,
                            reachability: appServices.networkReachability,
                            recoveryKeyStatusDetailViewModelFactory: InjectedFactory(makeAccountRecoveryKeyStatusDetailViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddAttachmentButtonViewModel(editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
            return AddAttachmentButtonViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            editingItem: editingItem,
                            premiumService: premiumService,
                            shouldDisplayRenameAlert: shouldDisplayRenameAlert,
                            itemPublisher: itemPublisher
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeAddItemFlowViewModel(displayMode: AddItemFlowViewModel.DisplayMode, completion: @escaping (AddItemFlowViewModel.Completion) -> Void) -> AddItemFlowViewModel {
            return AddItemFlowViewModel(
                            displayMode: displayMode,
                            completion: completion,
                            detailViewFactory: InjectedFactory(makeDetailView),
                            credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
                            addPrefilledCredentialViewModelFactory: InjectedFactory(makeAddPrefilledCredentialViewModel),
                            autofillOnboardingFlowViewModelFactory: InjectedFactory(makeAutofillOnboardingFlowViewModel),
                            sessionServices: self
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddLoginDetailsViewModel(website: String, credential: Credential?, supportDashlane2FA: Bool, completion: @escaping (OTPInfo) -> Void) -> AddLoginDetailsViewModel {
            return AddLoginDetailsViewModel(
                            website: website,
                            credential: credential,
                            supportDashlane2FA: supportDashlane2FA,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeAddNewDeviceViewModel(qrCodeViaSystemCamera: String? = nil) -> AddNewDeviceViewModel {
            return AddNewDeviceViewModel(
                            session: session,
                            apiClient: userDeviceAPIClient,
                            sessionCryptoEngineProvider: appServices.sessionCryptoEngineProvider,
                            qrCodeViaSystemCamera: qrCodeViaSystemCamera
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddOTPFlowViewModel(mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void) -> AddOTPFlowViewModel {
            return AddOTPFlowViewModel(
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            addOTPManuallyFlowViewModelFactory: InjectedFactory(makeAddOTPManuallyFlowViewModel),
                            mode: mode,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddOTPManuallyFlowViewModel(credential: Credential?, completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void) -> AddOTPManuallyFlowViewModel {
            return AddOTPManuallyFlowViewModel(
                            credential: credential,
                            vaultItemsService: vaultItemsService,
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            chooseWebsiteViewModelFactory: InjectedFactory(makeChooseWebsiteViewModel),
                            addLoginDetailsViewModelFactory: InjectedFactory(makeAddLoginDetailsViewModel),
                            credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddPrefilledCredentialViewModel(didChooseCredential: @escaping (Credential, Bool) -> Void) -> AddPrefilledCredentialViewModel {
            return AddPrefilledCredentialViewModel(
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            session: session,
                            categorizer: appServices.categorizer,
                            personalDataURLDecoder: personalDataURLDecoder,
                            vaultItemsService: vaultItemsService,
                            didChooseCredential: didChooseCredential
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddressDetailViewModel(item: Address, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> AddressDetailViewModel {
            return AddressDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            regionInformationService: appServices.regionInformationService,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            dismiss: dismiss
            )
        }
                
        internal func makeAddressDetailViewModel(service: DetailService<Address>) -> AddressDetailViewModel {
            return AddressDetailViewModel(
                            service: service,
                            regionInformationService: appServices.regionInformationService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAttachmentRowViewModel(attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>, editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void) -> AttachmentRowViewModel {
            return AttachmentRowViewModel(
                            attachment: attachment,
                            attachmentPublisher: attachmentPublisher,
                            editingItem: editingItem,
                            database: database,
                            documentStorageService: documentStorageService,
                            deleteAction: deleteAction
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAttachmentsListViewModel(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
            return AttachmentsListViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: activityReporter,
                            database: database,
                            editingItem: editingItem,
                            makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
                            itemPublisher: itemPublisher
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAttachmentsSectionViewModel(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsSectionViewModel {
            return AttachmentsSectionViewModel(
                            vaultItemsService: vaultItemsService,
                            item: item,
                            documentStorageService: documentStorageService,
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
                            makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
                            itemPublisher: itemPublisher
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAuthenticatorNotificationRowViewModel(notification: DashlaneNotification) -> AuthenticatorNotificationRowViewModel {
            return AuthenticatorNotificationRowViewModel(
                            notification: notification,
                            deepLinkingService: appServices.deepLinkingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAuthenticatorToolFlowViewModel() -> AuthenticatorToolFlowViewModel {
            return AuthenticatorToolFlowViewModel(
                            vaultItemsService: vaultItemsService,
                            activityReporter: activityReporter,
                            deepLinkingService: appServices.deepLinkingService,
                            otpDatabaseService: otpDatabaseService,
                            iconService: iconService,
                            settings: spiegelLocalSettingsStore,
                            otpExplorerViewModelFactory: InjectedFactory(makeOTPExplorerViewModel),
                            otpTokenListViewModelFactory: InjectedFactory(makeOTPTokenListViewModel),
                            credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
                            addOTPFlowViewModelFactory: InjectedFactory(makeAddOTPFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeBankAccountDetailViewModel(item: BankAccount, mode: DetailMode = .viewing) -> BankAccountDetailViewModel {
            return BankAccountDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            regionInformationService: appServices.regionInformationService,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeBankAccountDetailViewModel(service: DetailService<BankAccount>) -> BankAccountDetailViewModel {
            return BankAccountDetailViewModel(
                            service: service,
                            regionInformationService: appServices.regionInformationService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeBreachDetailViewModel(breach: DWMSimplifiedBreach, email: String, completion: @escaping (BreachDetailViewModel.Completion) -> Void) -> BreachDetailViewModel {
            return BreachDetailViewModel(
                            breach: breach,
                            email: email,
                            domainParser: appServices.domainParser,
                            vaultItemsService: vaultItemsService,
                            dwmOnboardingService: dwmOnboardingService,
                            userSettings: spiegelUserSettings,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeBreachViewModel(hasBeenAddressed: Bool, url: PersonalDataURL, leakedPassword: String?, leakDate: Date?, email: String? = nil, otherLeakedData: [String]? = nil, simplifiedBreach: DWMSimplifiedBreach? = nil) -> BreachViewModel {
            return BreachViewModel(
                            hasBeenAddressed: hasBeenAddressed,
                            url: url,
                            leakedPassword: leakedPassword,
                            leakDate: leakDate,
                            email: email,
                            otherLeakedData: otherLeakedData,
                            simplifiedBreach: simplifiedBreach,
                            iconViewModelProvider: makeDWMItemIconViewModel
            )
        }
                
        internal func makeBreachViewModel(breach: DWMSimplifiedBreach) -> BreachViewModel {
            return BreachViewModel(
                            breach: breach,
                            iconViewModelProvider: makeDWMItemIconViewModel
            )
        }
                
        internal func makeBreachViewModel(credential: Credential) -> BreachViewModel {
            return BreachViewModel(
                            credential: credential,
                            iconViewModelProvider: makeDWMItemIconViewModel
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeBreachesListViewModel(completion: @escaping (BreachesListViewModel.Completion) -> Void) -> BreachesListViewModel {
            return BreachesListViewModel(
                            dwmOnboardingService: dwmOnboardingService,
                            breachRowProvider: makeBreachViewModel,
                            credentialRowProvider: makeBreachViewModel,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeChangeMasterPasswordFlowViewModel() -> ChangeMasterPasswordFlowViewModel {
            return ChangeMasterPasswordFlowViewModel(
                            session: session,
                            sessionsContainer: appServices.sessionContainer,
                            premiumService: premiumService,
                            passwordEvaluator: passwordEvaluator,
                            logger: appServices.rootLogger,
                            activityReporter: activityReporter,
                            syncService: syncService,
                            apiClient: userDeviceAPIClient,
                            resetMasterPasswordService: resetMasterPasswordService,
                            keychainService: appServices.keychainService,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            databaseDriver: databaseDriver,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            migrationProgressViewModelFactory: InjectedFactory(makeMigrationProgressViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeChooseWebsiteViewModel(completion: @escaping (String) -> Void) -> ChooseWebsiteViewModel {
            return ChooseWebsiteViewModel(
                            categorizer: appServices.categorizer,
                            activityReporter: activityReporter,
                            placeholderViewModelFactory: InjectedFactory(makePlaceholderWebsiteViewModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCollectionDetailViewModel(collection: VaultCollection) -> CollectionDetailViewModel {
            return CollectionDetailViewModel(
                            collection: collection,
                            logger: appServices.rootLogger,
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            collectionQuickActionsMenuViewModelFactory: InjectedFactory(makeCollectionQuickActionsMenuViewModel),
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeCollectionsFlowViewModel(initialStep: CollectionsFlowViewModel.Step = .list) -> CollectionsFlowViewModel {
            return CollectionsFlowViewModel(
                            initialStep: initialStep,
                            vaultItemsService: vaultItemsService,
                            detailViewFactory: InjectedFactory(makeDetailView),
                            collectionsListViewModelFactory: InjectedFactory(makeCollectionsListViewModel),
                            collectionDetailViewModelFactory: InjectedFactory(makeCollectionDetailViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCompanyDetailViewModel(item: Company, mode: DetailMode = .viewing) -> CompanyDetailViewModel {
            return CompanyDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeCompanyDetailViewModel(service: DetailService<Company>) -> CompanyDetailViewModel {
            return CompanyDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCredentialDetailViewModel(item: Credential, mode: DetailMode = .viewing, generatedPasswordToLink: GeneratedPassword? = nil, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil) -> CredentialDetailViewModel {
            return CredentialDetailViewModel(
                            item: item,
                            session: session,
                            mode: mode,
                            generatedPasswordToLink: generatedPasswordToLink,
                            vaultItemsService: vaultItemsService,
                            actionPublisher: actionPublisher,
                            origin: origin,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            premiumService: premiumService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            iconService: iconService,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            passwordEvaluator: passwordEvaluator,
                            linkedDomainsService: appServices.linkedDomainService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            didSave: didSave,
                            credentialMainSectionModelFactory: InjectedFactory(makeCredentialMainSectionModel),
                            passwordHealthSectionModelFactory: InjectedFactory(makePasswordHealthSectionModel),
                            passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel),
                            notesSectionModelFactory: InjectedFactory(makeNotesSectionModel),
                            sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
                            domainsSectionModelFactory: InjectedFactory(makeDomainsSectionModel),
                            makePasswordGeneratorViewModel: InjectedFactory(makePasswordGeneratorViewModel),
                            addOTPFlowViewModelFactory: InjectedFactory(makeAddOTPFlowViewModel),
                            passwordGeneratorViewModelFactory: makePasswordGeneratorViewModel,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeCredentialDetailViewModel(generatedPasswordToLink: GeneratedPassword? = nil, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil, service: DetailService<Credential>) -> CredentialDetailViewModel {
            return CredentialDetailViewModel(
                            generatedPasswordToLink: generatedPasswordToLink,
                            vaultItemsService: vaultItemsService,
                            actionPublisher: actionPublisher,
                            origin: origin,
                            featureService: featureService,
                            iconService: iconService,
                            passwordEvaluator: passwordEvaluator,
                            linkedDomainsService: appServices.linkedDomainService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            didSave: didSave,
                            credentialMainSectionModelFactory: InjectedFactory(makeCredentialMainSectionModel),
                            passwordHealthSectionModelFactory: InjectedFactory(makePasswordHealthSectionModel),
                            passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel),
                            notesSectionModelFactory: InjectedFactory(makeNotesSectionModel),
                            sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
                            domainsSectionModelFactory: InjectedFactory(makeDomainsSectionModel),
                            addOTPFlowViewModelFactory: InjectedFactory(makeAddOTPFlowViewModel),
                            passwordGeneratorViewModelFactory: makePasswordGeneratorViewModel,
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCredentialMainSectionModel(service: DetailService<Credential>, code: Binding<String>, isAutoFillDemoModalShown: Binding<Bool>, isAdd2FAFlowPresented: Binding<Bool>) -> CredentialMainSectionModel {
            return CredentialMainSectionModel(
                            service: service,
                            code: code,
                            isAutoFillDemoModalShown: isAutoFillDemoModalShown,
                            isAdd2FAFlowPresented: isAdd2FAFlowPresented,
                            passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeCreditCardDetailViewModel(item: CreditCard, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> CreditCardDetailViewModel {
            return CreditCardDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            regionInformationService: appServices.regionInformationService,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            dismiss: dismiss
            )
        }
                
        internal func makeCreditCardDetailViewModel(service: DetailService<CreditCard>) -> CreditCardDetailViewModel {
            return CreditCardDetailViewModel(
                            service: service,
                            regionInformationService: appServices.regionInformationService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeDWMEmailConfirmationViewModel(accountEmail: String, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy) -> DWMEmailConfirmationViewModel {
            return DWMEmailConfirmationViewModel(
                            accountEmail: accountEmail,
                            emailStatusCheck: emailStatusCheck,
                            settings: dwmOnboardingSettings,
                            dwmOnboardingService: dwmOnboardingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDWMItemIconViewModel(url: PersonalDataURL) -> DWMItemIconViewModel {
            return DWMItemIconViewModel(
                            url: url,
                            iconService: iconService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeDWMOnboardingFlowViewModel(transitionHandler: GuidedOnboardingTransitionHandler?, completion: @escaping (DWMOnboardingFlowViewModel.Completion) -> Void) -> DWMOnboardingFlowViewModel {
            return DWMOnboardingFlowViewModel(
                            transitionHandler: transitionHandler,
                            session: session,
                            dwmOnboardingSettings: dwmOnboardingSettings,
                            registrationInGuidedOnboardingVModelFactory: InjectedFactory(makeDWMRegistrationInGuidedOnboardingViewModel),
                            emailConfirmationViewModelFactory: InjectedFactory(makeDWMEmailConfirmationViewModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeDWMRegistrationInGuidedOnboardingViewModel(email: String) -> DWMRegistrationInGuidedOnboardingViewModel {
            return DWMRegistrationInGuidedOnboardingViewModel(
                            email: email,
                            dwmOnboardingService: dwmOnboardingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDarkWebMonitoringBreachListViewModel(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?) -> DarkWebMonitoringBreachListViewModel {
            return DarkWebMonitoringBreachListViewModel(
                            darkWebMonitoringService: darkWebMonitoringService,
                            activityReporter: activityReporter,
                            actionPublisher: actionPublisher,
                            breachRowProvider: makeBreachViewModel
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDarkWebMonitoringDetailsViewModel(breach: DWMSimplifiedBreach, breachViewModel: BreachViewModel, actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil) -> DarkWebMonitoringDetailsViewModel {
            return DarkWebMonitoringDetailsViewModel(
                            breach: breach,
                            breachViewModel: breachViewModel,
                            darkWebMonitoringService: darkWebMonitoringService,
                            domainParser: domainParser,
                            userSettings: spiegelUserSettings,
                            actionPublisher: actionPublisher
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDarkWebMonitoringEmailRowViewModel(email: DataLeakEmail, actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>) -> DarkWebMonitoringEmailRowViewModel {
            return DarkWebMonitoringEmailRowViewModel(
                            email: email,
                            iconService: iconService,
                            actionPublisher: actionPublisher
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDarkWebMonitoringMonitoredEmailsViewModel(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>) -> DarkWebMonitoringMonitoredEmailsViewModel {
            return DarkWebMonitoringMonitoredEmailsViewModel(
                            darkWebMonitoringService: darkWebMonitoringService,
                            iconService: iconService,
                            actionPublisher: actionPublisher
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDarkWebMonitoringViewModel(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never> = .init()) -> DarkWebMonitoringViewModel {
            return DarkWebMonitoringViewModel(
                            darkWebMonitoringService: darkWebMonitoringService,
                            headerViewModelFactory: InjectedFactory(makeDarkWebMonitoringMonitoredEmailsViewModel),
                            listViewModelFactory: InjectedFactory(makeDarkWebMonitoringBreachListViewModel),
                            actionPublisher: actionPublisher,
                            iconService: iconService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeDarkWebToolsFlowViewModel() -> DarkWebToolsFlowViewModel {
            return DarkWebToolsFlowViewModel(
                            session: session,
                            userSettings: spiegelUserSettings,
                            darkWebMonitoringService: darkWebMonitoringService,
                            deepLinkingService: appServices.deepLinkingService,
                            darkWebMonitoringViewModelFactory: InjectedFactory(makeDarkWebMonitoringViewModel),
                            dataLeakMonitoringAddEmailViewModelFactory: InjectedFactory(makeDataLeakMonitoringAddEmailViewModel),
                            darkWebMonitoringDetailsViewModelFactory: InjectedFactory(makeDarkWebMonitoringDetailsViewModel),
                            breachViewModelFactory: InjectedFactory(makeBreachViewModel),
                            webservice: legacyWebService,
                            notificationService: notificationService,
                            logger: appServices.rootLogger,
                            credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeDataLeakMonitoringAddEmailViewModel(login: Login, dataLeakService: DataLeakMonitoringRegisterServiceProtocol) -> DataLeakMonitoringAddEmailViewModel {
            return DataLeakMonitoringAddEmailViewModel(
                            login: login,
                            dataLeakService: dataLeakService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDetailView(itemDetailViewType: ItemDetailViewType, dismiss: DetailContainerViewSpecificAction? = nil) -> DetailView {
            return DetailView(
                            itemDetailViewType: itemDetailViewType,
                            dismiss: dismiss,
                            detailViewFactory: InjectedFactory(makeDetailViewFactory)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDetailViewFactory() -> DetailViewFactory {
            return DetailViewFactory(
                            credentialFactory: InjectedFactory(makeCredentialDetailViewModel),
                            identityFactory: InjectedFactory(makeIdentityDetailViewModel),
                            emailFactory: InjectedFactory(makeEmailDetailViewModel),
                            companyFactory: InjectedFactory(makeCompanyDetailViewModel),
                            personalWebsiteFactory: InjectedFactory(makeWebsiteDetailViewModel),
                            phoneFactory: InjectedFactory(makePhoneDetailViewModel),
                            fiscalInfoFactory: InjectedFactory(makeFiscalInformationDetailViewModel),
                            idCardFactory: InjectedFactory(makeIDCardDetailViewModel),
                            passportFactory: InjectedFactory(makePassportDetailViewModel),
                            socialSecurityFactory: InjectedFactory(makeSocialSecurityDetailViewModel),
                            drivingLicenseFactory: InjectedFactory(makeDrivingLicenseDetailViewModel),
                            addressFactory: InjectedFactory(makeAddressDetailViewModel),
                            creditCardFactory: InjectedFactory(makeCreditCardDetailViewModel),
                            bankAccountFactory: InjectedFactory(makeBankAccountDetailViewModel),
                            secureNoteFactory: InjectedFactory(makeSecureNotesDetailViewModel),
                            passkeyFactory: InjectedFactory(makePasskeyDetailViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDeviceListViewModel() -> DeviceListViewModel {
            return DeviceListViewModel(
                            apiClient: userDeviceAPIClient,
                            legacyWebService: legacyWebService,
                            session: session,
                            reachability: appServices.networkReachability,
                            logoutHandler: appServices.sessionLifeCycleHandler
            )
        }
                
        internal func makeDeviceListViewModel(deviceService: DeviceServiceProtocol, currentDeviceId: String) -> DeviceListViewModel {
            return DeviceListViewModel(
                            deviceService: deviceService,
                            currentDeviceId: currentDeviceId,
                            reachability: appServices.networkReachability
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDomainsSectionModel(service: DetailService<Credential>) -> DomainsSectionModel {
            return DomainsSectionModel(
                            service: service,
                            linkedDomainsService: appServices.linkedDomainService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDrivingLicenseDetailViewModel(item: DrivingLicence, mode: DetailMode = .viewing) -> DrivingLicenseDetailViewModel {
            return DrivingLicenseDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            regionInformationService: appServices.regionInformationService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeDrivingLicenseDetailViewModel(service: DetailService<DrivingLicence>) -> DrivingLicenseDetailViewModel {
            return DrivingLicenseDetailViewModel(
                            service: service,
                            regionInformationService: appServices.regionInformationService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeEmailDetailViewModel(item: CorePersonalData.Email, mode: DetailMode = .viewing) -> EmailDetailViewModel {
            return EmailDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeEmailDetailViewModel(service: DetailService<CorePersonalData.Email>) -> EmailDetailViewModel {
            return EmailDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeExportSecureArchiveViewModel() -> ExportSecureArchiveViewModel {
            return ExportSecureArchiveViewModel(
                            session: session,
                            databaseDriver: databaseDriver,
                            reporter: activityReporter
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeFastLocalSetupInLoginViewModel(masterPassword: String?, biometry: Biometry?, completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void) -> FastLocalSetupInLoginViewModel {
            return FastLocalSetupInLoginViewModel(
                            masterPassword: masterPassword,
                            biometry: biometry,
                            lockService: lockService,
                            masterPasswordResetService: resetMasterPasswordService,
                            userSettings: spiegelUserSettings,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeFiscalInformationDetailViewModel(item: FiscalInformation, mode: DetailMode = .viewing) -> FiscalInformationDetailViewModel {
            return FiscalInformationDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeFiscalInformationDetailViewModel(service: DetailService<FiscalInformation>) -> FiscalInformationDetailViewModel {
            return FiscalInformationDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeGeneralSettingsViewModel() -> GeneralSettingsViewModel {
            return GeneralSettingsViewModel(
                            applicationDatabase: database,
                            databaseDriver: databaseDriver,
                            iconService: iconService,
                            activityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            exportSecureArchiveViewModelFactory: InjectedFactory(makeExportSecureArchiveViewModel),
                            dashImportFlowViewModelFactory: InjectedFactory(makeDashImportFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGravatarIconViewModel(email: String, iconLibrary: GravatarIconLibraryProtocol) -> GravatarIconViewModel {
            return GravatarIconViewModel(
                            email: email,
                            iconLibrary: iconLibrary
            )
        }
                
        internal func makeGravatarIconViewModel(email: String) -> GravatarIconViewModel {
            return GravatarIconViewModel(
                            email: email,
                            iconService: iconService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGuidedOnboardingViewModel(guidedOnboardingService: GuidedOnboardingService, step: GuidedOnboardingSurveyStep, completion: ((GuidedOnboardingViewModelCompletion) -> Void)?) -> GuidedOnboardingViewModel {
            return GuidedOnboardingViewModel(
                            guidedOnboardingService: guidedOnboardingService,
                            dwmOnboardingService: dwmOnboardingService,
                            step: step,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeHelpCenterSettingsViewModel() -> HelpCenterSettingsViewModel {
            return HelpCenterSettingsViewModel(
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeHomeFlowViewModel() -> HomeFlowViewModel {
            return HomeFlowViewModel(
                            sessionServices: self
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeHomeViewModel(onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void, action: @escaping (VaultFlowViewModel.Action) -> Void) -> HomeViewModel {
            return HomeViewModel(
                            vaultItemsService: vaultItemsService,
                            autofillService: autofillService,
                            userSettings: spiegelUserSettings,
                            viewModelFactory: viewModelFactory,
                            brazeService: brazeServiceProtocol,
                            syncedSettings: syncedSettings,
                            featureService: featureService,
                            premiumService: vaultKitPremiumService,
                            deepLinkingService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            capabilityService: premiumService,
                            abTestingService: authenticatedABTestingService,
                            onboardingAction: onboardingAction,
                            action: action,
                            lastpassDetector: lastpassDetector,
                            vaultListViewModelFactory: InjectedFactory(makeVaultListViewModel),
                            premiumAnnouncementsViewModelFactory: InjectedFactory(makePremiumAnnouncementsViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeIDCardDetailViewModel(item: IDCard, mode: DetailMode = .viewing) -> IDCardDetailViewModel {
            return IDCardDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeIDCardDetailViewModel(service: DetailService<IDCard>) -> IDCardDetailViewModel {
            return IDCardDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeIdentityBreachAlertViewModel(breachesToPresent: [PopupAlertProtocol]) -> IdentityBreachAlertViewModel {
            return IdentityBreachAlertViewModel(
                            breachesToPresent: breachesToPresent,
                            identityDashboardService: identityDashboardService,
                            deepLinkingService: appServices.deepLinkingService,
                            featureService: featureService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeIdentityDetailViewModel(item: Identity, mode: DetailMode = .viewing) -> IdentityDetailViewModel {
            return IdentityDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeIdentityDetailViewModel(service: DetailService<Identity>) -> IdentityDetailViewModel {
            return IdentityDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeImportMethodFlowViewModel(mode: ImportMethodMode, completion: @escaping (ImportMethodFlowViewModel.Completion) -> Void) -> ImportMethodFlowViewModel {
            return ImportMethodFlowViewModel(
                            mode: mode,
                            completion: completion,
                            sessionServices: self,
                            importMethodViewModelFactory: InjectedFactory(makeImportMethodViewModel),
                            addItemFlowViewModelFactory: InjectedFactory(makeAddItemFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeImportMethodViewModel(importService: ImportMethodServiceProtocol, completion: @escaping (ImportMethodCompletion) -> Void) -> ImportMethodViewModel {
            return ImportMethodViewModel(
                            dwmSettings: dwmOnboardingSettings,
                            dwmOnboardingService: dwmOnboardingService,
                            importService: importService,
                            activityReporter: activityReporter,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeLabsSettingsViewModel(labsService: LabsService) -> LabsSettingsViewModel {
            return LabsSettingsViewModel(
                            featureFlipService: featureService,
                            labsService: labsService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeLockViewModel(locker: ScreenLocker, newMasterPassword: String? = nil, changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher) -> LockViewModel {
            return LockViewModel(
                            locker: locker,
                            session: session,
                            appServices: appServices,
                            appAPIClient: appServices.appAPIClient,
                            userDeviceAPIClient: userDeviceAPIClient,
                            keychainService: appServices.keychainService,
                            userSettings: spiegelUserSettings,
                            resetMasterPasswordService: resetMasterPasswordService,
                            activityReporter: activityReporter,
                            teamspaceService: teamSpacesService,
                            loginMetricsReporter: appServices.loginMetricsReporter,
                            lockService: lockService,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            syncService: syncService,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            syncedSettings: syncedSettings,
                            databaseDriver: databaseDriver,
                            logger: appServices.rootLogger,
                            newMasterPassword: newMasterPassword,
                            changeMasterPasswordLauncher: changeMasterPasswordLauncher,
                            postARKChangeMasterPasswordViewModelFactory: InjectedFactory(makePostARKChangeMasterPasswordViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeM2WSettings() -> M2WSettings {
            return M2WSettings(
                            userSettings: spiegelUserSettings
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeMainSettingsViewModel(labsService: LabsService) -> MainSettingsViewModel {
            return MainSettingsViewModel(
                            session: session,
                            sessionCryptoEngineProvider: appServices.sessionCryptoEngineProvider,
                            premiumService: premiumService,
                            teamSpacesService: teamSpacesService,
                            lockService: lockService,
                            sharingLinkService: sharingLinkService,
                            userSettings: spiegelUserSettings,
                            labsService: labsService,
                            featureService: featureService,
                            userApiClient: userDeviceAPIClient,
                            settingsStatusSectionViewModelFactory: InjectedFactory(makeSettingsStatusSectionViewModel),
                            addNewDeviceFactory: InjectedFactory(makeAddNewDeviceViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeMasterPasswordResetActivationViewModel(masterPassword: String, actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> MasterPasswordResetActivationViewModel {
            return MasterPasswordResetActivationViewModel(
                            masterPassword: masterPassword,
                            resetMasterPasswordService: resetMasterPasswordService,
                            lockService: lockService,
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeMatchingCredentialListViewModel(website: String, matchingCredentials: [Credential], completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void) -> MatchingCredentialListViewModel {
            return MatchingCredentialListViewModel(
                            website: website,
                            matchingCredentials: matchingCredentials,
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeMigrationProgressViewModel(type: MigrationType, accountCryptoChangerService: AccountCryptoChangerServiceProtocol, context: MigrationProgressViewModel.Context, isProgress: Bool = true, isSuccess: Bool = true, completion: @escaping (Result<Session, Error>) -> Void) -> MigrationProgressViewModel {
            return MigrationProgressViewModel(
                            type: type,
                            accountCryptoChangerService: accountCryptoChangerService,
                            accountRecoveryKeyService: accountRecoveryKeyService,
                            userDeviceAPIClient: userDeviceAPIClient,
                            activityReporter: activityReporter,
                            syncedSettings: syncedSettings,
                            context: context,
                            logger: appServices.rootLogger,
                            isProgress: isProgress,
                            isSuccess: isSuccess,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeMiniBrowserViewModel(email: String, password: String, displayableDomain: String, url: URL, completion: @escaping (MiniBrowserViewModel.Completion) -> Void) -> MiniBrowserViewModel {
            return MiniBrowserViewModel(
                            email: email,
                            password: password,
                            displayableDomain: displayableDomain,
                            url: url,
                            domainParser: domainParser,
                            userSettings: spiegelUserSettings,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeNotesSectionModel(service: DetailService<Credential>) -> NotesSectionModel {
            return NotesSectionModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeNotificationCenterService() -> NotificationCenterService {
            return NotificationCenterService(
                            session: session,
                            settings: spiegelLocalSettingsStore,
                            userSettings: spiegelUserSettings,
                            lockService: lockService,
                            premiumService: premiumService,
                            identityDashboardService: identityDashboardService,
                            resetMasterPasswordService: resetMasterPasswordService,
                            sharingService: sharingService,
                            teamspaceService: teamSpacesService,
                            abtestService: authenticatedABTestingService,
                            keychainService: appServices.keychainService,
                            featureService: featureService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeNotificationsFlowViewModel(notificationCenterService: NotificationCenterServiceProtocol) -> NotificationsFlowViewModel {
            return NotificationsFlowViewModel(
                            notificationCenterService: notificationCenterService,
                            deeplinkService: appServices.deepLinkingService,
                            notificationsListViewModelFactory: InjectedFactory(makeNotificationsListViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeNotificationsListViewModel(notificationCenterService: NotificationCenterServiceProtocol) -> NotificationsListViewModel {
            return NotificationsListViewModel(
                            session: session,
                            settings: spiegelLocalSettingsStore,
                            userSettings: spiegelUserSettings,
                            resetMasterPasswordService: resetMasterPasswordService,
                            premiumService: premiumService,
                            lockService: lockService,
                            teamspaceService: teamSpacesService,
                            abtestService: authenticatedABTestingService,
                            keychainService: appServices.keychainService,
                            featureService: featureService,
                            notificationCenterService: notificationCenterService,
                            identityDashboardService: identityDashboardService,
                            authenticatorNotificationFactory: makeAuthenticatorNotificationRowViewModel,
                            resetMasterPasswordNotificationFactory: makeResetMasterPasswordNotificationRowViewModel,
                            trialPeriodNotificationFactory: makeTrialPeriodNotificationRowViewModel,
                            secureLockNotificationFactory: makeSecureLockNotificationRowViewModel,
                            sharingItemNotificationFactory: makeSharingRequestNotificationRowViewModel,
                            securityAlertNotificationFactory: makeSecurityAlertNotificationRowViewModel
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeOTPExplorerViewModel(otpSupportedDomainsRepository: OTPSupportedDomainsRepository, actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void) -> OTPExplorerViewModel {
            return OTPExplorerViewModel(
                            vaultItemsService: vaultItemsService,
                            otpSupportedDomainsRepository: otpSupportedDomainsRepository,
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel),
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeOTPTokenListViewModel(actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void) -> OTPTokenListViewModel {
            return OTPTokenListViewModel(
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            authenticatorDatabaseService: otpDatabaseService,
                            domainParser: domainParser,
                            domainIconLibrary: domainIconLibrary,
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeOnboardingChecklistFlowViewModel(displayMode: OnboardingChecklistFlowViewModel.DisplayMode, onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil, completion: @escaping (OnboardingChecklistFlowViewModel.Completion) -> Void) -> OnboardingChecklistFlowViewModel {
            return OnboardingChecklistFlowViewModel(
                            displayMode: displayMode,
                            onboardingChecklistViewAction: onboardingChecklistViewAction,
                            completion: completion,
                            onboardingChecklistViewModelFactory: InjectedFactory(makeOnboardingChecklistViewModel),
                            sessionServices: self
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeOnboardingChecklistViewModel(action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void) -> OnboardingChecklistViewModel {
            return OnboardingChecklistViewModel(
                            session: session,
                            userSettings: spiegelUserSettings,
                            dwmOnboardingSettings: dwmOnboardingSettings,
                            dwmOnboardingService: dwmOnboardingService,
                            vaultItemsService: vaultItemsService,
                            capabilityService: premiumService,
                            featureService: featureService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            activityReporter: activityReporter,
                            action: action,
                            userSpaceSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasskeyDetailViewModel(item: CorePersonalData.Passkey, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> PasskeyDetailViewModel {
            return PasskeyDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            dismiss: dismiss
            )
        }
                
        internal func makePasskeyDetailViewModel(service: DetailService<CorePersonalData.Passkey>) -> PasskeyDetailViewModel {
            return PasskeyDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePassportDetailViewModel(item: Passport, mode: DetailMode = .viewing) -> PassportDetailViewModel {
            return PassportDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makePassportDetailViewModel(service: DetailService<Passport>) -> PassportDetailViewModel {
            return PassportDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordAccessorySectionModel(service: DetailService<Credential>) -> PasswordAccessorySectionModel {
            return PasswordAccessorySectionModel(
                            service: service,
                            passwordEvaluator: passwordEvaluator
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordGeneratorHistoryViewModel() -> PasswordGeneratorHistoryViewModel {
            return PasswordGeneratorHistoryViewModel(
                            database: database,
                            userSettings: spiegelUserSettings,
                            activityReporter: activityReporter,
                            iconService: iconService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makePasswordGeneratorToolsFlowViewModel(pasteboardService: PasteboardService) -> PasswordGeneratorToolsFlowViewModel {
            return PasswordGeneratorToolsFlowViewModel(
                            deepLinkingService: appServices.deepLinkingService,
                            pasteboardService: pasteboardService,
                            passwordGeneratorViewModelFactory: InjectedFactory(makePasswordGeneratorViewModel),
                            passwordGeneratorHistoryViewModelFactory: InjectedFactory(makePasswordGeneratorHistoryViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            saveGeneratedPassword: saveGeneratedPassword,
                            passwordEvaluator: passwordEvaluator,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            savePreferencesOnChange: savePreferencesOnChange,
                            copyAction: copyAction
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: passwordEvaluator,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            savePreferencesOnChange: savePreferencesOnChange,
                            copyAction: copyAction
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: passwordEvaluator,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            copyAction: copyAction
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordHealthDetailedListViewModel(kind: PasswordHealthKind, origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthDetailedListViewModel {
            return PasswordHealthDetailedListViewModel(
                            kind: kind,
                            origin: origin,
                            passwordHealthListViewModelFactory: InjectedFactory(makePasswordHealthListViewModel),
                            passwordHealthService: identityDashboardService,
                            teamSpaceService: teamSpacesService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordHealthFlowViewModel(origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthFlowViewModel {
            return PasswordHealthFlowViewModel(
                            passwordHealthViewModelFactory: InjectedFactory(makePasswordHealthViewModel),
                            passwordHealthDetailedListViewModelFactory: InjectedFactory(makePasswordHealthDetailedListViewModel),
                            credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
                            deeplinkingService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            origin: origin
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordHealthListViewModel(kind: PasswordHealthKind, maximumCredentialsCount: Int? = nil, origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthListViewModel {
            return PasswordHealthListViewModel(
                            kind: kind,
                            maximumCredentialsCount: maximumCredentialsCount,
                            passwordHealthService: identityDashboardService,
                            origin: origin,
                            vaultItemsService: vaultItemsService,
                            teamSpaceService: teamSpacesService,
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordHealthSectionModel(service: DetailService<Credential>) -> PasswordHealthSectionModel {
            return PasswordHealthSectionModel(
                            service: service,
                            passwordEvaluator: passwordEvaluator,
                            identityDashboardService: identityDashboardService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordHealthViewModel(origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthViewModel {
            return PasswordHealthViewModel(
                            passwordHealthListViewModelFactory: InjectedFactory(makePasswordHealthListViewModel),
                            passwordHealthService: identityDashboardService,
                            origin: origin,
                            teamSpaceService: teamSpacesService,
                            userSpaceSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makePasswordLessCompletionViewModel(completion: @escaping () -> Void) -> PasswordLessCompletionViewModel {
            return PasswordLessCompletionViewModel(
                            accountRecoveryActivationFlowFactory: InjectedFactory(makeAccountRecoveryActivationEmbeddedFlowModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePhoneDetailViewModel(item: Phone, mode: DetailMode = .viewing) -> PhoneDetailViewModel {
            return PhoneDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            regionInformationService: appServices.regionInformationService
            )
        }
                
        internal func makePhoneDetailViewModel(service: DetailService<Phone>) -> PhoneDetailViewModel {
            return PhoneDetailViewModel(
                            service: service,
                            regionInformationService: appServices.regionInformationService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePinCodeSettingsViewModel(actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void) -> PinCodeSettingsViewModel {
            return PinCodeSettingsViewModel(
                            session: session,
                            lockService: lockService,
                            teamSpaceService: teamSpacesService,
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePlaceholderWebsiteViewModel(website: String) -> PlaceholderWebsiteViewModel {
            return PlaceholderWebsiteViewModel(
                            website: website,
                            domainIconLibrary: domainIconLibrary
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePostARKChangeMasterPasswordViewModel(accountCryptoChangerService: AccountCryptoChangerServiceProtocol, completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void) -> PostARKChangeMasterPasswordViewModel {
            return PostARKChangeMasterPasswordViewModel(
                            accountCryptoChangerService: accountCryptoChangerService,
                            userDeviceAPIClient: userDeviceAPIClient,
                            syncedSettings: syncedSettings,
                            activityReporter: activityReporter,
                            logger: appServices.rootLogger,
                            migrationProgressViewModelFactory: InjectedFactory(makeMigrationProgressViewModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePostAccountRecoveryLoginFlowModel(authenticationMethod: AuthenticationMethod) -> PostAccountRecoveryLoginFlowModel {
            return PostAccountRecoveryLoginFlowModel(
                            authenticationMethod: authenticationMethod,
                            deeplinkService: appServices.deepLinkingService,
                            changeMasterPasswordFlowViewModelFactory: InjectedFactory(makeChangeMasterPasswordFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePremiumAnnouncementsViewModel(excludedAnnouncements: Set<PremiumAnnouncement> = []) -> PremiumAnnouncementsViewModel {
            return PremiumAnnouncementsViewModel(
                            premiumService: premiumService,
                            teamspaceService: teamSpacesServiceProcotol,
                            featureService: featureService,
                            deeplinkService: appServices.deepLinkingService,
                            userSettings: spiegelUserSettings,
                            excludedAnnouncements: excludedAnnouncements
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeQuickActionsMenuViewModel(item: VaultItem, origin: VaultItemRowModel.Origin, isSuggestedItem: Bool) -> QuickActionsMenuViewModel {
            return QuickActionsMenuViewModel(
                            item: item,
                            sharingService: sharingService,
                            accessControl: accessControl,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            activityReporter: activityReporter,
                            shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel),
                            origin: origin,
                            pasteboardService: pasteboardService,
                            isSuggestedItem: isSuggestedItem
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeRememberMasterPasswordToggleViewModel(actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void) -> RememberMasterPasswordToggleViewModel {
            return RememberMasterPasswordToggleViewModel(
                            lockService: lockService,
                            teamSpacesService: teamSpacesService,
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeResetMasterPasswordNotificationRowViewModel(notification: DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel {
            return ResetMasterPasswordNotificationRowViewModel(
                            notification: notification,
                            resetMasterPasswordIntroViewModelFactory: InjectedFactory(makeResetMasterPasswordIntroViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSSOEnableBiometricsOrPinViewModel() -> SSOEnableBiometricsOrPinViewModel {
            return SSOEnableBiometricsOrPinViewModel(
                            userSettings: spiegelUserSettings,
                            lockService: lockService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSecureLockNotificationRowViewModel(notification: DashlaneNotification) -> SecureLockNotificationRowViewModel {
            return SecureLockNotificationRowViewModel(
                            notification: notification,
                            lockService: lockService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSecureNotesDetailFieldsModel(service: DetailService<SecureNote>) -> SecureNotesDetailFieldsModel {
            return SecureNotesDetailFieldsModel(
                            service: service,
                            featureService: featureService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSecureNotesDetailNavigationBarModel(service: DetailService<SecureNote>, isEditingContent: FocusState<Bool>.Binding) -> SecureNotesDetailNavigationBarModel {
            return SecureNotesDetailNavigationBarModel(
                            service: service,
                            isEditingContent: isEditingContent,
                            featureService: featureService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSecureNotesDetailToolbarModel(service: DetailService<SecureNote>) -> SecureNotesDetailToolbarModel {
            return SecureNotesDetailToolbarModel(
                            service: service,
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSecureNotesDetailViewModel(item: SecureNote, mode: DetailMode = .viewing) -> SecureNotesDetailViewModel {
            return SecureNotesDetailViewModel(
                            item: item,
                            session: session,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            pasteboardService: pasteboardService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarModelFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            logger: appServices.rootLogger,
                            documentStorageService: documentStorageService,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings
            )
        }
                
        internal func makeSecureNotesDetailViewModel(service: DetailService<SecureNote>) -> SecureNotesDetailViewModel {
            return SecureNotesDetailViewModel(
                            service: service,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSecurityAlertNotificationRowViewModel(notification: DashlaneNotification) -> SecurityAlertNotificationRowViewModel {
            return SecurityAlertNotificationRowViewModel(
                            notification: notification,
                            deepLinkingService: appServices.deepLinkingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSecuritySettingsViewModel() -> SecuritySettingsViewModel {
            return SecuritySettingsViewModel(
                            session: session,
                            teamSpacesService: teamSpacesServiceProcotol,
                            featureService: featureService,
                            lockService: lockService,
                            settingsLockSectionViewModelFactory: InjectedFactory(makeSettingsLockSectionViewModel),
                            settingsAccountSectionViewModelFactory: InjectedFactory(makeSettingsAccountSectionViewModel),
                            settingsBiometricToggleViewModelFactory: InjectedFactory(makeSettingsBiometricToggleViewModel),
                            masterPasswordResetActivationViewModelFactory: InjectedFactory(makeMasterPasswordResetActivationViewModel),
                            pinCodeSettingsViewModelFactory: InjectedFactory(makePinCodeSettingsViewModel),
                            rememberMasterPasswordToggleViewModelFactory: InjectedFactory(makeRememberMasterPasswordToggleViewModel),
                            twoFASettingsViewModelFactory: InjectedFactory(makeTwoFASettingsViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSettingsAccountSectionViewModel(actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> SettingsAccountSectionViewModel {
            return SettingsAccountSectionViewModel(
                            session: session,
                            featureService: featureService,
                            teamSpacesService: teamSpacesService,
                            premiumService: premiumService,
                            deviceListViewModel: makeDeviceListViewModel,
                            subscriptionCodeFetcher: subscriptionCodeFetcher,
                            activityReporter: activityReporter,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            deepLinkingService: appServices.deepLinkingService,
                            masterPasswordResetActivationViewModelFactory: InjectedFactory(makeMasterPasswordResetActivationViewModel),
                            changeMasterPasswordFlowViewModelFactory: InjectedFactory(makeChangeMasterPasswordFlowViewModel),
                            accountRecoveryKeyStatusViewModelFactory: InjectedFactory(makeAccountRecoveryKeyStatusViewModel),
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSettingsBiometricToggleViewModel(actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void) -> SettingsBiometricToggleViewModel {
            return SettingsBiometricToggleViewModel(
                            session: session,
                            lockService: lockService,
                            featureService: featureService,
                            resetMasterPasswordService: resetMasterPasswordService,
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSettingsFlowViewModel() -> SettingsFlowViewModel {
            return SettingsFlowViewModel(
                            mainSettingsViewModelFactory: InjectedFactory(makeMainSettingsViewModel),
                            securitySettingsViewModelFactory: InjectedFactory(makeSecuritySettingsViewModel),
                            generalSettingsViewModelFactory: InjectedFactory(makeGeneralSettingsViewModel),
                            helpCenterSettingsViewModelFactory: InjectedFactory(makeHelpCenterSettingsViewModel),
                            labsSettingsViewModelFactory: InjectedFactory(makeLabsSettingsViewModel),
                            deepLinkingService: appServices.deepLinkingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSettingsLockSectionViewModel() -> SettingsLockSectionViewModel {
            return SettingsLockSectionViewModel(
                            lockService: lockService,
                            accessControl: accessControl
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSettingsStatusSectionViewModel() -> SettingsStatusSectionViewModel {
            return SettingsStatusSectionViewModel(
                            premiumService: premiumService,
                            teamSpacesService: teamSpacesServiceProcotol,
                            deepLinkingService: appServices.deepLinkingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeShareButtonViewModel(items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []) -> ShareButtonViewModel {
            return ShareButtonViewModel(
                            items: items,
                            userGroupIds: userGroupIds,
                            userEmails: userEmails,
                            teamSpacesService: teamSpacesService,
                            shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeShareFlowViewModel(items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []) -> ShareFlowViewModel {
            return ShareFlowViewModel(
                            items: items,
                            userGroupIds: userGroupIds,
                            userEmails: userEmails,
                            sharingService: sharingService,
                            premiumService: premiumService,
                            itemsViewModelFactory: InjectedFactory(makeShareItemsSelectionViewModel),
                            recipientsViewModelFactory: InjectedFactory(makeShareRecipientsSelectionViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeShareItemsSelectionViewModel(completion: @MainActor @escaping ([VaultItem]) -> Void) -> ShareItemsSelectionViewModel {
            return ShareItemsSelectionViewModel(
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            itemRowViewModelFactory: InjectedFactory(makeVaultItemRowModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeShareRecipientsSelectionViewModel(configuration: RecipientsConfiguration = .init(), completion: @MainActor @escaping (RecipientsConfiguration) -> Void) -> ShareRecipientsSelectionViewModel {
            return ShareRecipientsSelectionViewModel(
                            session: session,
                            configuration: configuration,
                            sharingService: sharingService,
                            gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingDetailSectionModel(item: VaultItem) -> SharingDetailSectionModel {
            return SharingDetailSectionModel(
                            item: item,
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonModelFactory: InjectedFactory(makeShareButtonViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingItemsUserDetailViewModel(user: SharingItemsUser, userUpdatePublisher: AnyPublisher<SharingItemsUser, Never>, itemsProvider: SharingToolItemsProvider) -> SharingItemsUserDetailViewModel {
            return SharingItemsUserDetailViewModel(
                            user: user,
                            userUpdatePublisher: userUpdatePublisher,
                            itemsProvider: itemsProvider,
                            vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
                            gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
                            detailViewFactory: InjectedFactory(makeDetailView),
                            teamSpacesService: teamSpacesService,
                            sharingService: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingItemsUserGroupDetailViewModel(userGroup: SharingItemsUserGroup, userGroupUpdatePublisher: AnyPublisher<SharingItemsUserGroup, Never>, itemsProvider: SharingToolItemsProvider) -> SharingItemsUserGroupDetailViewModel {
            return SharingItemsUserGroupDetailViewModel(
                            userGroup: userGroup,
                            userGroupUpdatePublisher: userGroupUpdatePublisher,
                            itemsProvider: itemsProvider,
                            vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
                            gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
                            teamSpacesService: teamSpacesService,
                            sharingService: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingMembersDetailLinkModel(item: VaultItem) -> SharingMembersDetailLinkModel {
            return SharingMembersDetailLinkModel(
                            item: item,
                            sharingService: sharingService,
                            detailViewModelFactory: InjectedFactory(makeSharingMembersDetailViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingMembersDetailViewModel(members: ItemSharingMembers, item: VaultItem) -> SharingMembersDetailViewModel {
            return SharingMembersDetailViewModel(
                            members: members,
                            item: item,
                            session: session,
                            personalDataBD: database,
                            gravatarViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
                            shareButtonModelFactory: InjectedFactory(makeShareButtonViewModel),
                            sharingService: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingPendingItemGroupsSectionViewModel() -> SharingPendingItemGroupsSectionViewModel {
            return SharingPendingItemGroupsSectionViewModel(
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingPendingUserGroupsSectionViewModel() -> SharingPendingUserGroupsSectionViewModel {
            return SharingPendingUserGroupsSectionViewModel(
                            teamSpacesService: teamSpacesService,
                            sharingService: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSharingRequestNotificationRowViewModel(notification: DashlaneNotification) -> SharingRequestNotificationRowViewModel {
            return SharingRequestNotificationRowViewModel(
                            notification: notification,
                            deepLinkingService: appServices.deepLinkingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingToolItemsProvider() -> SharingToolItemsProvider {
            return SharingToolItemsProvider(
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingToolViewModel() -> SharingToolViewModel {
            return SharingToolViewModel(
                            itemsProviderFactory: InjectedFactory(makeSharingToolItemsProvider),
                            pendingUserGroupsSectionViewModelFactory: InjectedFactory(makeSharingPendingUserGroupsSectionViewModel),
                            pendingItemGroupsSectionViewModelFactory: InjectedFactory(makeSharingPendingItemGroupsSectionViewModel),
                            userGroupsSectionViewModelFactory: InjectedFactory(makeSharingUserGroupsSectionViewModel),
                            usersSectionViewModelFactory: InjectedFactory(makeSharingUsersSectionViewModel),
                            userSpaceSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            sharingService: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingToolsFlowViewModel() -> SharingToolsFlowViewModel {
            return SharingToolsFlowViewModel(
                            accessControl: accessControl,
                            detailViewFactory: InjectedFactory(makeDetailView),
                            sharingToolViewModelFactory: InjectedFactory(makeSharingToolViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingUserGroupsSectionViewModel(itemsProvider: SharingToolItemsProvider) -> SharingUserGroupsSectionViewModel {
            return SharingUserGroupsSectionViewModel(
                            itemsProvider: itemsProvider,
                            detailViewModelFactory: InjectedFactory(makeSharingItemsUserGroupDetailViewModel),
                            sharingService: sharingService,
                            teamSpacesService: vaultKitTeamSpacesServiceProcotol
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeSharingUsersSectionViewModel(itemsProvider: SharingToolItemsProvider) -> SharingUsersSectionViewModel {
            return SharingUsersSectionViewModel(
                            itemsProvider: itemsProvider,
                            sharingService: sharingService,
                            detailViewModelFactory: InjectedFactory(makeSharingItemsUserDetailViewModel),
                            gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSidebarViewModel() -> SidebarViewModel {
            return SidebarViewModel(
                            toolsService: toolsService,
                            teamSpacesService: vaultKitTeamSpacesServiceProcotol,
                            vaultItemsService: vaultItemsService,
                            deeplinkingService: appServices.deepLinkingService,
                            settingsFlowViewModelFactory: InjectedFactory(makeSettingsFlowViewModel),
                            collectionNamingViewModelFactory: InjectedFactory(makeCollectionNamingViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSocialSecurityDetailViewModel(item: SocialSecurityInformation, mode: DetailMode = .viewing) -> SocialSecurityDetailViewModel {
            return SocialSecurityDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeSocialSecurityDetailViewModel(service: DetailService<SocialSecurityInformation>) -> SocialSecurityDetailViewModel {
            return SocialSecurityDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeToolsFlowViewModel(toolsItem: ToolsItem?) -> ToolsFlowViewModel {
            return ToolsFlowViewModel(
                            toolsItem: toolsItem,
                            userSettings: spiegelUserSettings,
                            vpnService: vpnService,
                            capabilityService: premiumService,
                            deepLinkingService: appServices.deepLinkingService,
                            darkWebMonitoringService: darkWebMonitoringService,
                            toolsViewModelFactory: InjectedFactory(makeToolsViewModel),
                            passwordHealthFlowViewModelFactory: InjectedFactory(makePasswordHealthFlowViewModel),
                            authenticatorToolFlowViewModelFactory: InjectedFactory(makeAuthenticatorToolFlowViewModel),
                            passwordGeneratorToolsFlowViewModelFactory: InjectedFactory(makePasswordGeneratorToolsFlowViewModel),
                            vpnAvailableToolsFlowViewModelFactory: InjectedFactory(makeVPNAvailableToolsFlowViewModel),
                            sharingToolsFlowViewModelFactory: InjectedFactory(makeSharingToolsFlowViewModel),
                            darkWebToolsFlowViewModelFactory: InjectedFactory(makeDarkWebToolsFlowViewModel),
                            unresolvedAlertViewModelFactory: InjectedFactory(makeUnresolvedAlertViewModel),
                            collectionsFlowViewModelFactory: InjectedFactory(makeCollectionsFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeToolsViewModel(didSelectItem: PassthroughSubject<ToolsItem, Never>) -> ToolsViewModel {
            return ToolsViewModel(
                            toolsService: toolsService,
                            premiumService: premiumService,
                            didSelectItem: didSelectItem
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeTrialPeriodNotificationRowViewModel(notification: DashlaneNotification) -> TrialPeriodNotificationRowViewModel {
            return TrialPeriodNotificationRowViewModel(
                            notification: notification,
                            capabilityService: premiumService,
                            deepLinkingService: appServices.deepLinkingService,
                            activityReporter: activityReporter
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFAActivationViewModel() -> TwoFAActivationViewModel {
            return TwoFAActivationViewModel(
                            authenticatedAPIClient: userDeviceAPIClient,
                            twoFAPhoneNumberSetupViewModelFactory: InjectedFactory(makeTwoFAPhoneNumberSetupViewModel),
                            makeTwoFACompletionViewModelFactory: InjectedFactory(makeTwoFACompletionViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeTwoFACompletionViewModel(option: TFAOption, response: TOTPActivationResponse, completion: @escaping () -> Void) -> TwoFACompletionViewModel {
            return TwoFACompletionViewModel(
                            option: option,
                            response: response,
                            session: session,
                            sessionsContainer: appServices.sessionContainer,
                            keychainService: appServices.keychainService,
                            authenticatorCommunicator: authenticatorAppCommunicator,
                            syncService: syncService,
                            resetMasterPasswordService: resetMasterPasswordService,
                            databaseDriver: databaseDriver,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            activityReporter: activityReporter,
                            authenticatedAPIClient: userDeviceAPIClient,
                            appAPIClient: appServices.appAPIClient,
                            userDeviceAPIClient: userDeviceAPIClient,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            logger: appServices.rootLogger,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFADeactivationViewModel(isTwoFAEnforced: Bool, recover2faWebService: Recover2FAWebService) -> TwoFADeactivationViewModel {
            return TwoFADeactivationViewModel(
                            session: session,
                            sessionsContainer: appServices.sessionContainer,
                            authenticatedAPIClient: userDeviceAPIClient,
                            appAPIClient: appServices.appAPIClient,
                            userAPIClient: userDeviceAPIClient,
                            logger: appServices.rootLogger,
                            authenticatorCommunicator: authenticatorAppCommunicator,
                            syncService: syncService,
                            keychainService: appServices.keychainService,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            activityReporter: activityReporter,
                            resetMasterPasswordService: resetMasterPasswordService,
                            databaseDriver: databaseDriver,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            isTwoFAEnforced: isTwoFAEnforced,
                            recover2faWebService: recover2faWebService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFAPhoneNumberSetupViewModel(option: TFAOption, completion: @escaping (TOTPActivationResponse?) -> Void) -> TwoFAPhoneNumberSetupViewModel {
            return TwoFAPhoneNumberSetupViewModel(
                            userAPIClient: userDeviceAPIClient,
                            option: option,
                            regionInformationService: appServices.regionInformationService,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFASettingsViewModel(login: Login, loginOTPOption: ThirdPartyOTPOption?, isTwoFAEnforced: Bool) -> TwoFASettingsViewModel {
            return TwoFASettingsViewModel(
                            login: login,
                            loginOTPOption: loginOTPOption,
                            userAPIClient: userDeviceAPIClient,
                            nonAuthenticatedUKIBasedWebService: legacyWebService,
                            logger: appServices.rootLogger,
                            isTwoFAEnforced: isTwoFAEnforced,
                            reachability: appServices.networkReachability,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            twoFADeactivationViewModelFactory: InjectedFactory(makeTwoFADeactivationViewModel),
                            twoFAActivationViewModelFactory: InjectedFactory(makeTwoFAActivationViewModel),
                            twoFASetupViewModelFactory: InjectedFactory(makeTwoFASetupViewModel),
                            twoFactorEnforcementViewModelFactory: InjectedFactory(makeTwoFactorEnforcementViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFASetupViewModel() -> TwoFASetupViewModel {
            return TwoFASetupViewModel(
                            lockService: lockService,
                            twoFAActivationViewModelFactory: InjectedFactory(makeTwoFAActivationViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFactorEnforcementViewModel(logout: @escaping () -> Void) -> TwoFactorEnforcementViewModel {
            return TwoFactorEnforcementViewModel(
                            userDeviceAPIClient: userDeviceAPIClient,
                            lockService: lockService,
                            twoFASetupViewModelFactory: InjectedFactory(makeTwoFASetupViewModel),
                            logout: logout
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeUnresolvedAlertViewModel() -> UnresolvedAlertViewModel {
            return UnresolvedAlertViewModel(
                            identityDashboardService: identityDashboardService,
                            deeplinkService: appServices.deepLinkingService,
                            passwordHealthFlowViewModelFactory: InjectedFactory(makePasswordHealthFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVPNActivationViewModel(actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>, activationState: VPNActivationState = .initial) -> VPNActivationViewModel {
            return VPNActivationViewModel(
                            vpnService: vpnService,
                            activityReporter: activityReporter,
                            session: session,
                            actionPublisher: actionPublisher,
                            activationState: activationState
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeVPNAvailableToolsFlowViewModel() -> VPNAvailableToolsFlowViewModel {
            return VPNAvailableToolsFlowViewModel(
                            session: session,
                            activityReporter: activityReporter,
                            vpnMainViewModelFactory: InjectedFactory(makeVPNMainViewModel),
                            vpnActivationViewModelFactory: InjectedFactory(makeVPNActivationViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVPNMainViewModel(mode: VPNMainViewModel.VPNMainViewMode, credential: Credential? = nil, actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>? = nil) -> VPNMainViewModel {
            return VPNMainViewModel(
                            mode: mode,
                            credential: credential,
                            vaultItemsService: vaultItemsService,
                            userSettings: spiegelUserSettings,
                            activityReporter: activityReporter,
                            accessControl: accessControl,
                            iconService: iconService,
                            pasteboardService: pasteboardService,
                            actionPublisher: actionPublisher
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeVaultFlowViewModel(itemCategory: ItemCategory? = nil, onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil) -> VaultFlowViewModel {
            return VaultFlowViewModel(
                            itemCategory: itemCategory,
                            onboardingChecklistViewAction: onboardingChecklistViewAction,
                            detailViewFactory: InjectedFactory(makeDetailView),
                            homeViewModelFactory: InjectedFactory(makeHomeViewModel),
                            vaultListViewModelFactory: InjectedFactory(makeVaultListViewModel),
                            addItemFlowViewModelFactory: InjectedFactory(makeAddItemFlowViewModel),
                            autofillOnboardingFlowViewModelFactory: InjectedFactory(makeAutofillOnboardingFlowViewModel),
                            onboardingChecklistFlowViewModelFactory: InjectedFactory(makeOnboardingChecklistFlowViewModel),
                            sessionServices: self
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVaultItemIconViewModel(item: VaultItem) -> VaultItemIconViewModel {
            return VaultItemIconViewModel(
                            item: item,
                            iconLibrary: domainIconLibrary
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVaultItemRowModel(configuration: VaultItemRowModel.Configuration, additionalConfiguration: VaultItemRowModel.AdditionalConfiguration? = nil) -> VaultItemRowModel {
            return VaultItemRowModel(
                            configuration: configuration,
                            additionalConfiguration: additionalConfiguration,
                            vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
                            quickActionsMenuViewModelFactory: InjectedFactory(makeQuickActionsMenuViewModel),
                            userSettings: spiegelUserSettings,
                            accessControl: accessControl,
                            pasteboardService: pasteboardService,
                            activityReporter: activityReporter,
                            teamSpacesService: teamSpacesService,
                            vaultItemsService: vaultItemsService,
                            sharingPermissionProvider: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVaultListViewModel(filter: VaultItemsSection, completion: @escaping (VaultListCompletion) -> Void) -> VaultListViewModel {
            return VaultListViewModel(
                            filter: filter,
                            activityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            searchViewModelFactory: InjectedFactory(makeVaultSearchViewModel),
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVaultSearchViewModel(activeFilter: VaultItemsSection, completion: @escaping (VaultListCompletion) -> Void) -> VaultSearchViewModel {
            return VaultSearchViewModel(
                            vaultItemsService: vaultItemsService,
                            capabilityService: premiumService,
                            sharingService: sharingService,
                            featureService: featureService,
                            activityReporter: activityReporter,
                            teamSpacesService: teamSpacesService,
                            userSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel),
                            vaultItemRowModelFactory: InjectedFactory(makeVaultItemRowModel),
                            activeFilter: activeFilter,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeWebsiteDetailViewModel(item: PersonalWebsite, mode: DetailMode = .viewing) -> WebsiteDetailViewModel {
            return WebsiteDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            documentStorageService: documentStorageService,
                            deepLinkService: vaultKitDeepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            pasteboardService: pasteboardService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
            )
        }
                
        internal func makeWebsiteDetailViewModel(service: DetailService<PersonalWebsite>) -> WebsiteDetailViewModel {
            return WebsiteDetailViewModel(
                            service: service
            )
        }
        
}


internal typealias _AccountCreationFlowViewModelFactory = @MainActor (
    _ completion: @MainActor @escaping (AccountCreationFlowViewModel.CompletionResult) -> Void
) -> AccountCreationFlowViewModel

internal extension InjectedFactory where T == _AccountCreationFlowViewModelFactory {
    @MainActor
    func make(completion: @MainActor @escaping (AccountCreationFlowViewModel.CompletionResult) -> Void) -> AccountCreationFlowViewModel {
       return factory(
              completion
       )
    }
}

extension AccountCreationFlowViewModel {
        internal typealias Factory = InjectedFactory<_AccountCreationFlowViewModelFactory>
}


internal typealias _AccountEmailViewModelFactory = @MainActor (
    _ completion: @escaping (_ result: AccountEmailViewModel.CompletionResult) -> Void
) -> AccountEmailViewModel

internal extension InjectedFactory where T == _AccountEmailViewModelFactory {
    @MainActor
    func make(completion: @escaping (_ result: AccountEmailViewModel.CompletionResult) -> Void) -> AccountEmailViewModel {
       return factory(
              completion
       )
    }
}

extension AccountEmailViewModel {
        internal typealias Factory = InjectedFactory<_AccountEmailViewModelFactory>
}


internal typealias _AccountRecoveryActivationEmbeddedFlowModelFactory = @MainActor (
    _ context: AccountRecoveryActivationContext,
    _ completion: @MainActor @escaping () -> Void
) -> AccountRecoveryActivationEmbeddedFlowModel

internal extension InjectedFactory where T == _AccountRecoveryActivationEmbeddedFlowModelFactory {
    @MainActor
    func make(context: AccountRecoveryActivationContext, completion: @MainActor @escaping () -> Void) -> AccountRecoveryActivationEmbeddedFlowModel {
       return factory(
              context,
              completion
       )
    }
}

extension AccountRecoveryActivationEmbeddedFlowModel {
        internal typealias Factory = InjectedFactory<_AccountRecoveryActivationEmbeddedFlowModelFactory>
}


internal typealias _AccountRecoveryActivationFlowModelFactory = @MainActor (
    _ context: AccountRecoveryActivationContext
) -> AccountRecoveryActivationFlowModel

internal extension InjectedFactory where T == _AccountRecoveryActivationFlowModelFactory {
    @MainActor
    func make(context: AccountRecoveryActivationContext) -> AccountRecoveryActivationFlowModel {
       return factory(
              context
       )
    }
}

extension AccountRecoveryActivationFlowModel {
        internal typealias Factory = InjectedFactory<_AccountRecoveryActivationFlowModelFactory>
}


internal typealias _AccountRecoveryKeyStatusDetailViewModelFactory = @MainActor (
    _ isEnabled: Bool
) -> AccountRecoveryKeyStatusDetailViewModel

internal extension InjectedFactory where T == _AccountRecoveryKeyStatusDetailViewModelFactory {
    @MainActor
    func make(isEnabled: Bool) -> AccountRecoveryKeyStatusDetailViewModel {
       return factory(
              isEnabled
       )
    }
}

extension AccountRecoveryKeyStatusDetailViewModel {
        internal typealias Factory = InjectedFactory<_AccountRecoveryKeyStatusDetailViewModelFactory>
}


internal typealias _AccountRecoveryKeyStatusViewModelFactory = @MainActor (
) -> AccountRecoveryKeyStatusViewModel

internal extension InjectedFactory where T == _AccountRecoveryKeyStatusViewModelFactory {
    @MainActor
    func make() -> AccountRecoveryKeyStatusViewModel {
       return factory(
       )
    }
}

extension AccountRecoveryKeyStatusViewModel {
        internal typealias Factory = InjectedFactory<_AccountRecoveryKeyStatusViewModelFactory>
}


public typealias _AddAttachmentButtonViewModelFactory =  (
    _ editingItem: VaultItem,
    _ shouldDisplayRenameAlert: Bool,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AddAttachmentButtonViewModel

public extension InjectedFactory where T == _AddAttachmentButtonViewModelFactory {
    
    func make(editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
       return factory(
              editingItem,
              shouldDisplayRenameAlert,
              itemPublisher
       )
    }
}

extension AddAttachmentButtonViewModel {
        public typealias Factory = InjectedFactory<_AddAttachmentButtonViewModelFactory>
}


internal typealias _AddItemFlowViewModelFactory = @MainActor (
    _ displayMode: AddItemFlowViewModel.DisplayMode,
    _ completion: @escaping (AddItemFlowViewModel.Completion) -> Void
) -> AddItemFlowViewModel

internal extension InjectedFactory where T == _AddItemFlowViewModelFactory {
    @MainActor
    func make(displayMode: AddItemFlowViewModel.DisplayMode, completion: @escaping (AddItemFlowViewModel.Completion) -> Void) -> AddItemFlowViewModel {
       return factory(
              displayMode,
              completion
       )
    }
}

extension AddItemFlowViewModel {
        internal typealias Factory = InjectedFactory<_AddItemFlowViewModelFactory>
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


internal typealias _AddNewDeviceViewModelFactory = @MainActor (
    _ qrCodeViaSystemCamera: String?
) -> AddNewDeviceViewModel

internal extension InjectedFactory where T == _AddNewDeviceViewModelFactory {
    @MainActor
    func make(qrCodeViaSystemCamera: String? = nil) -> AddNewDeviceViewModel {
       return factory(
              qrCodeViaSystemCamera
       )
    }
}

extension AddNewDeviceViewModel {
        internal typealias Factory = InjectedFactory<_AddNewDeviceViewModelFactory>
}


internal typealias _AddOTPFlowViewModelFactory =  (
    _ mode: AddOTPFlowViewModel.Mode,
    _ completion: @escaping () -> Void
) -> AddOTPFlowViewModel

internal extension InjectedFactory where T == _AddOTPFlowViewModelFactory {
    
    func make(mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void) -> AddOTPFlowViewModel {
       return factory(
              mode,
              completion
       )
    }
}

extension AddOTPFlowViewModel {
        internal typealias Factory = InjectedFactory<_AddOTPFlowViewModelFactory>
}


internal typealias _AddOTPManuallyFlowViewModelFactory =  (
    _ credential: Credential?,
    _ completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void
) -> AddOTPManuallyFlowViewModel

internal extension InjectedFactory where T == _AddOTPManuallyFlowViewModelFactory {
    
    func make(credential: Credential?, completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void) -> AddOTPManuallyFlowViewModel {
       return factory(
              credential,
              completion
       )
    }
}

extension AddOTPManuallyFlowViewModel {
        internal typealias Factory = InjectedFactory<_AddOTPManuallyFlowViewModelFactory>
}


internal typealias _AddPrefilledCredentialViewModelFactory =  (
    _ didChooseCredential: @escaping (Credential, Bool) -> Void
) -> AddPrefilledCredentialViewModel

internal extension InjectedFactory where T == _AddPrefilledCredentialViewModelFactory {
    
    func make(didChooseCredential: @escaping (Credential, Bool) -> Void) -> AddPrefilledCredentialViewModel {
       return factory(
              didChooseCredential
       )
    }
}

extension AddPrefilledCredentialViewModel {
        internal typealias Factory = InjectedFactory<_AddPrefilledCredentialViewModelFactory>
}


internal typealias _AddressDetailViewModelFactory =  (
    _ item: Address,
    _ mode: DetailMode,
    _ dismiss: (() -> Void)?
) -> AddressDetailViewModel

internal extension InjectedFactory where T == _AddressDetailViewModelFactory {
    
    func make(item: Address, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> AddressDetailViewModel {
       return factory(
              item,
              mode,
              dismiss
       )
    }
}

extension AddressDetailViewModel {
        internal typealias Factory = InjectedFactory<_AddressDetailViewModelFactory>
}


internal typealias _AddressDetailViewModelSecondFactory =  (
    _ service: DetailService<Address>
) -> AddressDetailViewModel

internal extension InjectedFactory where T == _AddressDetailViewModelSecondFactory {
    
    func make(service: DetailService<Address>) -> AddressDetailViewModel {
       return factory(
              service
       )
    }
}

extension AddressDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_AddressDetailViewModelSecondFactory>
}


public typealias _AttachmentRowViewModelFactory =  (
    _ attachment: Attachment,
    _ attachmentPublisher: AnyPublisher<Attachment, Never>,
    _ editingItem: DocumentAttachable,
    _ deleteAction: @escaping (Attachment) -> Void
) -> AttachmentRowViewModel

public extension InjectedFactory where T == _AttachmentRowViewModelFactory {
    
    func make(attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>, editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void) -> AttachmentRowViewModel {
       return factory(
              attachment,
              attachmentPublisher,
              editingItem,
              deleteAction
       )
    }
}

extension AttachmentRowViewModel {
        public typealias Factory = InjectedFactory<_AttachmentRowViewModelFactory>
}


public typealias _AttachmentsListViewModelFactory =  (
    _ editingItem: VaultItem,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsListViewModel

public extension InjectedFactory where T == _AttachmentsListViewModelFactory {
    
    func make(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
       return factory(
              editingItem,
              itemPublisher
       )
    }
}

extension AttachmentsListViewModel {
        public typealias Factory = InjectedFactory<_AttachmentsListViewModelFactory>
}


public typealias _AttachmentsSectionViewModelFactory =  (
    _ item: VaultItem,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsSectionViewModel

public extension InjectedFactory where T == _AttachmentsSectionViewModelFactory {
    
    func make(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsSectionViewModel {
       return factory(
              item,
              itemPublisher
       )
    }
}

extension AttachmentsSectionViewModel {
        public typealias Factory = InjectedFactory<_AttachmentsSectionViewModelFactory>
}


internal typealias _AuthenticatorNotificationRowViewModelFactory =  (
    _ notification: DashlaneNotification
) -> AuthenticatorNotificationRowViewModel

internal extension InjectedFactory where T == _AuthenticatorNotificationRowViewModelFactory {
    
    func make(notification: DashlaneNotification) -> AuthenticatorNotificationRowViewModel {
       return factory(
              notification
       )
    }
}

extension AuthenticatorNotificationRowViewModel {
        internal typealias Factory = InjectedFactory<_AuthenticatorNotificationRowViewModelFactory>
}


internal typealias _AuthenticatorToolFlowViewModelFactory =  (
) -> AuthenticatorToolFlowViewModel

internal extension InjectedFactory where T == _AuthenticatorToolFlowViewModelFactory {
    
    func make() -> AuthenticatorToolFlowViewModel {
       return factory(
       )
    }
}

extension AuthenticatorToolFlowViewModel {
        internal typealias Factory = InjectedFactory<_AuthenticatorToolFlowViewModelFactory>
}


internal typealias _BankAccountDetailViewModelFactory =  (
    _ item: BankAccount,
    _ mode: DetailMode
) -> BankAccountDetailViewModel

internal extension InjectedFactory where T == _BankAccountDetailViewModelFactory {
    
    func make(item: BankAccount, mode: DetailMode = .viewing) -> BankAccountDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension BankAccountDetailViewModel {
        internal typealias Factory = InjectedFactory<_BankAccountDetailViewModelFactory>
}


internal typealias _BankAccountDetailViewModelSecondFactory =  (
    _ service: DetailService<BankAccount>
) -> BankAccountDetailViewModel

internal extension InjectedFactory where T == _BankAccountDetailViewModelSecondFactory {
    
    func make(service: DetailService<BankAccount>) -> BankAccountDetailViewModel {
       return factory(
              service
       )
    }
}

extension BankAccountDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_BankAccountDetailViewModelSecondFactory>
}


internal typealias _BreachDetailViewModelFactory =  (
    _ breach: DWMSimplifiedBreach,
    _ email: String,
    _ completion: @escaping (BreachDetailViewModel.Completion) -> Void
) -> BreachDetailViewModel

internal extension InjectedFactory where T == _BreachDetailViewModelFactory {
    
    func make(breach: DWMSimplifiedBreach, email: String, completion: @escaping (BreachDetailViewModel.Completion) -> Void) -> BreachDetailViewModel {
       return factory(
              breach,
              email,
              completion
       )
    }
}

extension BreachDetailViewModel {
        internal typealias Factory = InjectedFactory<_BreachDetailViewModelFactory>
}


internal typealias _BreachViewModelFactory =  (
    _ hasBeenAddressed: Bool,
    _ url: PersonalDataURL,
    _ leakedPassword: String?,
    _ leakDate: Date?,
    _ email: String?,
    _ otherLeakedData: [String]?,
    _ simplifiedBreach: DWMSimplifiedBreach?
) -> BreachViewModel

internal extension InjectedFactory where T == _BreachViewModelFactory {
    
    func make(hasBeenAddressed: Bool, url: PersonalDataURL, leakedPassword: String?, leakDate: Date?, email: String? = nil, otherLeakedData: [String]? = nil, simplifiedBreach: DWMSimplifiedBreach? = nil) -> BreachViewModel {
       return factory(
              hasBeenAddressed,
              url,
              leakedPassword,
              leakDate,
              email,
              otherLeakedData,
              simplifiedBreach
       )
    }
}

extension BreachViewModel {
        internal typealias Factory = InjectedFactory<_BreachViewModelFactory>
}


internal typealias _BreachViewModelSecondFactory =  (
    _ breach: DWMSimplifiedBreach
) -> BreachViewModel

internal extension InjectedFactory where T == _BreachViewModelSecondFactory {
    
    func make(breach: DWMSimplifiedBreach) -> BreachViewModel {
       return factory(
              breach
       )
    }
}

extension BreachViewModel {
        internal typealias SecondFactory = InjectedFactory<_BreachViewModelSecondFactory>
}


internal typealias _BreachViewModelThirdFactory =  (
    _ credential: Credential
) -> BreachViewModel

internal extension InjectedFactory where T == _BreachViewModelThirdFactory {
    
    func make(credential: Credential) -> BreachViewModel {
       return factory(
              credential
       )
    }
}

extension BreachViewModel {
        internal typealias ThirdFactory = InjectedFactory<_BreachViewModelThirdFactory>
}


internal typealias _BreachesListViewModelFactory =  (
    _ completion: @escaping (BreachesListViewModel.Completion) -> Void
) -> BreachesListViewModel

internal extension InjectedFactory where T == _BreachesListViewModelFactory {
    
    func make(completion: @escaping (BreachesListViewModel.Completion) -> Void) -> BreachesListViewModel {
       return factory(
              completion
       )
    }
}

extension BreachesListViewModel {
        internal typealias Factory = InjectedFactory<_BreachesListViewModelFactory>
}


internal typealias _ChangeMasterPasswordFlowViewModelFactory =  (
) -> ChangeMasterPasswordFlowViewModel

internal extension InjectedFactory where T == _ChangeMasterPasswordFlowViewModelFactory {
    
    func make() -> ChangeMasterPasswordFlowViewModel {
       return factory(
       )
    }
}

extension ChangeMasterPasswordFlowViewModel {
        internal typealias Factory = InjectedFactory<_ChangeMasterPasswordFlowViewModelFactory>
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


internal typealias _CollectionDetailViewModelFactory =  (
    _ collection: VaultCollection
) -> CollectionDetailViewModel

internal extension InjectedFactory where T == _CollectionDetailViewModelFactory {
    
    func make(collection: VaultCollection) -> CollectionDetailViewModel {
       return factory(
              collection
       )
    }
}

extension CollectionDetailViewModel {
        internal typealias Factory = InjectedFactory<_CollectionDetailViewModelFactory>
}


internal typealias _CollectionsFlowViewModelFactory = @MainActor (
    _ initialStep: CollectionsFlowViewModel.Step
) -> CollectionsFlowViewModel

internal extension InjectedFactory where T == _CollectionsFlowViewModelFactory {
    @MainActor
    func make(initialStep: CollectionsFlowViewModel.Step = .list) -> CollectionsFlowViewModel {
       return factory(
              initialStep
       )
    }
}

extension CollectionsFlowViewModel {
        internal typealias Factory = InjectedFactory<_CollectionsFlowViewModelFactory>
}


internal typealias _CompanyDetailViewModelFactory =  (
    _ item: Company,
    _ mode: DetailMode
) -> CompanyDetailViewModel

internal extension InjectedFactory where T == _CompanyDetailViewModelFactory {
    
    func make(item: Company, mode: DetailMode = .viewing) -> CompanyDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension CompanyDetailViewModel {
        internal typealias Factory = InjectedFactory<_CompanyDetailViewModelFactory>
}


internal typealias _CompanyDetailViewModelSecondFactory =  (
    _ service: DetailService<Company>
) -> CompanyDetailViewModel

internal extension InjectedFactory where T == _CompanyDetailViewModelSecondFactory {
    
    func make(service: DetailService<Company>) -> CompanyDetailViewModel {
       return factory(
              service
       )
    }
}

extension CompanyDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_CompanyDetailViewModelSecondFactory>
}


internal typealias _CredentialDetailViewModelFactory =  (
    _ item: Credential,
    _ mode: DetailMode,
    _ generatedPasswordToLink: GeneratedPassword?,
    _ actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>?,
    _ origin: ItemDetailOrigin,
    _ didSave: (() -> Void)?
) -> CredentialDetailViewModel

internal extension InjectedFactory where T == _CredentialDetailViewModelFactory {
    
    func make(item: Credential, mode: DetailMode = .viewing, generatedPasswordToLink: GeneratedPassword? = nil, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil) -> CredentialDetailViewModel {
       return factory(
              item,
              mode,
              generatedPasswordToLink,
              actionPublisher,
              origin,
              didSave
       )
    }
}

extension CredentialDetailViewModel {
        internal typealias Factory = InjectedFactory<_CredentialDetailViewModelFactory>
}


internal typealias _CredentialDetailViewModelSecondFactory =  (
    _ generatedPasswordToLink: GeneratedPassword?,
    _ actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>?,
    _ origin: ItemDetailOrigin,
    _ didSave: (() -> Void)?,
    _ service: DetailService<Credential>
) -> CredentialDetailViewModel

internal extension InjectedFactory where T == _CredentialDetailViewModelSecondFactory {
    
    func make(generatedPasswordToLink: GeneratedPassword? = nil, actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil, origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil, service: DetailService<Credential>) -> CredentialDetailViewModel {
       return factory(
              generatedPasswordToLink,
              actionPublisher,
              origin,
              didSave,
              service
       )
    }
}

extension CredentialDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_CredentialDetailViewModelSecondFactory>
}


internal typealias _CredentialMainSectionModelFactory =  (
    _ service: DetailService<Credential>,
    _ code: Binding<String>,
    _ isAutoFillDemoModalShown: Binding<Bool>,
    _ isAdd2FAFlowPresented: Binding<Bool>
) -> CredentialMainSectionModel

internal extension InjectedFactory where T == _CredentialMainSectionModelFactory {
    
    func make(service: DetailService<Credential>, code: Binding<String>, isAutoFillDemoModalShown: Binding<Bool>, isAdd2FAFlowPresented: Binding<Bool>) -> CredentialMainSectionModel {
       return factory(
              service,
              code,
              isAutoFillDemoModalShown,
              isAdd2FAFlowPresented
       )
    }
}

extension CredentialMainSectionModel {
        internal typealias Factory = InjectedFactory<_CredentialMainSectionModelFactory>
}


internal typealias _CreditCardDetailViewModelFactory =  (
    _ item: CreditCard,
    _ mode: DetailMode,
    _ dismiss: (() -> Void)?
) -> CreditCardDetailViewModel

internal extension InjectedFactory where T == _CreditCardDetailViewModelFactory {
    
    func make(item: CreditCard, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> CreditCardDetailViewModel {
       return factory(
              item,
              mode,
              dismiss
       )
    }
}

extension CreditCardDetailViewModel {
        internal typealias Factory = InjectedFactory<_CreditCardDetailViewModelFactory>
}


internal typealias _CreditCardDetailViewModelSecondFactory =  (
    _ service: DetailService<CreditCard>
) -> CreditCardDetailViewModel

internal extension InjectedFactory where T == _CreditCardDetailViewModelSecondFactory {
    
    func make(service: DetailService<CreditCard>) -> CreditCardDetailViewModel {
       return factory(
              service
       )
    }
}

extension CreditCardDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_CreditCardDetailViewModelSecondFactory>
}


internal typealias _DWMEmailConfirmationViewModelFactory = @MainActor (
    _ accountEmail: String,
    _ emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy
) -> DWMEmailConfirmationViewModel

internal extension InjectedFactory where T == _DWMEmailConfirmationViewModelFactory {
    @MainActor
    func make(accountEmail: String, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy) -> DWMEmailConfirmationViewModel {
       return factory(
              accountEmail,
              emailStatusCheck
       )
    }
}

extension DWMEmailConfirmationViewModel {
        internal typealias Factory = InjectedFactory<_DWMEmailConfirmationViewModelFactory>
}


internal typealias _DWMItemIconViewModelFactory =  (
    _ url: PersonalDataURL
) -> DWMItemIconViewModel

internal extension InjectedFactory where T == _DWMItemIconViewModelFactory {
    
    func make(url: PersonalDataURL) -> DWMItemIconViewModel {
       return factory(
              url
       )
    }
}

extension DWMItemIconViewModel {
        internal typealias Factory = InjectedFactory<_DWMItemIconViewModelFactory>
}


internal typealias _DWMOnboardingFlowViewModelFactory = @MainActor (
    _ transitionHandler: GuidedOnboardingTransitionHandler?,
    _ completion: @escaping (DWMOnboardingFlowViewModel.Completion) -> Void
) -> DWMOnboardingFlowViewModel

internal extension InjectedFactory where T == _DWMOnboardingFlowViewModelFactory {
    @MainActor
    func make(transitionHandler: GuidedOnboardingTransitionHandler?, completion: @escaping (DWMOnboardingFlowViewModel.Completion) -> Void) -> DWMOnboardingFlowViewModel {
       return factory(
              transitionHandler,
              completion
       )
    }
}

extension DWMOnboardingFlowViewModel {
        internal typealias Factory = InjectedFactory<_DWMOnboardingFlowViewModelFactory>
}


internal typealias _DWMRegistrationInGuidedOnboardingViewModelFactory = @MainActor (
    _ email: String
) -> DWMRegistrationInGuidedOnboardingViewModel

internal extension InjectedFactory where T == _DWMRegistrationInGuidedOnboardingViewModelFactory {
    @MainActor
    func make(email: String) -> DWMRegistrationInGuidedOnboardingViewModel {
       return factory(
              email
       )
    }
}

extension DWMRegistrationInGuidedOnboardingViewModel {
        internal typealias Factory = InjectedFactory<_DWMRegistrationInGuidedOnboardingViewModelFactory>
}


internal typealias _DarkWebMonitoringBreachListViewModelFactory =  (
    _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?
) -> DarkWebMonitoringBreachListViewModel

internal extension InjectedFactory where T == _DarkWebMonitoringBreachListViewModelFactory {
    
    func make(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?) -> DarkWebMonitoringBreachListViewModel {
       return factory(
              actionPublisher
       )
    }
}

extension DarkWebMonitoringBreachListViewModel {
        internal typealias Factory = InjectedFactory<_DarkWebMonitoringBreachListViewModelFactory>
}


internal typealias _DarkWebMonitoringDetailsViewModelFactory =  (
    _ breach: DWMSimplifiedBreach,
    _ breachViewModel: BreachViewModel,
    _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?
) -> DarkWebMonitoringDetailsViewModel

internal extension InjectedFactory where T == _DarkWebMonitoringDetailsViewModelFactory {
    
    func make(breach: DWMSimplifiedBreach, breachViewModel: BreachViewModel, actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil) -> DarkWebMonitoringDetailsViewModel {
       return factory(
              breach,
              breachViewModel,
              actionPublisher
       )
    }
}

extension DarkWebMonitoringDetailsViewModel {
        internal typealias Factory = InjectedFactory<_DarkWebMonitoringDetailsViewModelFactory>
}


internal typealias _DarkWebMonitoringEmailRowViewModelFactory =  (
    _ email: DataLeakEmail,
    _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
) -> DarkWebMonitoringEmailRowViewModel

internal extension InjectedFactory where T == _DarkWebMonitoringEmailRowViewModelFactory {
    
    func make(email: DataLeakEmail, actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>) -> DarkWebMonitoringEmailRowViewModel {
       return factory(
              email,
              actionPublisher
       )
    }
}

extension DarkWebMonitoringEmailRowViewModel {
        internal typealias Factory = InjectedFactory<_DarkWebMonitoringEmailRowViewModelFactory>
}


internal typealias _DarkWebMonitoringMonitoredEmailsViewModelFactory =  (
    _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
) -> DarkWebMonitoringMonitoredEmailsViewModel

internal extension InjectedFactory where T == _DarkWebMonitoringMonitoredEmailsViewModelFactory {
    
    func make(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>) -> DarkWebMonitoringMonitoredEmailsViewModel {
       return factory(
              actionPublisher
       )
    }
}

extension DarkWebMonitoringMonitoredEmailsViewModel {
        internal typealias Factory = InjectedFactory<_DarkWebMonitoringMonitoredEmailsViewModelFactory>
}


internal typealias _DarkWebMonitoringViewModelFactory =  (
    _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
) -> DarkWebMonitoringViewModel

internal extension InjectedFactory where T == _DarkWebMonitoringViewModelFactory {
    
    func make(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never> = .init()) -> DarkWebMonitoringViewModel {
       return factory(
              actionPublisher
       )
    }
}

extension DarkWebMonitoringViewModel {
        internal typealias Factory = InjectedFactory<_DarkWebMonitoringViewModelFactory>
}


internal typealias _DarkWebToolsFlowViewModelFactory = @MainActor (
) -> DarkWebToolsFlowViewModel

internal extension InjectedFactory where T == _DarkWebToolsFlowViewModelFactory {
    @MainActor
    func make() -> DarkWebToolsFlowViewModel {
       return factory(
       )
    }
}

extension DarkWebToolsFlowViewModel {
        internal typealias Factory = InjectedFactory<_DarkWebToolsFlowViewModelFactory>
}


internal typealias _DataLeakMonitoringAddEmailViewModelFactory = @MainActor (
    _ login: Login,
    _ dataLeakService: DataLeakMonitoringRegisterServiceProtocol
) -> DataLeakMonitoringAddEmailViewModel

internal extension InjectedFactory where T == _DataLeakMonitoringAddEmailViewModelFactory {
    @MainActor
    func make(login: Login, dataLeakService: DataLeakMonitoringRegisterServiceProtocol) -> DataLeakMonitoringAddEmailViewModel {
       return factory(
              login,
              dataLeakService
       )
    }
}

extension DataLeakMonitoringAddEmailViewModel {
        internal typealias Factory = InjectedFactory<_DataLeakMonitoringAddEmailViewModelFactory>
}


internal typealias _DetailViewFactory =  (
    _ itemDetailViewType: ItemDetailViewType,
    _ dismiss: DetailContainerViewSpecificAction?
) -> DetailView

internal extension InjectedFactory where T == _DetailViewFactory {
    
    func make(itemDetailViewType: ItemDetailViewType, dismiss: DetailContainerViewSpecificAction? = nil) -> DetailView {
       return factory(
              itemDetailViewType,
              dismiss
       )
    }
}

extension DetailView {
        internal typealias Factory = InjectedFactory<_DetailViewFactory>
}


internal typealias _DetailViewFactoryFactory =  (
) -> DetailViewFactory

internal extension InjectedFactory where T == _DetailViewFactoryFactory {
    
    func make() -> DetailViewFactory {
       return factory(
       )
    }
}

extension DetailViewFactory {
        internal typealias Factory = InjectedFactory<_DetailViewFactoryFactory>
}


internal typealias _DeviceListViewModelFactory =  (
) -> DeviceListViewModel

internal extension InjectedFactory where T == _DeviceListViewModelFactory {
    
    func make() -> DeviceListViewModel {
       return factory(
       )
    }
}

extension DeviceListViewModel {
        internal typealias Factory = InjectedFactory<_DeviceListViewModelFactory>
}


internal typealias _DeviceListViewModelSecondFactory =  (
    _ deviceService: DeviceServiceProtocol,
    _ currentDeviceId: String
) -> DeviceListViewModel

internal extension InjectedFactory where T == _DeviceListViewModelSecondFactory {
    
    func make(deviceService: DeviceServiceProtocol, currentDeviceId: String) -> DeviceListViewModel {
       return factory(
              deviceService,
              currentDeviceId
       )
    }
}

extension DeviceListViewModel {
        internal typealias SecondFactory = InjectedFactory<_DeviceListViewModelSecondFactory>
}


internal typealias _DomainsSectionModelFactory =  (
    _ service: DetailService<Credential>
) -> DomainsSectionModel

internal extension InjectedFactory where T == _DomainsSectionModelFactory {
    
    func make(service: DetailService<Credential>) -> DomainsSectionModel {
       return factory(
              service
       )
    }
}

extension DomainsSectionModel {
        internal typealias Factory = InjectedFactory<_DomainsSectionModelFactory>
}


internal typealias _DrivingLicenseDetailViewModelFactory =  (
    _ item: DrivingLicence,
    _ mode: DetailMode
) -> DrivingLicenseDetailViewModel

internal extension InjectedFactory where T == _DrivingLicenseDetailViewModelFactory {
    
    func make(item: DrivingLicence, mode: DetailMode = .viewing) -> DrivingLicenseDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension DrivingLicenseDetailViewModel {
        internal typealias Factory = InjectedFactory<_DrivingLicenseDetailViewModelFactory>
}


internal typealias _DrivingLicenseDetailViewModelSecondFactory =  (
    _ service: DetailService<DrivingLicence>
) -> DrivingLicenseDetailViewModel

internal extension InjectedFactory where T == _DrivingLicenseDetailViewModelSecondFactory {
    
    func make(service: DetailService<DrivingLicence>) -> DrivingLicenseDetailViewModel {
       return factory(
              service
       )
    }
}

extension DrivingLicenseDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_DrivingLicenseDetailViewModelSecondFactory>
}


internal typealias _EmailDetailViewModelFactory =  (
    _ item: CorePersonalData.Email,
    _ mode: DetailMode
) -> EmailDetailViewModel

internal extension InjectedFactory where T == _EmailDetailViewModelFactory {
    
    func make(item: CorePersonalData.Email, mode: DetailMode = .viewing) -> EmailDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension EmailDetailViewModel {
        internal typealias Factory = InjectedFactory<_EmailDetailViewModelFactory>
}


internal typealias _EmailDetailViewModelSecondFactory =  (
    _ service: DetailService<CorePersonalData.Email>
) -> EmailDetailViewModel

internal extension InjectedFactory where T == _EmailDetailViewModelSecondFactory {
    
    func make(service: DetailService<CorePersonalData.Email>) -> EmailDetailViewModel {
       return factory(
              service
       )
    }
}

extension EmailDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_EmailDetailViewModelSecondFactory>
}


internal typealias _ExportSecureArchiveViewModelFactory =  (
) -> ExportSecureArchiveViewModel

internal extension InjectedFactory where T == _ExportSecureArchiveViewModelFactory {
    
    func make() -> ExportSecureArchiveViewModel {
       return factory(
       )
    }
}

extension ExportSecureArchiveViewModel {
        internal typealias Factory = InjectedFactory<_ExportSecureArchiveViewModelFactory>
}


internal typealias _FastLocalSetupInAccountCreationViewModelFactory =  (
    _ biometry: Biometry?,
    _ completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void
) -> FastLocalSetupInAccountCreationViewModel

internal extension InjectedFactory where T == _FastLocalSetupInAccountCreationViewModelFactory {
    
    func make(biometry: Biometry? = Device.biometryType, completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void) -> FastLocalSetupInAccountCreationViewModel {
       return factory(
              biometry,
              completion
       )
    }
}

extension FastLocalSetupInAccountCreationViewModel {
        internal typealias Factory = InjectedFactory<_FastLocalSetupInAccountCreationViewModelFactory>
}


internal typealias _FastLocalSetupInLoginViewModelFactory =  (
    _ masterPassword: String?,
    _ biometry: Biometry?,
    _ completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
) -> FastLocalSetupInLoginViewModel

internal extension InjectedFactory where T == _FastLocalSetupInLoginViewModelFactory {
    
    func make(masterPassword: String?, biometry: Biometry?, completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void) -> FastLocalSetupInLoginViewModel {
       return factory(
              masterPassword,
              biometry,
              completion
       )
    }
}

extension FastLocalSetupInLoginViewModel {
        internal typealias Factory = InjectedFactory<_FastLocalSetupInLoginViewModelFactory>
}


internal typealias _FastLocalSetupInLoginViewModelSecondFactory =  (
    _ masterPassword: String?,
    _ biometry: Biometry?,
    _ lockService: LockService,
    _ masterPasswordResetService: ResetMasterPasswordService,
    _ userSettings: UserSettings,
    _ completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
) -> FastLocalSetupInLoginViewModel

internal extension InjectedFactory where T == _FastLocalSetupInLoginViewModelSecondFactory {
    
    func make(masterPassword: String?, biometry: Biometry?, lockService: LockService, masterPasswordResetService: ResetMasterPasswordService, userSettings: UserSettings, completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void) -> FastLocalSetupInLoginViewModel {
       return factory(
              masterPassword,
              biometry,
              lockService,
              masterPasswordResetService,
              userSettings,
              completion
       )
    }
}

extension FastLocalSetupInLoginViewModel {
        internal typealias SecondFactory = InjectedFactory<_FastLocalSetupInLoginViewModelSecondFactory>
}


internal typealias _FiscalInformationDetailViewModelFactory =  (
    _ item: FiscalInformation,
    _ mode: DetailMode
) -> FiscalInformationDetailViewModel

internal extension InjectedFactory where T == _FiscalInformationDetailViewModelFactory {
    
    func make(item: FiscalInformation, mode: DetailMode = .viewing) -> FiscalInformationDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension FiscalInformationDetailViewModel {
        internal typealias Factory = InjectedFactory<_FiscalInformationDetailViewModelFactory>
}


internal typealias _FiscalInformationDetailViewModelSecondFactory =  (
    _ service: DetailService<FiscalInformation>
) -> FiscalInformationDetailViewModel

internal extension InjectedFactory where T == _FiscalInformationDetailViewModelSecondFactory {
    
    func make(service: DetailService<FiscalInformation>) -> FiscalInformationDetailViewModel {
       return factory(
              service
       )
    }
}

extension FiscalInformationDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_FiscalInformationDetailViewModelSecondFactory>
}


internal typealias _GeneralSettingsViewModelFactory = @MainActor (
) -> GeneralSettingsViewModel

internal extension InjectedFactory where T == _GeneralSettingsViewModelFactory {
    @MainActor
    func make() -> GeneralSettingsViewModel {
       return factory(
       )
    }
}

extension GeneralSettingsViewModel {
        internal typealias Factory = InjectedFactory<_GeneralSettingsViewModelFactory>
}


internal typealias _GravatarIconViewModelFactory =  (
    _ email: String,
    _ iconLibrary: GravatarIconLibraryProtocol
) -> GravatarIconViewModel

internal extension InjectedFactory where T == _GravatarIconViewModelFactory {
    
    func make(email: String, iconLibrary: GravatarIconLibraryProtocol) -> GravatarIconViewModel {
       return factory(
              email,
              iconLibrary
       )
    }
}

extension GravatarIconViewModel {
        internal typealias Factory = InjectedFactory<_GravatarIconViewModelFactory>
}


internal typealias _GravatarIconViewModelSecondFactory =  (
    _ email: String
) -> GravatarIconViewModel

internal extension InjectedFactory where T == _GravatarIconViewModelSecondFactory {
    
    func make(email: String) -> GravatarIconViewModel {
       return factory(
              email
       )
    }
}

extension GravatarIconViewModel {
        internal typealias SecondFactory = InjectedFactory<_GravatarIconViewModelSecondFactory>
}


internal typealias _GuidedOnboardingViewModelFactory =  (
    _ guidedOnboardingService: GuidedOnboardingService,
    _ step: GuidedOnboardingSurveyStep,
    _ completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
) -> GuidedOnboardingViewModel

internal extension InjectedFactory where T == _GuidedOnboardingViewModelFactory {
    
    func make(guidedOnboardingService: GuidedOnboardingService, step: GuidedOnboardingSurveyStep, completion: ((GuidedOnboardingViewModelCompletion) -> Void)?) -> GuidedOnboardingViewModel {
       return factory(
              guidedOnboardingService,
              step,
              completion
       )
    }
}

extension GuidedOnboardingViewModel {
        internal typealias Factory = InjectedFactory<_GuidedOnboardingViewModelFactory>
}


internal typealias _HelpCenterSettingsViewModelFactory =  (
) -> HelpCenterSettingsViewModel

internal extension InjectedFactory where T == _HelpCenterSettingsViewModelFactory {
    
    func make() -> HelpCenterSettingsViewModel {
       return factory(
       )
    }
}

extension HelpCenterSettingsViewModel {
        internal typealias Factory = InjectedFactory<_HelpCenterSettingsViewModelFactory>
}


internal typealias _HomeFlowViewModelFactory = @MainActor (
) -> HomeFlowViewModel

internal extension InjectedFactory where T == _HomeFlowViewModelFactory {
    @MainActor
    func make() -> HomeFlowViewModel {
       return factory(
       )
    }
}

extension HomeFlowViewModel {
        internal typealias Factory = InjectedFactory<_HomeFlowViewModelFactory>
}


internal typealias _HomeViewModelFactory =  (
    _ onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    _ action: @escaping (VaultFlowViewModel.Action) -> Void
) -> HomeViewModel

internal extension InjectedFactory where T == _HomeViewModelFactory {
    
    func make(onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void, action: @escaping (VaultFlowViewModel.Action) -> Void) -> HomeViewModel {
       return factory(
              onboardingAction,
              action
       )
    }
}

extension HomeViewModel {
        internal typealias Factory = InjectedFactory<_HomeViewModelFactory>
}


internal typealias _IDCardDetailViewModelFactory =  (
    _ item: IDCard,
    _ mode: DetailMode
) -> IDCardDetailViewModel

internal extension InjectedFactory where T == _IDCardDetailViewModelFactory {
    
    func make(item: IDCard, mode: DetailMode = .viewing) -> IDCardDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension IDCardDetailViewModel {
        internal typealias Factory = InjectedFactory<_IDCardDetailViewModelFactory>
}


internal typealias _IDCardDetailViewModelSecondFactory =  (
    _ service: DetailService<IDCard>
) -> IDCardDetailViewModel

internal extension InjectedFactory where T == _IDCardDetailViewModelSecondFactory {
    
    func make(service: DetailService<IDCard>) -> IDCardDetailViewModel {
       return factory(
              service
       )
    }
}

extension IDCardDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_IDCardDetailViewModelSecondFactory>
}


internal typealias _IdentityBreachAlertViewModelFactory =  (
    _ breachesToPresent: [PopupAlertProtocol]
) -> IdentityBreachAlertViewModel

internal extension InjectedFactory where T == _IdentityBreachAlertViewModelFactory {
    
    func make(breachesToPresent: [PopupAlertProtocol]) -> IdentityBreachAlertViewModel {
       return factory(
              breachesToPresent
       )
    }
}

extension IdentityBreachAlertViewModel {
        internal typealias Factory = InjectedFactory<_IdentityBreachAlertViewModelFactory>
}


internal typealias _IdentityDetailViewModelFactory =  (
    _ item: Identity,
    _ mode: DetailMode
) -> IdentityDetailViewModel

internal extension InjectedFactory where T == _IdentityDetailViewModelFactory {
    
    func make(item: Identity, mode: DetailMode = .viewing) -> IdentityDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension IdentityDetailViewModel {
        internal typealias Factory = InjectedFactory<_IdentityDetailViewModelFactory>
}


internal typealias _IdentityDetailViewModelSecondFactory =  (
    _ service: DetailService<Identity>
) -> IdentityDetailViewModel

internal extension InjectedFactory where T == _IdentityDetailViewModelSecondFactory {
    
    func make(service: DetailService<Identity>) -> IdentityDetailViewModel {
       return factory(
              service
       )
    }
}

extension IdentityDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_IdentityDetailViewModelSecondFactory>
}


internal typealias _ImportMethodFlowViewModelFactory = @MainActor (
    _ mode: ImportMethodMode,
    _ completion: @escaping (ImportMethodFlowViewModel.Completion) -> Void
) -> ImportMethodFlowViewModel

internal extension InjectedFactory where T == _ImportMethodFlowViewModelFactory {
    @MainActor
    func make(mode: ImportMethodMode, completion: @escaping (ImportMethodFlowViewModel.Completion) -> Void) -> ImportMethodFlowViewModel {
       return factory(
              mode,
              completion
       )
    }
}

extension ImportMethodFlowViewModel {
        internal typealias Factory = InjectedFactory<_ImportMethodFlowViewModelFactory>
}


internal typealias _ImportMethodViewModelFactory =  (
    _ importService: ImportMethodServiceProtocol,
    _ completion: @escaping (ImportMethodCompletion) -> Void
) -> ImportMethodViewModel

internal extension InjectedFactory where T == _ImportMethodViewModelFactory {
    
    func make(importService: ImportMethodServiceProtocol, completion: @escaping (ImportMethodCompletion) -> Void) -> ImportMethodViewModel {
       return factory(
              importService,
              completion
       )
    }
}

extension ImportMethodViewModel {
        internal typealias Factory = InjectedFactory<_ImportMethodViewModelFactory>
}


internal typealias _LabsSettingsViewModelFactory =  (
    _ labsService: LabsService
) -> LabsSettingsViewModel

internal extension InjectedFactory where T == _LabsSettingsViewModelFactory {
    
    func make(labsService: LabsService) -> LabsSettingsViewModel {
       return factory(
              labsService
       )
    }
}

extension LabsSettingsViewModel {
        internal typealias Factory = InjectedFactory<_LabsSettingsViewModelFactory>
}


internal typealias _LockViewModelFactory = @MainActor (
    _ locker: ScreenLocker,
    _ newMasterPassword: String?,
    _ changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher
) -> LockViewModel

internal extension InjectedFactory where T == _LockViewModelFactory {
    @MainActor
    func make(locker: ScreenLocker, newMasterPassword: String? = nil, changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher) -> LockViewModel {
       return factory(
              locker,
              newMasterPassword,
              changeMasterPasswordLauncher
       )
    }
}

extension LockViewModel {
        internal typealias Factory = InjectedFactory<_LockViewModelFactory>
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


internal typealias _M2WSettingsFactory =  (
) -> M2WSettings

internal extension InjectedFactory where T == _M2WSettingsFactory {
    
    func make() -> M2WSettings {
       return factory(
       )
    }
}

extension M2WSettings {
        internal typealias Factory = InjectedFactory<_M2WSettingsFactory>
}


internal typealias _MainSettingsViewModelFactory = @MainActor (
    _ labsService: LabsService
) -> MainSettingsViewModel

internal extension InjectedFactory where T == _MainSettingsViewModelFactory {
    @MainActor
    func make(labsService: LabsService) -> MainSettingsViewModel {
       return factory(
              labsService
       )
    }
}

extension MainSettingsViewModel {
        internal typealias Factory = InjectedFactory<_MainSettingsViewModelFactory>
}


internal typealias _MasterPasswordAccountCreationFlowViewModelFactory = @MainActor (
    _ configuration: AccountCreationConfiguration,
    _ completion: @MainActor @escaping (MasterPasswordAccountCreationFlowViewModel.CompletionResult) -> Void
) -> MasterPasswordAccountCreationFlowViewModel

internal extension InjectedFactory where T == _MasterPasswordAccountCreationFlowViewModelFactory {
    @MainActor
    func make(configuration: AccountCreationConfiguration, completion: @MainActor @escaping (MasterPasswordAccountCreationFlowViewModel.CompletionResult) -> Void) -> MasterPasswordAccountCreationFlowViewModel {
       return factory(
              configuration,
              completion
       )
    }
}

extension MasterPasswordAccountCreationFlowViewModel {
        internal typealias Factory = InjectedFactory<_MasterPasswordAccountCreationFlowViewModelFactory>
}


internal typealias _MasterPasswordResetActivationViewModelFactory = @MainActor (
    _ masterPassword: String,
    _ actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
) -> MasterPasswordResetActivationViewModel

internal extension InjectedFactory where T == _MasterPasswordResetActivationViewModelFactory {
    @MainActor
    func make(masterPassword: String, actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> MasterPasswordResetActivationViewModel {
       return factory(
              masterPassword,
              actionHandler
       )
    }
}

extension MasterPasswordResetActivationViewModel {
        internal typealias Factory = InjectedFactory<_MasterPasswordResetActivationViewModelFactory>
}


internal typealias _MatchingCredentialListViewModelFactory =  (
    _ website: String,
    _ matchingCredentials: [Credential],
    _ completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void
) -> MatchingCredentialListViewModel

internal extension InjectedFactory where T == _MatchingCredentialListViewModelFactory {
    
    func make(website: String, matchingCredentials: [Credential], completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void) -> MatchingCredentialListViewModel {
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


internal typealias _MigrationProgressViewModelFactory =  (
    _ type: MigrationType,
    _ accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    _ context: MigrationProgressViewModel.Context,
    _ isProgress: Bool,
    _ isSuccess: Bool,
    _ completion: @escaping (Result<Session, Error>) -> Void
) -> MigrationProgressViewModel

internal extension InjectedFactory where T == _MigrationProgressViewModelFactory {
    
    func make(type: MigrationType, accountCryptoChangerService: AccountCryptoChangerServiceProtocol, context: MigrationProgressViewModel.Context, isProgress: Bool = true, isSuccess: Bool = true, completion: @escaping (Result<Session, Error>) -> Void) -> MigrationProgressViewModel {
       return factory(
              type,
              accountCryptoChangerService,
              context,
              isProgress,
              isSuccess,
              completion
       )
    }
}

extension MigrationProgressViewModel {
        internal typealias Factory = InjectedFactory<_MigrationProgressViewModelFactory>
}


internal typealias _MiniBrowserViewModelFactory =  (
    _ email: String,
    _ password: String,
    _ displayableDomain: String,
    _ url: URL,
    _ completion: @escaping (MiniBrowserViewModel.Completion) -> Void
) -> MiniBrowserViewModel

internal extension InjectedFactory where T == _MiniBrowserViewModelFactory {
    
    func make(email: String, password: String, displayableDomain: String, url: URL, completion: @escaping (MiniBrowserViewModel.Completion) -> Void) -> MiniBrowserViewModel {
       return factory(
              email,
              password,
              displayableDomain,
              url,
              completion
       )
    }
}

extension MiniBrowserViewModel {
        internal typealias Factory = InjectedFactory<_MiniBrowserViewModelFactory>
}


internal typealias _NotesSectionModelFactory =  (
    _ service: DetailService<Credential>
) -> NotesSectionModel

internal extension InjectedFactory where T == _NotesSectionModelFactory {
    
    func make(service: DetailService<Credential>) -> NotesSectionModel {
       return factory(
              service
       )
    }
}

extension NotesSectionModel {
        internal typealias Factory = InjectedFactory<_NotesSectionModelFactory>
}


internal typealias _NotificationCenterServiceFactory =  (
) -> NotificationCenterService

internal extension InjectedFactory where T == _NotificationCenterServiceFactory {
    
    func make() -> NotificationCenterService {
       return factory(
       )
    }
}

extension NotificationCenterService {
        internal typealias Factory = InjectedFactory<_NotificationCenterServiceFactory>
}


internal typealias _NotificationsFlowViewModelFactory = @MainActor (
    _ notificationCenterService: NotificationCenterServiceProtocol
) -> NotificationsFlowViewModel

internal extension InjectedFactory where T == _NotificationsFlowViewModelFactory {
    @MainActor
    func make(notificationCenterService: NotificationCenterServiceProtocol) -> NotificationsFlowViewModel {
       return factory(
              notificationCenterService
       )
    }
}

extension NotificationsFlowViewModel {
        internal typealias Factory = InjectedFactory<_NotificationsFlowViewModelFactory>
}


internal typealias _NotificationsListViewModelFactory =  (
    _ notificationCenterService: NotificationCenterServiceProtocol
) -> NotificationsListViewModel

internal extension InjectedFactory where T == _NotificationsListViewModelFactory {
    
    func make(notificationCenterService: NotificationCenterServiceProtocol) -> NotificationsListViewModel {
       return factory(
              notificationCenterService
       )
    }
}

extension NotificationsListViewModel {
        internal typealias Factory = InjectedFactory<_NotificationsListViewModelFactory>
}


internal typealias _OTPExplorerViewModelFactory =  (
    _ otpSupportedDomainsRepository: OTPSupportedDomainsRepository,
    _ actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void
) -> OTPExplorerViewModel

internal extension InjectedFactory where T == _OTPExplorerViewModelFactory {
    
    func make(otpSupportedDomainsRepository: OTPSupportedDomainsRepository, actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void) -> OTPExplorerViewModel {
       return factory(
              otpSupportedDomainsRepository,
              actionHandler
       )
    }
}

extension OTPExplorerViewModel {
        internal typealias Factory = InjectedFactory<_OTPExplorerViewModelFactory>
}


internal typealias _OTPTokenListViewModelFactory =  (
    _ actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void
) -> OTPTokenListViewModel

internal extension InjectedFactory where T == _OTPTokenListViewModelFactory {
    
    func make(actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void) -> OTPTokenListViewModel {
       return factory(
              actionHandler
       )
    }
}

extension OTPTokenListViewModel {
        internal typealias Factory = InjectedFactory<_OTPTokenListViewModelFactory>
}


internal typealias _OnboardingChecklistFlowViewModelFactory = @MainActor (
    _ displayMode: OnboardingChecklistFlowViewModel.DisplayMode,
    _ onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)?,
    _ completion: @escaping (OnboardingChecklistFlowViewModel.Completion) -> Void
) -> OnboardingChecklistFlowViewModel

internal extension InjectedFactory where T == _OnboardingChecklistFlowViewModelFactory {
    @MainActor
    func make(displayMode: OnboardingChecklistFlowViewModel.DisplayMode, onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil, completion: @escaping (OnboardingChecklistFlowViewModel.Completion) -> Void) -> OnboardingChecklistFlowViewModel {
       return factory(
              displayMode,
              onboardingChecklistViewAction,
              completion
       )
    }
}

extension OnboardingChecklistFlowViewModel {
        internal typealias Factory = InjectedFactory<_OnboardingChecklistFlowViewModelFactory>
}


internal typealias _OnboardingChecklistViewModelFactory =  (
    _ action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
) -> OnboardingChecklistViewModel

internal extension InjectedFactory where T == _OnboardingChecklistViewModelFactory {
    
    func make(action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void) -> OnboardingChecklistViewModel {
       return factory(
              action
       )
    }
}

extension OnboardingChecklistViewModel {
        internal typealias Factory = InjectedFactory<_OnboardingChecklistViewModelFactory>
}


internal typealias _PasskeyDetailViewModelFactory =  (
    _ item: CorePersonalData.Passkey,
    _ mode: DetailMode,
    _ dismiss: (() -> Void)?
) -> PasskeyDetailViewModel

internal extension InjectedFactory where T == _PasskeyDetailViewModelFactory {
    
    func make(item: CorePersonalData.Passkey, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil) -> PasskeyDetailViewModel {
       return factory(
              item,
              mode,
              dismiss
       )
    }
}

extension PasskeyDetailViewModel {
        internal typealias Factory = InjectedFactory<_PasskeyDetailViewModelFactory>
}


internal typealias _PasskeyDetailViewModelSecondFactory =  (
    _ service: DetailService<CorePersonalData.Passkey>
) -> PasskeyDetailViewModel

internal extension InjectedFactory where T == _PasskeyDetailViewModelSecondFactory {
    
    func make(service: DetailService<CorePersonalData.Passkey>) -> PasskeyDetailViewModel {
       return factory(
              service
       )
    }
}

extension PasskeyDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_PasskeyDetailViewModelSecondFactory>
}


internal typealias _PassportDetailViewModelFactory =  (
    _ item: Passport,
    _ mode: DetailMode
) -> PassportDetailViewModel

internal extension InjectedFactory where T == _PassportDetailViewModelFactory {
    
    func make(item: Passport, mode: DetailMode = .viewing) -> PassportDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension PassportDetailViewModel {
        internal typealias Factory = InjectedFactory<_PassportDetailViewModelFactory>
}


internal typealias _PassportDetailViewModelSecondFactory =  (
    _ service: DetailService<Passport>
) -> PassportDetailViewModel

internal extension InjectedFactory where T == _PassportDetailViewModelSecondFactory {
    
    func make(service: DetailService<Passport>) -> PassportDetailViewModel {
       return factory(
              service
       )
    }
}

extension PassportDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_PassportDetailViewModelSecondFactory>
}


internal typealias _PasswordAccessorySectionModelFactory =  (
    _ service: DetailService<Credential>
) -> PasswordAccessorySectionModel

internal extension InjectedFactory where T == _PasswordAccessorySectionModelFactory {
    
    func make(service: DetailService<Credential>) -> PasswordAccessorySectionModel {
       return factory(
              service
       )
    }
}

extension PasswordAccessorySectionModel {
        internal typealias Factory = InjectedFactory<_PasswordAccessorySectionModelFactory>
}


internal typealias _PasswordGeneratorHistoryViewModelFactory =  (
) -> PasswordGeneratorHistoryViewModel

internal extension InjectedFactory where T == _PasswordGeneratorHistoryViewModelFactory {
    
    func make() -> PasswordGeneratorHistoryViewModel {
       return factory(
       )
    }
}

extension PasswordGeneratorHistoryViewModel {
        internal typealias Factory = InjectedFactory<_PasswordGeneratorHistoryViewModelFactory>
}


internal typealias _PasswordGeneratorToolsFlowViewModelFactory = @MainActor (
    _ pasteboardService: PasteboardService
) -> PasswordGeneratorToolsFlowViewModel

internal extension InjectedFactory where T == _PasswordGeneratorToolsFlowViewModelFactory {
    @MainActor
    func make(pasteboardService: PasteboardService) -> PasswordGeneratorToolsFlowViewModel {
       return factory(
              pasteboardService
       )
    }
}

extension PasswordGeneratorToolsFlowViewModel {
        internal typealias Factory = InjectedFactory<_PasswordGeneratorToolsFlowViewModelFactory>
}


public typealias _PasswordGeneratorViewModelFactory =  (
    _ mode: PasswordGeneratorMode,
    _ saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
    _ savePreferencesOnChange: Bool,
    _ copyAction: @escaping (String) -> Void
) -> PasswordGeneratorViewModel

public extension InjectedFactory where T == _PasswordGeneratorViewModelFactory {
    
    func make(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
       return factory(
              mode,
              saveGeneratedPassword,
              savePreferencesOnChange,
              copyAction
       )
    }
}

extension PasswordGeneratorViewModel {
        public typealias Factory = InjectedFactory<_PasswordGeneratorViewModelFactory>
}


public typealias _PasswordGeneratorViewModelSecondFactory =  (
    _ mode: PasswordGeneratorMode,
    _ savePreferencesOnChange: Bool,
    _ copyAction: @escaping (String) -> Void
) -> PasswordGeneratorViewModel

public extension InjectedFactory where T == _PasswordGeneratorViewModelSecondFactory {
    
    func make(mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
       return factory(
              mode,
              savePreferencesOnChange,
              copyAction
       )
    }
}

extension PasswordGeneratorViewModel {
        public typealias SecondFactory = InjectedFactory<_PasswordGeneratorViewModelSecondFactory>
}


public typealias _PasswordGeneratorViewModelThirdFactory =  (
    _ mode: PasswordGeneratorMode,
    _ copyAction: @escaping (String) -> Void
) -> PasswordGeneratorViewModel

public extension InjectedFactory where T == _PasswordGeneratorViewModelThirdFactory {
    
    func make(mode: PasswordGeneratorMode, copyAction: @escaping (String) -> Void) -> PasswordGeneratorViewModel {
       return factory(
              mode,
              copyAction
       )
    }
}

extension PasswordGeneratorViewModel {
        public typealias ThirdFactory = InjectedFactory<_PasswordGeneratorViewModelThirdFactory>
}


internal typealias _PasswordHealthDetailedListViewModelFactory =  (
    _ kind: PasswordHealthKind,
    _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthDetailedListViewModel

internal extension InjectedFactory where T == _PasswordHealthDetailedListViewModelFactory {
    
    func make(kind: PasswordHealthKind, origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthDetailedListViewModel {
       return factory(
              kind,
              origin
       )
    }
}

extension PasswordHealthDetailedListViewModel {
        internal typealias Factory = InjectedFactory<_PasswordHealthDetailedListViewModelFactory>
}


internal typealias _PasswordHealthFlowViewModelFactory =  (
    _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthFlowViewModel

internal extension InjectedFactory where T == _PasswordHealthFlowViewModelFactory {
    
    func make(origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthFlowViewModel {
       return factory(
              origin
       )
    }
}

extension PasswordHealthFlowViewModel {
        internal typealias Factory = InjectedFactory<_PasswordHealthFlowViewModelFactory>
}


internal typealias _PasswordHealthListViewModelFactory =  (
    _ kind: PasswordHealthKind,
    _ maximumCredentialsCount: Int?,
    _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthListViewModel

internal extension InjectedFactory where T == _PasswordHealthListViewModelFactory {
    
    func make(kind: PasswordHealthKind, maximumCredentialsCount: Int? = nil, origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthListViewModel {
       return factory(
              kind,
              maximumCredentialsCount,
              origin
       )
    }
}

extension PasswordHealthListViewModel {
        internal typealias Factory = InjectedFactory<_PasswordHealthListViewModelFactory>
}


internal typealias _PasswordHealthSectionModelFactory =  (
    _ service: DetailService<Credential>
) -> PasswordHealthSectionModel

internal extension InjectedFactory where T == _PasswordHealthSectionModelFactory {
    
    func make(service: DetailService<Credential>) -> PasswordHealthSectionModel {
       return factory(
              service
       )
    }
}

extension PasswordHealthSectionModel {
        internal typealias Factory = InjectedFactory<_PasswordHealthSectionModelFactory>
}


internal typealias _PasswordHealthViewModelFactory =  (
    _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthViewModel

internal extension InjectedFactory where T == _PasswordHealthViewModelFactory {
    
    func make(origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthViewModel {
       return factory(
              origin
       )
    }
}

extension PasswordHealthViewModel {
        internal typealias Factory = InjectedFactory<_PasswordHealthViewModelFactory>
}


internal typealias _PasswordLessAccountCreationFlowViewModelFactory = @MainActor (
    _ configuration: AccountCreationConfiguration,
    _ completion: @MainActor @escaping (PasswordLessAccountCreationFlowViewModel.CompletionResult) -> Void
) -> PasswordLessAccountCreationFlowViewModel

internal extension InjectedFactory where T == _PasswordLessAccountCreationFlowViewModelFactory {
    @MainActor
    func make(configuration: AccountCreationConfiguration, completion: @MainActor @escaping (PasswordLessAccountCreationFlowViewModel.CompletionResult) -> Void) -> PasswordLessAccountCreationFlowViewModel {
       return factory(
              configuration,
              completion
       )
    }
}

extension PasswordLessAccountCreationFlowViewModel {
        internal typealias Factory = InjectedFactory<_PasswordLessAccountCreationFlowViewModelFactory>
}


internal typealias _PasswordLessCompletionViewModelFactory = @MainActor (
    _ completion: @escaping () -> Void
) -> PasswordLessCompletionViewModel

internal extension InjectedFactory where T == _PasswordLessCompletionViewModelFactory {
    @MainActor
    func make(completion: @escaping () -> Void) -> PasswordLessCompletionViewModel {
       return factory(
              completion
       )
    }
}

extension PasswordLessCompletionViewModel {
        internal typealias Factory = InjectedFactory<_PasswordLessCompletionViewModelFactory>
}


internal typealias _PhoneDetailViewModelFactory =  (
    _ item: Phone,
    _ mode: DetailMode
) -> PhoneDetailViewModel

internal extension InjectedFactory where T == _PhoneDetailViewModelFactory {
    
    func make(item: Phone, mode: DetailMode = .viewing) -> PhoneDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension PhoneDetailViewModel {
        internal typealias Factory = InjectedFactory<_PhoneDetailViewModelFactory>
}


internal typealias _PhoneDetailViewModelSecondFactory =  (
    _ service: DetailService<Phone>
) -> PhoneDetailViewModel

internal extension InjectedFactory where T == _PhoneDetailViewModelSecondFactory {
    
    func make(service: DetailService<Phone>) -> PhoneDetailViewModel {
       return factory(
              service
       )
    }
}

extension PhoneDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_PhoneDetailViewModelSecondFactory>
}


internal typealias _PinCodeSettingsViewModelFactory =  (
    _ actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void
) -> PinCodeSettingsViewModel

internal extension InjectedFactory where T == _PinCodeSettingsViewModelFactory {
    
    func make(actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void) -> PinCodeSettingsViewModel {
       return factory(
              actionHandler
       )
    }
}

extension PinCodeSettingsViewModel {
        internal typealias Factory = InjectedFactory<_PinCodeSettingsViewModelFactory>
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


internal typealias _PostARKChangeMasterPasswordViewModelFactory =  (
    _ accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    _ completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void
) -> PostARKChangeMasterPasswordViewModel

internal extension InjectedFactory where T == _PostARKChangeMasterPasswordViewModelFactory {
    
    func make(accountCryptoChangerService: AccountCryptoChangerServiceProtocol, completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void) -> PostARKChangeMasterPasswordViewModel {
       return factory(
              accountCryptoChangerService,
              completion
       )
    }
}

extension PostARKChangeMasterPasswordViewModel {
        internal typealias Factory = InjectedFactory<_PostARKChangeMasterPasswordViewModelFactory>
}


internal typealias _PostAccountRecoveryLoginFlowModelFactory =  (
    _ authenticationMethod: AuthenticationMethod
) -> PostAccountRecoveryLoginFlowModel

internal extension InjectedFactory where T == _PostAccountRecoveryLoginFlowModelFactory {
    
    func make(authenticationMethod: AuthenticationMethod) -> PostAccountRecoveryLoginFlowModel {
       return factory(
              authenticationMethod
       )
    }
}

extension PostAccountRecoveryLoginFlowModel {
        internal typealias Factory = InjectedFactory<_PostAccountRecoveryLoginFlowModelFactory>
}


public typealias _PremiumAnnouncementsViewModelFactory =  (
    _ excludedAnnouncements: Set<PremiumAnnouncement>
) -> PremiumAnnouncementsViewModel

public extension InjectedFactory where T == _PremiumAnnouncementsViewModelFactory {
    
    func make(excludedAnnouncements: Set<PremiumAnnouncement> = []) -> PremiumAnnouncementsViewModel {
       return factory(
              excludedAnnouncements
       )
    }
}

extension PremiumAnnouncementsViewModel {
        public typealias Factory = InjectedFactory<_PremiumAnnouncementsViewModelFactory>
}


internal typealias _QuickActionsMenuViewModelFactory =  (
    _ item: VaultItem,
    _ origin: VaultItemRowModel.Origin,
    _ isSuggestedItem: Bool
) -> QuickActionsMenuViewModel

internal extension InjectedFactory where T == _QuickActionsMenuViewModelFactory {
    
    func make(item: VaultItem, origin: VaultItemRowModel.Origin, isSuggestedItem: Bool) -> QuickActionsMenuViewModel {
       return factory(
              item,
              origin,
              isSuggestedItem
       )
    }
}

extension QuickActionsMenuViewModel {
        internal typealias Factory = InjectedFactory<_QuickActionsMenuViewModelFactory>
}


internal typealias _RememberMasterPasswordToggleViewModelFactory =  (
    _ actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void
) -> RememberMasterPasswordToggleViewModel

internal extension InjectedFactory where T == _RememberMasterPasswordToggleViewModelFactory {
    
    func make(actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void) -> RememberMasterPasswordToggleViewModel {
       return factory(
              actionHandler
       )
    }
}

extension RememberMasterPasswordToggleViewModel {
        internal typealias Factory = InjectedFactory<_RememberMasterPasswordToggleViewModelFactory>
}


internal typealias _ResetMasterPasswordNotificationRowViewModelFactory = @MainActor (
    _ notification: DashlaneNotification
) -> ResetMasterPasswordNotificationRowViewModel

internal extension InjectedFactory where T == _ResetMasterPasswordNotificationRowViewModelFactory {
    @MainActor
    func make(notification: DashlaneNotification) -> ResetMasterPasswordNotificationRowViewModel {
       return factory(
              notification
       )
    }
}

extension ResetMasterPasswordNotificationRowViewModel {
        internal typealias Factory = InjectedFactory<_ResetMasterPasswordNotificationRowViewModelFactory>
}


internal typealias _SSOEnableBiometricsOrPinViewModelFactory =  (
) -> SSOEnableBiometricsOrPinViewModel

internal extension InjectedFactory where T == _SSOEnableBiometricsOrPinViewModelFactory {
    
    func make() -> SSOEnableBiometricsOrPinViewModel {
       return factory(
       )
    }
}

extension SSOEnableBiometricsOrPinViewModel {
        internal typealias Factory = InjectedFactory<_SSOEnableBiometricsOrPinViewModelFactory>
}


internal typealias _SecureLockNotificationRowViewModelFactory =  (
    _ notification: DashlaneNotification
) -> SecureLockNotificationRowViewModel

internal extension InjectedFactory where T == _SecureLockNotificationRowViewModelFactory {
    
    func make(notification: DashlaneNotification) -> SecureLockNotificationRowViewModel {
       return factory(
              notification
       )
    }
}

extension SecureLockNotificationRowViewModel {
        internal typealias Factory = InjectedFactory<_SecureLockNotificationRowViewModelFactory>
}


internal typealias _SecureNotesDetailFieldsModelFactory =  (
    _ service: DetailService<SecureNote>
) -> SecureNotesDetailFieldsModel

internal extension InjectedFactory where T == _SecureNotesDetailFieldsModelFactory {
    
    func make(service: DetailService<SecureNote>) -> SecureNotesDetailFieldsModel {
       return factory(
              service
       )
    }
}

extension SecureNotesDetailFieldsModel {
        internal typealias Factory = InjectedFactory<_SecureNotesDetailFieldsModelFactory>
}


internal typealias _SecureNotesDetailNavigationBarModelFactory =  (
    _ service: DetailService<SecureNote>,
    _ isEditingContent: FocusState<Bool>.Binding
) -> SecureNotesDetailNavigationBarModel

internal extension InjectedFactory where T == _SecureNotesDetailNavigationBarModelFactory {
    
    func make(service: DetailService<SecureNote>, isEditingContent: FocusState<Bool>.Binding) -> SecureNotesDetailNavigationBarModel {
       return factory(
              service,
              isEditingContent
       )
    }
}

extension SecureNotesDetailNavigationBarModel {
        internal typealias Factory = InjectedFactory<_SecureNotesDetailNavigationBarModelFactory>
}


internal typealias _SecureNotesDetailToolbarModelFactory =  (
    _ service: DetailService<SecureNote>
) -> SecureNotesDetailToolbarModel

internal extension InjectedFactory where T == _SecureNotesDetailToolbarModelFactory {
    
    func make(service: DetailService<SecureNote>) -> SecureNotesDetailToolbarModel {
       return factory(
              service
       )
    }
}

extension SecureNotesDetailToolbarModel {
        internal typealias Factory = InjectedFactory<_SecureNotesDetailToolbarModelFactory>
}


internal typealias _SecureNotesDetailViewModelFactory =  (
    _ item: SecureNote,
    _ mode: DetailMode
) -> SecureNotesDetailViewModel

internal extension InjectedFactory where T == _SecureNotesDetailViewModelFactory {
    
    func make(item: SecureNote, mode: DetailMode = .viewing) -> SecureNotesDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension SecureNotesDetailViewModel {
        internal typealias Factory = InjectedFactory<_SecureNotesDetailViewModelFactory>
}


internal typealias _SecureNotesDetailViewModelSecondFactory =  (
    _ service: DetailService<SecureNote>
) -> SecureNotesDetailViewModel

internal extension InjectedFactory where T == _SecureNotesDetailViewModelSecondFactory {
    
    func make(service: DetailService<SecureNote>) -> SecureNotesDetailViewModel {
       return factory(
              service
       )
    }
}

extension SecureNotesDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_SecureNotesDetailViewModelSecondFactory>
}


internal typealias _SecurityAlertNotificationRowViewModelFactory =  (
    _ notification: DashlaneNotification
) -> SecurityAlertNotificationRowViewModel

internal extension InjectedFactory where T == _SecurityAlertNotificationRowViewModelFactory {
    
    func make(notification: DashlaneNotification) -> SecurityAlertNotificationRowViewModel {
       return factory(
              notification
       )
    }
}

extension SecurityAlertNotificationRowViewModel {
        internal typealias Factory = InjectedFactory<_SecurityAlertNotificationRowViewModelFactory>
}


internal typealias _SecuritySettingsViewModelFactory = @MainActor (
) -> SecuritySettingsViewModel

internal extension InjectedFactory where T == _SecuritySettingsViewModelFactory {
    @MainActor
    func make() -> SecuritySettingsViewModel {
       return factory(
       )
    }
}

extension SecuritySettingsViewModel {
        internal typealias Factory = InjectedFactory<_SecuritySettingsViewModelFactory>
}


internal typealias _SettingsAccountSectionViewModelFactory = @MainActor (
    _ actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
) -> SettingsAccountSectionViewModel

internal extension InjectedFactory where T == _SettingsAccountSectionViewModelFactory {
    @MainActor
    func make(actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> SettingsAccountSectionViewModel {
       return factory(
              actionHandler
       )
    }
}

extension SettingsAccountSectionViewModel {
        internal typealias Factory = InjectedFactory<_SettingsAccountSectionViewModelFactory>
}


internal typealias _SettingsBiometricToggleViewModelFactory =  (
    _ actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void
) -> SettingsBiometricToggleViewModel

internal extension InjectedFactory where T == _SettingsBiometricToggleViewModelFactory {
    
    func make(actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void) -> SettingsBiometricToggleViewModel {
       return factory(
              actionHandler
       )
    }
}

extension SettingsBiometricToggleViewModel {
        internal typealias Factory = InjectedFactory<_SettingsBiometricToggleViewModelFactory>
}


internal typealias _SettingsFlowViewModelFactory = @MainActor (
) -> SettingsFlowViewModel

internal extension InjectedFactory where T == _SettingsFlowViewModelFactory {
    @MainActor
    func make() -> SettingsFlowViewModel {
       return factory(
       )
    }
}

extension SettingsFlowViewModel {
        internal typealias Factory = InjectedFactory<_SettingsFlowViewModelFactory>
}


internal typealias _SettingsLockSectionViewModelFactory =  (
) -> SettingsLockSectionViewModel

internal extension InjectedFactory where T == _SettingsLockSectionViewModelFactory {
    
    func make() -> SettingsLockSectionViewModel {
       return factory(
       )
    }
}

extension SettingsLockSectionViewModel {
        internal typealias Factory = InjectedFactory<_SettingsLockSectionViewModelFactory>
}


internal typealias _SettingsStatusSectionViewModelFactory = @MainActor (
) -> SettingsStatusSectionViewModel

internal extension InjectedFactory where T == _SettingsStatusSectionViewModelFactory {
    @MainActor
    func make() -> SettingsStatusSectionViewModel {
       return factory(
       )
    }
}

extension SettingsStatusSectionViewModel {
        internal typealias Factory = InjectedFactory<_SettingsStatusSectionViewModelFactory>
}


internal typealias _ShareButtonViewModelFactory = @MainActor (
    _ items: [VaultItem],
    _ userGroupIds: Set<Identifier>,
    _ userEmails: Set<String>
) -> ShareButtonViewModel

internal extension InjectedFactory where T == _ShareButtonViewModelFactory {
    @MainActor
    func make(items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []) -> ShareButtonViewModel {
       return factory(
              items,
              userGroupIds,
              userEmails
       )
    }
}

extension ShareButtonViewModel {
        internal typealias Factory = InjectedFactory<_ShareButtonViewModelFactory>
}


internal typealias _ShareFlowViewModelFactory = @MainActor (
    _ items: [VaultItem],
    _ userGroupIds: Set<Identifier>,
    _ userEmails: Set<String>
) -> ShareFlowViewModel

internal extension InjectedFactory where T == _ShareFlowViewModelFactory {
    @MainActor
    func make(items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []) -> ShareFlowViewModel {
       return factory(
              items,
              userGroupIds,
              userEmails
       )
    }
}

extension ShareFlowViewModel {
        internal typealias Factory = InjectedFactory<_ShareFlowViewModelFactory>
}


internal typealias _ShareItemsSelectionViewModelFactory = @MainActor (
    _ completion: @MainActor @escaping ([VaultItem]) -> Void
) -> ShareItemsSelectionViewModel

internal extension InjectedFactory where T == _ShareItemsSelectionViewModelFactory {
    @MainActor
    func make(completion: @MainActor @escaping ([VaultItem]) -> Void) -> ShareItemsSelectionViewModel {
       return factory(
              completion
       )
    }
}

extension ShareItemsSelectionViewModel {
        internal typealias Factory = InjectedFactory<_ShareItemsSelectionViewModelFactory>
}


internal typealias _ShareRecipientsSelectionViewModelFactory = @MainActor (
    _ configuration: RecipientsConfiguration,
    _ completion: @MainActor @escaping (RecipientsConfiguration) -> Void
) -> ShareRecipientsSelectionViewModel

internal extension InjectedFactory where T == _ShareRecipientsSelectionViewModelFactory {
    @MainActor
    func make(configuration: RecipientsConfiguration = .init(), completion: @MainActor @escaping (RecipientsConfiguration) -> Void) -> ShareRecipientsSelectionViewModel {
       return factory(
              configuration,
              completion
       )
    }
}

extension ShareRecipientsSelectionViewModel {
        internal typealias Factory = InjectedFactory<_ShareRecipientsSelectionViewModelFactory>
}


internal typealias _SharingDetailSectionModelFactory = @MainActor (
    _ item: VaultItem
) -> SharingDetailSectionModel

internal extension InjectedFactory where T == _SharingDetailSectionModelFactory {
    @MainActor
    func make(item: VaultItem) -> SharingDetailSectionModel {
       return factory(
              item
       )
    }
}

extension SharingDetailSectionModel {
        internal typealias Factory = InjectedFactory<_SharingDetailSectionModelFactory>
}


internal typealias _SharingItemsUserDetailViewModelFactory = @MainActor (
    _ user: SharingItemsUser,
    _ userUpdatePublisher: AnyPublisher<SharingItemsUser, Never>,
    _ itemsProvider: SharingToolItemsProvider
) -> SharingItemsUserDetailViewModel

internal extension InjectedFactory where T == _SharingItemsUserDetailViewModelFactory {
    @MainActor
    func make(user: SharingItemsUser, userUpdatePublisher: AnyPublisher<SharingItemsUser, Never>, itemsProvider: SharingToolItemsProvider) -> SharingItemsUserDetailViewModel {
       return factory(
              user,
              userUpdatePublisher,
              itemsProvider
       )
    }
}

extension SharingItemsUserDetailViewModel {
        internal typealias Factory = InjectedFactory<_SharingItemsUserDetailViewModelFactory>
}


internal typealias _SharingItemsUserGroupDetailViewModelFactory = @MainActor (
    _ userGroup: SharingItemsUserGroup,
    _ userGroupUpdatePublisher: AnyPublisher<SharingItemsUserGroup, Never>,
    _ itemsProvider: SharingToolItemsProvider
) -> SharingItemsUserGroupDetailViewModel

internal extension InjectedFactory where T == _SharingItemsUserGroupDetailViewModelFactory {
    @MainActor
    func make(userGroup: SharingItemsUserGroup, userGroupUpdatePublisher: AnyPublisher<SharingItemsUserGroup, Never>, itemsProvider: SharingToolItemsProvider) -> SharingItemsUserGroupDetailViewModel {
       return factory(
              userGroup,
              userGroupUpdatePublisher,
              itemsProvider
       )
    }
}

extension SharingItemsUserGroupDetailViewModel {
        internal typealias Factory = InjectedFactory<_SharingItemsUserGroupDetailViewModelFactory>
}


internal typealias _SharingMembersDetailLinkModelFactory = @MainActor (
    _ item: VaultItem
) -> SharingMembersDetailLinkModel

internal extension InjectedFactory where T == _SharingMembersDetailLinkModelFactory {
    @MainActor
    func make(item: VaultItem) -> SharingMembersDetailLinkModel {
       return factory(
              item
       )
    }
}

extension SharingMembersDetailLinkModel {
        internal typealias Factory = InjectedFactory<_SharingMembersDetailLinkModelFactory>
}


internal typealias _SharingMembersDetailViewModelFactory = @MainActor (
    _ members: ItemSharingMembers,
    _ item: VaultItem
) -> SharingMembersDetailViewModel

internal extension InjectedFactory where T == _SharingMembersDetailViewModelFactory {
    @MainActor
    func make(members: ItemSharingMembers, item: VaultItem) -> SharingMembersDetailViewModel {
       return factory(
              members,
              item
       )
    }
}

extension SharingMembersDetailViewModel {
        internal typealias Factory = InjectedFactory<_SharingMembersDetailViewModelFactory>
}


internal typealias _SharingPendingItemGroupsSectionViewModelFactory = @MainActor (
) -> SharingPendingItemGroupsSectionViewModel

internal extension InjectedFactory where T == _SharingPendingItemGroupsSectionViewModelFactory {
    @MainActor
    func make() -> SharingPendingItemGroupsSectionViewModel {
       return factory(
       )
    }
}

extension SharingPendingItemGroupsSectionViewModel {
        internal typealias Factory = InjectedFactory<_SharingPendingItemGroupsSectionViewModelFactory>
}


internal typealias _SharingPendingUserGroupsSectionViewModelFactory = @MainActor (
) -> SharingPendingUserGroupsSectionViewModel

internal extension InjectedFactory where T == _SharingPendingUserGroupsSectionViewModelFactory {
    @MainActor
    func make() -> SharingPendingUserGroupsSectionViewModel {
       return factory(
       )
    }
}

extension SharingPendingUserGroupsSectionViewModel {
        internal typealias Factory = InjectedFactory<_SharingPendingUserGroupsSectionViewModelFactory>
}


internal typealias _SharingRequestNotificationRowViewModelFactory =  (
    _ notification: DashlaneNotification
) -> SharingRequestNotificationRowViewModel

internal extension InjectedFactory where T == _SharingRequestNotificationRowViewModelFactory {
    
    func make(notification: DashlaneNotification) -> SharingRequestNotificationRowViewModel {
       return factory(
              notification
       )
    }
}

extension SharingRequestNotificationRowViewModel {
        internal typealias Factory = InjectedFactory<_SharingRequestNotificationRowViewModelFactory>
}


internal typealias _SharingToolItemsProviderFactory = @MainActor (
) -> SharingToolItemsProvider

internal extension InjectedFactory where T == _SharingToolItemsProviderFactory {
    @MainActor
    func make() -> SharingToolItemsProvider {
       return factory(
       )
    }
}

extension SharingToolItemsProvider {
        internal typealias Factory = InjectedFactory<_SharingToolItemsProviderFactory>
}


internal typealias _SharingToolViewModelFactory = @MainActor (
) -> SharingToolViewModel

internal extension InjectedFactory where T == _SharingToolViewModelFactory {
    @MainActor
    func make() -> SharingToolViewModel {
       return factory(
       )
    }
}

extension SharingToolViewModel {
        internal typealias Factory = InjectedFactory<_SharingToolViewModelFactory>
}


internal typealias _SharingToolsFlowViewModelFactory = @MainActor (
) -> SharingToolsFlowViewModel

internal extension InjectedFactory where T == _SharingToolsFlowViewModelFactory {
    @MainActor
    func make() -> SharingToolsFlowViewModel {
       return factory(
       )
    }
}

extension SharingToolsFlowViewModel {
        internal typealias Factory = InjectedFactory<_SharingToolsFlowViewModelFactory>
}


internal typealias _SharingUserGroupsSectionViewModelFactory = @MainActor (
    _ itemsProvider: SharingToolItemsProvider
) -> SharingUserGroupsSectionViewModel

internal extension InjectedFactory where T == _SharingUserGroupsSectionViewModelFactory {
    @MainActor
    func make(itemsProvider: SharingToolItemsProvider) -> SharingUserGroupsSectionViewModel {
       return factory(
              itemsProvider
       )
    }
}

extension SharingUserGroupsSectionViewModel {
        internal typealias Factory = InjectedFactory<_SharingUserGroupsSectionViewModelFactory>
}


internal typealias _SharingUsersSectionViewModelFactory = @MainActor (
    _ itemsProvider: SharingToolItemsProvider
) -> SharingUsersSectionViewModel

internal extension InjectedFactory where T == _SharingUsersSectionViewModelFactory {
    @MainActor
    func make(itemsProvider: SharingToolItemsProvider) -> SharingUsersSectionViewModel {
       return factory(
              itemsProvider
       )
    }
}

extension SharingUsersSectionViewModel {
        internal typealias Factory = InjectedFactory<_SharingUsersSectionViewModelFactory>
}


internal typealias _SidebarViewModelFactory =  (
) -> SidebarViewModel

internal extension InjectedFactory where T == _SidebarViewModelFactory {
    
    func make() -> SidebarViewModel {
       return factory(
       )
    }
}

extension SidebarViewModel {
        internal typealias Factory = InjectedFactory<_SidebarViewModelFactory>
}


internal typealias _SocialSecurityDetailViewModelFactory =  (
    _ item: SocialSecurityInformation,
    _ mode: DetailMode
) -> SocialSecurityDetailViewModel

internal extension InjectedFactory where T == _SocialSecurityDetailViewModelFactory {
    
    func make(item: SocialSecurityInformation, mode: DetailMode = .viewing) -> SocialSecurityDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension SocialSecurityDetailViewModel {
        internal typealias Factory = InjectedFactory<_SocialSecurityDetailViewModelFactory>
}


internal typealias _SocialSecurityDetailViewModelSecondFactory =  (
    _ service: DetailService<SocialSecurityInformation>
) -> SocialSecurityDetailViewModel

internal extension InjectedFactory where T == _SocialSecurityDetailViewModelSecondFactory {
    
    func make(service: DetailService<SocialSecurityInformation>) -> SocialSecurityDetailViewModel {
       return factory(
              service
       )
    }
}

extension SocialSecurityDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_SocialSecurityDetailViewModelSecondFactory>
}


internal typealias _ToolsFlowViewModelFactory = @MainActor (
    _ toolsItem: ToolsItem?
) -> ToolsFlowViewModel

internal extension InjectedFactory where T == _ToolsFlowViewModelFactory {
    @MainActor
    func make(toolsItem: ToolsItem?) -> ToolsFlowViewModel {
       return factory(
              toolsItem
       )
    }
}

extension ToolsFlowViewModel {
        internal typealias Factory = InjectedFactory<_ToolsFlowViewModelFactory>
}


internal typealias _ToolsViewModelFactory =  (
    _ didSelectItem: PassthroughSubject<ToolsItem, Never>
) -> ToolsViewModel

internal extension InjectedFactory where T == _ToolsViewModelFactory {
    
    func make(didSelectItem: PassthroughSubject<ToolsItem, Never>) -> ToolsViewModel {
       return factory(
              didSelectItem
       )
    }
}

extension ToolsViewModel {
        internal typealias Factory = InjectedFactory<_ToolsViewModelFactory>
}


internal typealias _TrialPeriodNotificationRowViewModelFactory =  (
    _ notification: DashlaneNotification
) -> TrialPeriodNotificationRowViewModel

internal extension InjectedFactory where T == _TrialPeriodNotificationRowViewModelFactory {
    
    func make(notification: DashlaneNotification) -> TrialPeriodNotificationRowViewModel {
       return factory(
              notification
       )
    }
}

extension TrialPeriodNotificationRowViewModel {
        internal typealias Factory = InjectedFactory<_TrialPeriodNotificationRowViewModelFactory>
}


internal typealias _TwoFAActivationViewModelFactory = @MainActor (
) -> TwoFAActivationViewModel

internal extension InjectedFactory where T == _TwoFAActivationViewModelFactory {
    @MainActor
    func make() -> TwoFAActivationViewModel {
       return factory(
       )
    }
}

extension TwoFAActivationViewModel {
        internal typealias Factory = InjectedFactory<_TwoFAActivationViewModelFactory>
}


internal typealias _TwoFACompletionViewModelFactory =  (
    _ option: TFAOption,
    _ response: TOTPActivationResponse,
    _ completion: @escaping () -> Void
) -> TwoFACompletionViewModel

internal extension InjectedFactory where T == _TwoFACompletionViewModelFactory {
    
    func make(option: TFAOption, response: TOTPActivationResponse, completion: @escaping () -> Void) -> TwoFACompletionViewModel {
       return factory(
              option,
              response,
              completion
       )
    }
}

extension TwoFACompletionViewModel {
        internal typealias Factory = InjectedFactory<_TwoFACompletionViewModelFactory>
}


internal typealias _TwoFADeactivationViewModelFactory = @MainActor (
    _ isTwoFAEnforced: Bool,
    _ recover2faWebService: Recover2FAWebService
) -> TwoFADeactivationViewModel

internal extension InjectedFactory where T == _TwoFADeactivationViewModelFactory {
    @MainActor
    func make(isTwoFAEnforced: Bool, recover2faWebService: Recover2FAWebService) -> TwoFADeactivationViewModel {
       return factory(
              isTwoFAEnforced,
              recover2faWebService
       )
    }
}

extension TwoFADeactivationViewModel {
        internal typealias Factory = InjectedFactory<_TwoFADeactivationViewModelFactory>
}


internal typealias _TwoFAPhoneNumberSetupViewModelFactory = @MainActor (
    _ option: TFAOption,
    _ completion: @escaping (TOTPActivationResponse?) -> Void
) -> TwoFAPhoneNumberSetupViewModel

internal extension InjectedFactory where T == _TwoFAPhoneNumberSetupViewModelFactory {
    @MainActor
    func make(option: TFAOption, completion: @escaping (TOTPActivationResponse?) -> Void) -> TwoFAPhoneNumberSetupViewModel {
       return factory(
              option,
              completion
       )
    }
}

extension TwoFAPhoneNumberSetupViewModel {
        internal typealias Factory = InjectedFactory<_TwoFAPhoneNumberSetupViewModelFactory>
}


internal typealias _TwoFASettingsViewModelFactory = @MainActor (
    _ login: Login,
    _ loginOTPOption: ThirdPartyOTPOption?,
    _ isTwoFAEnforced: Bool
) -> TwoFASettingsViewModel

internal extension InjectedFactory where T == _TwoFASettingsViewModelFactory {
    @MainActor
    func make(login: Login, loginOTPOption: ThirdPartyOTPOption?, isTwoFAEnforced: Bool) -> TwoFASettingsViewModel {
       return factory(
              login,
              loginOTPOption,
              isTwoFAEnforced
       )
    }
}

extension TwoFASettingsViewModel {
        internal typealias Factory = InjectedFactory<_TwoFASettingsViewModelFactory>
}


internal typealias _TwoFASetupViewModelFactory = @MainActor (
) -> TwoFASetupViewModel

internal extension InjectedFactory where T == _TwoFASetupViewModelFactory {
    @MainActor
    func make() -> TwoFASetupViewModel {
       return factory(
       )
    }
}

extension TwoFASetupViewModel {
        internal typealias Factory = InjectedFactory<_TwoFASetupViewModelFactory>
}


internal typealias _TwoFactorEnforcementViewModelFactory = @MainActor (
    _ logout: @escaping () -> Void
) -> TwoFactorEnforcementViewModel

internal extension InjectedFactory where T == _TwoFactorEnforcementViewModelFactory {
    @MainActor
    func make(logout: @escaping () -> Void) -> TwoFactorEnforcementViewModel {
       return factory(
              logout
       )
    }
}

extension TwoFactorEnforcementViewModel {
        internal typealias Factory = InjectedFactory<_TwoFactorEnforcementViewModelFactory>
}


internal typealias _UnresolvedAlertViewModelFactory =  (
) -> UnresolvedAlertViewModel

internal extension InjectedFactory where T == _UnresolvedAlertViewModelFactory {
    
    func make() -> UnresolvedAlertViewModel {
       return factory(
       )
    }
}

extension UnresolvedAlertViewModel {
        internal typealias Factory = InjectedFactory<_UnresolvedAlertViewModelFactory>
}


internal typealias _UserConsentViewModelFactory =  (
    _ isEmailMarketingOptInRequired: Bool,
    _ completion: @escaping (UserConsentViewModel.Completion) -> Void
) -> UserConsentViewModel

internal extension InjectedFactory where T == _UserConsentViewModelFactory {
    
    func make(isEmailMarketingOptInRequired: Bool, completion: @escaping (UserConsentViewModel.Completion) -> Void) -> UserConsentViewModel {
       return factory(
              isEmailMarketingOptInRequired,
              completion
       )
    }
}

extension UserConsentViewModel {
        internal typealias Factory = InjectedFactory<_UserConsentViewModelFactory>
}


internal typealias _VPNActivationViewModelFactory =  (
    _ actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>,
    _ activationState: VPNActivationState
) -> VPNActivationViewModel

internal extension InjectedFactory where T == _VPNActivationViewModelFactory {
    
    func make(actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>, activationState: VPNActivationState = .initial) -> VPNActivationViewModel {
       return factory(
              actionPublisher,
              activationState
       )
    }
}

extension VPNActivationViewModel {
        internal typealias Factory = InjectedFactory<_VPNActivationViewModelFactory>
}


internal typealias _VPNAvailableToolsFlowViewModelFactory = @MainActor (
) -> VPNAvailableToolsFlowViewModel

internal extension InjectedFactory where T == _VPNAvailableToolsFlowViewModelFactory {
    @MainActor
    func make() -> VPNAvailableToolsFlowViewModel {
       return factory(
       )
    }
}

extension VPNAvailableToolsFlowViewModel {
        internal typealias Factory = InjectedFactory<_VPNAvailableToolsFlowViewModelFactory>
}


internal typealias _VPNMainViewModelFactory =  (
    _ mode: VPNMainViewModel.VPNMainViewMode,
    _ credential: Credential?,
    _ actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>?
) -> VPNMainViewModel

internal extension InjectedFactory where T == _VPNMainViewModelFactory {
    
    func make(mode: VPNMainViewModel.VPNMainViewMode, credential: Credential? = nil, actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>? = nil) -> VPNMainViewModel {
       return factory(
              mode,
              credential,
              actionPublisher
       )
    }
}

extension VPNMainViewModel {
        internal typealias Factory = InjectedFactory<_VPNMainViewModelFactory>
}


internal typealias _VaultFlowViewModelFactory = @MainActor (
    _ itemCategory: ItemCategory?,
    _ onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)?
) -> VaultFlowViewModel

internal extension InjectedFactory where T == _VaultFlowViewModelFactory {
    @MainActor
    func make(itemCategory: ItemCategory? = nil, onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil) -> VaultFlowViewModel {
       return factory(
              itemCategory,
              onboardingChecklistViewAction
       )
    }
}

extension VaultFlowViewModel {
        internal typealias Factory = InjectedFactory<_VaultFlowViewModelFactory>
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


internal typealias _VaultItemRowModelFactory =  (
    _ configuration: VaultItemRowModel.Configuration,
    _ additionalConfiguration: VaultItemRowModel.AdditionalConfiguration?
) -> VaultItemRowModel

internal extension InjectedFactory where T == _VaultItemRowModelFactory {
    
    func make(configuration: VaultItemRowModel.Configuration, additionalConfiguration: VaultItemRowModel.AdditionalConfiguration? = nil) -> VaultItemRowModel {
       return factory(
              configuration,
              additionalConfiguration
       )
    }
}

extension VaultItemRowModel {
        internal typealias Factory = InjectedFactory<_VaultItemRowModelFactory>
}


internal typealias _VaultListViewModelFactory =  (
    _ filter: VaultItemsSection,
    _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultListViewModel

internal extension InjectedFactory where T == _VaultListViewModelFactory {
    
    func make(filter: VaultItemsSection, completion: @escaping (VaultListCompletion) -> Void) -> VaultListViewModel {
       return factory(
              filter,
              completion
       )
    }
}

extension VaultListViewModel {
        internal typealias Factory = InjectedFactory<_VaultListViewModelFactory>
}


internal typealias _VaultSearchViewModelFactory =  (
    _ activeFilter: VaultItemsSection,
    _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultSearchViewModel

internal extension InjectedFactory where T == _VaultSearchViewModelFactory {
    
    func make(activeFilter: VaultItemsSection, completion: @escaping (VaultListCompletion) -> Void) -> VaultSearchViewModel {
       return factory(
              activeFilter,
              completion
       )
    }
}

extension VaultSearchViewModel {
        internal typealias Factory = InjectedFactory<_VaultSearchViewModelFactory>
}


internal typealias _WebsiteDetailViewModelFactory =  (
    _ item: PersonalWebsite,
    _ mode: DetailMode
) -> WebsiteDetailViewModel

internal extension InjectedFactory where T == _WebsiteDetailViewModelFactory {
    
    func make(item: PersonalWebsite, mode: DetailMode = .viewing) -> WebsiteDetailViewModel {
       return factory(
              item,
              mode
       )
    }
}

extension WebsiteDetailViewModel {
        internal typealias Factory = InjectedFactory<_WebsiteDetailViewModelFactory>
}


internal typealias _WebsiteDetailViewModelSecondFactory =  (
    _ service: DetailService<PersonalWebsite>
) -> WebsiteDetailViewModel

internal extension InjectedFactory where T == _WebsiteDetailViewModelSecondFactory {
    
    func make(service: DetailService<PersonalWebsite>) -> WebsiteDetailViewModel {
       return factory(
              service
       )
    }
}

extension WebsiteDetailViewModel {
        internal typealias SecondFactory = InjectedFactory<_WebsiteDetailViewModelSecondFactory>
}

