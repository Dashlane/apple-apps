#if canImport(AuthenticationServices)
import AuthenticationServices
#endif
#if canImport(AuthenticatorKit)
import AuthenticatorKit
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
#if canImport(DashlaneAppKit)
import DashlaneAppKit
#endif
#if canImport(DashlaneCrypto)
import DashlaneCrypto
#endif
#if canImport(DashlaneReportKit)
import DashlaneReportKit
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

internal protocol AppServicesInjecting { }

 
extension AppServicesContainer {
        
        internal func makeLoginKitServicesContainer(logger: LoginInstallerLogger) -> LoginKitServicesContainer {
            return LoginKitServicesContainer(
                            loginUsageLogService: loginUsageLogService,
                            activityReporter: activityReporter,
                            sessionCleaner: sessionCleaner,
                            logger: logger,
                            settingsManager: spiegelSettingsManager,
                            keychainService: keychainService,
                            installerLogService: installerLogService,
                            nonAuthenticatedUKIBasedWebService: nonAuthenticatedUKIBasedWebService,
                            appAPIClient: appAPIClient,
                            sessionCryptoEngineProvider: sessionCryptoEngineProvider,
                            sessionContainer: sessionContainer,
                            rootLogger: rootLogger,
                            nitroWebService: nitroWebService
            )
        }
        
}

internal protocol MockVaultConnectedInjecting { }

 
extension MockVaultConnectedContainer {
        
        internal func makeAddAttachmentButtonViewModel(editingItem: VaultItem, logger: AttachmentsListUsageLogger, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
            return AddAttachmentButtonViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            editingItem: editingItem,
                            premiumService: premiumService,
                            logger: logger,
                            shouldDisplayRenameAlert: shouldDisplayRenameAlert,
                            itemPublisher: itemPublisher
            )
        }
        
}

extension MockVaultConnectedContainer {
        
        internal func makeAddOTPFlowViewModel(mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void) -> AddOTPFlowViewModel {
            return AddOTPFlowViewModel(
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            mode: mode,
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
                            usageLogService: usageLogService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            regionInformationService: regionInformationService,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
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
        
        internal func makeAttachmentsListViewModel(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
            return AttachmentsListViewModel(
                            documentStorageService: documentStorageService,
                            usageLogService: usageLogService,
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
                            usageLogService: usageLogService,
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
                            usageLogService: usageLogService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            regionInformationService: regionInformationService,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
        
        internal func makeCompanyDetailViewModel(item: Company, mode: DetailMode = .viewing) -> CompanyDetailViewModel {
            return CompanyDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            vaultItemsServices: vaultItemsService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            usageLogService: usageLogService,
                            deepLinkService: deepLinkService,
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
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: usageLogService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            regionInformationService: regionInformationService,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
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
                            usageLogService: usageLogService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            regionInformationService: regionInformationService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
        
        internal func makePassportDetailViewModel(item: Passport, mode: DetailMode = .viewing) -> PassportDetailViewModel {
            return PassportDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharedVaultHandling,
                            teamSpacesService: teamSpacesService,
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
        
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            saveGeneratedPassword: saveGeneratedPassword,
                            passwordEvaluator: passwordEvaluator,
                            usageLogService: usageLogService,
                            sessionActivityReporter: activityReporter,
                            userSettings: userSettings,
                            savePreferencesOnChange: savePreferencesOnChange
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: passwordEvaluator,
                            usageLogService: usageLogService,
                            sessionActivityReporter: activityReporter,
                            userSettings: userSettings,
                            savePreferencesOnChange: savePreferencesOnChange
            )
        }
                
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            database: database,
                            passwordEvaluator: passwordEvaluator,
                            usageLogService: usageLogService,
                            sessionActivityReporter: activityReporter,
                            userSettings: userSettings
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            regionInformationService: regionInformationService,
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
        
        internal func makeQuickActionsMenuViewModel(item: VaultItem, origin: VaultItemRowModel.Origin, isSuggestedItem: Bool) -> QuickActionsMenuViewModel {
            return QuickActionsMenuViewModel(
                            item: item,
                            sharingService: sharedVaultHandling,
                            accessControl: accessControl,
                            usageLogService: usageLogService,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            activityReporter: activityReporter,
                            userSettings: userSettings,
                            shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel),
                            origin: origin,
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
                            usageLogService: usageLogService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarModelFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            logger: logger,
                            documentStorageService: documentStorageService,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
            )
        }
                
        internal func makeSecureNotesDetailViewModel(service: DetailService<SecureNote>) -> SecureNotesDetailViewModel {
            return SecureNotesDetailViewModel(
                            service: service,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel)
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
                            usageLogService: usageLogService,
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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

extension MockVaultConnectedContainer {
        
        internal func makeVaultItemRowModel(configuration: VaultItemRowModel.Configuration, additionalConfiguration: VaultItemRowModel.AdditionalConfiguration? = nil) -> VaultItemRowModel {
            return VaultItemRowModel(
                            configuration: configuration,
                            additionalConfiguration: additionalConfiguration,
                            vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
                            quickActionsMenuViewModelFactory: InjectedFactory(makeQuickActionsMenuViewModel),
                            userSettings: userSettings,
                            accessControl: accessControl,
                            usageLogService: usageLogService,
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
                            usageLogService: usageLogService,
                            documentStorageService: documentStorageService,
                            deepLinkService: deepLinkService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: logger,
                            accessControl: accessControl,
                            userSettings: userSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
        
        internal func makeAddAttachmentButtonViewModel(editingItem: VaultItem, logger: AttachmentsListUsageLogger, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
            return AddAttachmentButtonViewModel(
                            documentStorageService: documentStorageService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            editingItem: editingItem,
                            premiumService: premiumService,
                            logger: logger,
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
                            sessionServices: self,
                            usageLogService: activityReporter.legacyUsage
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAddOTPFlowViewModel(mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void) -> AddOTPFlowViewModel {
            return AddOTPFlowViewModel(
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
                            mode: mode,
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
                            personalDataURLDecoder: appServices.personalDataURLDecoder,
                            vaultItemsService: vaultItemsService,
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            regionInformationService: appServices.regionInformationService,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deleteAction: deleteAction
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeAttachmentsListViewModel(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
            return AttachmentsListViewModel(
                            documentStorageService: documentStorageService,
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            regionInformationService: appServices.regionInformationService,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
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
                            passwordEvaluator: appServices.passwordEvaluator,
                            logger: appServices.rootLogger,
                            activityReporter: activityReporter,
                            syncService: syncService,
                            apiClient: userDeviceAPIClient,
                            resetMasterPasswordService: resetMasterPasswordService,
                            keychainService: appServices.keychainService,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            databaseDriver: databaseDriver,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            vaultItemsServices: vaultItemsService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            usageLogService: activityReporter.legacyUsage,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            featureService: featureService,
                            iconService: iconService,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            passwordEvaluator: appServices.passwordEvaluator,
                            linkedDomainsService: appServices.linkedDomainService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            documentStorageService: documentStorageService,
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
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: activityReporter.legacyUsage,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            regionInformationService: appServices.regionInformationService,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel,
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
        
        internal func makeDWMEmailConfirmationViewModel(accountEmail: String, context: DWMOnboardingPresentationContext, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy, completion: @escaping (DWMEmailConfirmationViewModel.Completion) -> Void) -> DWMEmailConfirmationViewModel {
            return DWMEmailConfirmationViewModel(
                            accountEmail: accountEmail,
                            context: context,
                            emailStatusCheck: emailStatusCheck,
                            webservice: legacyWebService,
                            settings: dwmOnboardingSettings,
                            dwmOnboardingService: dwmOnboardingService,
                            logsService: activityReporter.legacyUsage,
                            completion: completion
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
        
        internal func makeDWMRegistrationInGuidedOnboardingViewModel(email: String, completion: ((DWMRegistrationViewModel.Completion) -> Void)?) -> DWMRegistrationInGuidedOnboardingViewModel {
            return DWMRegistrationInGuidedOnboardingViewModel(
                            email: email,
                            dwmOnboardingService: dwmOnboardingService,
                            logsService: activityReporter.legacyUsage,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDWMRegistrationInOnboardingChecklistViewModel(email: String, completion: ((DWMRegistrationInOnboardingChecklistViewModel.Completion) -> Void)?) -> DWMRegistrationInOnboardingChecklistViewModel {
            return DWMRegistrationInOnboardingChecklistViewModel(
                            email: email,
                            dwmOnboardingService: dwmOnboardingService,
                            logsService: activityReporter.legacyUsage,
                            completion: completion
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
        
        internal func makeDarkWebMonitoringDetailsViewModel(breach: DWMSimplifiedBreach, breachViewModel: BreachViewModel, usageLogService: DWMLogService, actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil) -> DarkWebMonitoringDetailsViewModel {
            return DarkWebMonitoringDetailsViewModel(
                            breach: breach,
                            breachViewModel: breachViewModel,
                            darkWebMonitoringService: darkWebMonitoringService,
                            domainParser: appServices.domainParser,
                            usageLogService: usageLogService,
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
                            usageLogService: activityReporter.legacyUsage,
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
                            dataLeakService: dataLeakService,
                            usageLogService: activityReporter.legacyUsage
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeDetailView(itemDetailViewType: ItemDetailViewType, dismiss: DetailContainerViewSpecificAction? = nil) -> DetailView {
            return DetailView(
                            itemDetailViewType: itemDetailViewType,
                            dismiss: dismiss,
                            sessionServices: self
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
                            usageLogService: activityReporter.legacyUsage,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            regionInformationService: appServices.regionInformationService,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            documentStorageService: documentStorageService,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
            )
        }
                
        internal func makeFiscalInformationDetailViewModel(service: DetailService<FiscalInformation>) -> FiscalInformationDetailViewModel {
            return FiscalInformationDetailViewModel(
                            service: service
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeGeneralSettingsViewModel() -> GeneralSettingsViewModel {
            return GeneralSettingsViewModel(
                            personalDataURLDecoder: appServices.personalDataURLDecoder,
                            applicationDatabase: database,
                            databaseDriver: databaseDriver,
                            iconService: iconService,
                            activityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            usageLogService: activityReporter.legacyUsage,
                            exportSecureArchiveViewModelFactory: InjectedFactory(makeExportSecureArchiveViewModel)
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
                            logService: activityReporter.legacyUsage,
                            completion: completion
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeHelpCenterSettingsViewModel() -> HelpCenterSettingsViewModel {
            return HelpCenterSettingsViewModel(
                            usageLogService: activityReporter.legacyUsage
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
                            usageLogService: activityReporter.legacyUsage,
                            brazeService: brazeServiceProtocol,
                            syncedSettings: syncedSettings,
                            premiumService: announcementsPremiumService,
                            deepLinkingService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            capabilityService: capabilityService,
                            lockService: lockService,
                            abTestingService: authenticatedABTestingService,
                            onboardingAction: onboardingAction,
                            action: action,
                            homeModalAnnouncementsViewModelFactory: InjectedFactory(makeHomeModalAnnouncementsViewModel),
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            featureFlipService: featureService,
                            labsService: labsService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeLockViewModel(locker: ScreenLocker, changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher) -> LockViewModel {
            return LockViewModel(
                            locker: locker,
                            keychainService: appServices.keychainService,
                            userSettings: spiegelUserSettings,
                            resetMasterPasswordService: resetMasterPasswordService,
                            installerLogService: appServices.installerLogService,
                            usageLogService: activityReporter.legacyUsage,
                            activityReporter: activityReporter,
                            teamspaceService: teamSpacesService,
                            loginUsageLogService: appServices.loginUsageLogService,
                            lockService: lockService,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            changeMasterPasswordLauncher: changeMasterPasswordLauncher
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
        
        internal func makeMainSettingsViewModel(labsService: LabsService) -> MainSettingsViewModel {
            return MainSettingsViewModel(
                            session: session,
                            premiumService: premiumService,
                            teamSpacesService: teamSpacesService,
                            deepLinkingService: appServices.deepLinkingService,
                            lockService: lockService,
                            usageLogService: activityReporter.legacyUsage,
                            sharingLinkService: sharingLinkService,
                            userSettings: spiegelUserSettings,
                            labsService: labsService,
                            featureService: featureService,
                            settingsStatusSectionViewModelFactory: InjectedFactory(makeSettingsStatusSectionViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeMasterPasswordResetActivationViewModel(actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> MasterPasswordResetActivationViewModel {
            return MasterPasswordResetActivationViewModel(
                            session: session,
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
        
        internal func makeMiniBrowserViewModel(email: String, password: String, displayableDomain: String, url: URL, usageLogService: DWMLogService, completion: @escaping (MiniBrowserViewModel.Completion) -> Void) -> MiniBrowserViewModel {
            return MiniBrowserViewModel(
                            email: email,
                            password: password,
                            displayableDomain: displayableDomain,
                            url: url,
                            domainParser: appServices.domainParser,
                            usageLogService: usageLogService,
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
                            usageLogService: activityReporter.legacyUsage,
                            sharingService: sharingService,
                            teamspaceService: teamSpacesService,
                            abtestService: authenticatedABTestingService,
                            keychainService: appServices.keychainService,
                            featureService: featureService
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
                            usageLogService: activityReporter.legacyUsage,
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
        
        internal func makeOTPTokenListViewModel(authenticatorDatabaseService: OTPDatabaseService, domainIconLibray: DomainIconLibraryProtocol, actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void) -> OTPTokenListViewModel {
            return OTPTokenListViewModel(
                            activityReporter: activityReporter,
                            vaultItemsService: vaultItemsService,
                            authenticatorDatabaseService: authenticatorDatabaseService,
                            domainParser: appServices.domainParser,
                            domainIconLibray: domainIconLibray,
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
        
        internal func makeOnboardingChecklistViewModel(logsService: OnboardingChecklistLogsService, action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void) -> OnboardingChecklistViewModel {
            return OnboardingChecklistViewModel(
                            userSettings: spiegelUserSettings,
                            dwmOnboardingSettings: dwmOnboardingSettings,
                            dwmOnboardingService: dwmOnboardingService,
                            vaultItemsService: vaultItemsService,
                            capabilityService: capabilityService,
                            featureService: featureService,
                            onboardingService: onboardingService,
                            autofillService: autofillService,
                            logsService: logsService,
                            lockService: lockService,
                            activityReporter: activityReporter,
                            userSwitcherViewModel: makeUserSpaceSwitcherViewModel,
                            action: action,
                            homeModalAnnouncementsViewModelFactory: InjectedFactory(makeHomeModalAnnouncementsViewModel)
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            passwordEvaluator: appServices.passwordEvaluator
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
        internal func makePasswordGeneratorToolsFlowViewModel() -> PasswordGeneratorToolsFlowViewModel {
            return PasswordGeneratorToolsFlowViewModel(
                            deepLinkingService: appServices.deepLinkingService,
                            passwordGeneratorViewModelFactory: InjectedFactory(makePasswordGeneratorViewModel),
                            passwordGeneratorHistoryViewModelFactory: InjectedFactory(makePasswordGeneratorHistoryViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePasswordGeneratorViewModel(mode: PasswordGeneratorMode, saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword, savePreferencesOnChange: Bool = true) -> PasswordGeneratorViewModel {
            return PasswordGeneratorViewModel(
                            mode: mode,
                            saveGeneratedPassword: saveGeneratedPassword,
                            passwordEvaluator: appServices.passwordEvaluator,
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            sessionActivityReporter: activityReporter,
                            userSettings: spiegelUserSettings
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
                            usageLogService: activityReporter.legacyUsage,
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
                            passwordEvaluator: appServices.passwordEvaluator,
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
                            userSpaceSwitcherViewModel: makeUserSpaceSwitcherViewModel
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            regionInformationService: appServices.regionInformationService,
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            lockService: lockService,
                            teamSpaceService: teamSpacesService,
                            usageLogService: activityReporter.legacyUsage,
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePreAccountCreationOnboardingViewModel(localDataRemover: LocalDataRemover) -> PreAccountCreationOnboardingViewModel {
            return PreAccountCreationOnboardingViewModel(
                            installerLogService: appServices.installerLogService,
                            localDataRemover: localDataRemover
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makePremiumAnnouncementsViewModel(excludedAnnouncements: Set<PremiumAnnouncement> = []) -> PremiumAnnouncementsViewModel {
            return PremiumAnnouncementsViewModel(
                            premiumService: premiumService,
                            teamspaceService: teamSpacesService,
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
                            usageLogService: activityReporter.legacyUsage,
                            vaultItemsService: vaultItemsService,
                            teamSpacesService: teamSpacesService,
                            activityReporter: activityReporter,
                            userSettings: spiegelUserSettings,
                            shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel),
                            origin: origin,
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
                            lockService: lockService,
                            usageLogService: activityReporter.legacyUsage
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
                            usageLogService: activityReporter.legacyUsage,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarModelFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
                            logger: appServices.rootLogger,
                            documentStorageService: documentStorageService,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
            )
        }
                
        internal func makeSecureNotesDetailViewModel(service: DetailService<SecureNote>) -> SecureNotesDetailViewModel {
            return SecureNotesDetailViewModel(
                            service: service,
                            secureNotesDetailNavigationBarModelFactory: InjectedFactory(makeSecureNotesDetailNavigationBarModel),
                            secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
                            secureNotesDetailToolbarFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
                            sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
                            shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel)
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
        
        internal func makeSecuritySettingsViewModel() -> SecuritySettingsViewModel {
            return SecuritySettingsViewModel(
                            session: session,
                            teamSpacesService: teamSpacesService,
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
        
        internal func makeSettingsAccountSectionViewModel(actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> SettingsAccountSectionViewModel {
            return SettingsAccountSectionViewModel(
                            session: session,
                            featureService: featureService,
                            teamSpacesService: teamSpacesService,
                            premiumService: premiumService,
                            deviceListViewModel: makeDeviceListViewModel,
                            subscriptionCodeFetcher: subscriptionCodeFetcher,
                            usageLogService: activityReporter.legacyUsage,
                            activityReporter: activityReporter,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            deepLinkingService: appServices.deepLinkingService,
                            masterPasswordResetActivationViewModelFactory: InjectedFactory(makeMasterPasswordResetActivationViewModel),
                            changeMasterPasswordFlowViewModelFactory: InjectedFactory(makeChangeMasterPasswordFlowViewModel),
                            actionHandler: actionHandler
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeSettingsBiometricToggleViewModel(actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void) -> SettingsBiometricToggleViewModel {
            return SettingsBiometricToggleViewModel(
                            lockService: lockService,
                            featureService: featureService,
                            teamSpaceService: teamSpacesService,
                            resetMasterPasswordService: resetMasterPasswordService,
                            usageLogService: activityReporter.legacyUsage,
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
                            labsSettingsViewModelFactory: InjectedFactory(makeLabsSettingsViewModel)
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
                            teamSpacesService: teamSpacesService,
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
                            usageLogService: activityReporter.legacyUsage,
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
                            sharingService: sharingService
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
        
        internal func makeSocialSecurityDetailViewModel(item: SocialSecurityInformation, mode: DetailMode = .viewing) -> SocialSecurityDetailViewModel {
            return SocialSecurityDetailViewModel(
                            item: item,
                            mode: mode,
                            vaultItemsService: vaultItemsService,
                            sharingService: sharingService,
                            teamSpacesService: teamSpacesService,
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
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
                            capabilityService: capabilityService,
                            deepLinkingService: appServices.deepLinkingService,
                            darkWebMonitoringService: darkWebMonitoringService,
                            toolsViewModelFactory: InjectedFactory(makeToolsViewModel),
                            passwordHealthFlowViewModelFactory: InjectedFactory(makePasswordHealthFlowViewModel),
                            authenticatorToolFlowViewModelFactory: InjectedFactory(makeAuthenticatorToolFlowViewModel),
                            passwordGeneratorToolsFlowViewModelFactory: InjectedFactory(makePasswordGeneratorToolsFlowViewModel),
                            vpnAvailableToolsFlowViewModelFactory: InjectedFactory(makeVPNAvailableToolsFlowViewModel),
                            sharingToolsFlowViewModelFactory: InjectedFactory(makeSharingToolsFlowViewModel),
                            darkWebToolsFlowViewModelFactory: InjectedFactory(makeDarkWebToolsFlowViewModel),
                            unresolvedAlertViewModelFactory: InjectedFactory(makeUnresolvedAlertViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeToolsViewModel(didSelectItem: PassthroughSubject<ToolsItem, Never>) -> ToolsViewModel {
            return ToolsViewModel(
                            toolsService: toolsService,
                            usageLogService: activityReporter.legacyUsage,
                            premiumService: premiumService,
                            didSelectItem: didSelectItem
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeTrialPeriodNotificationRowViewModel(notification: DashlaneNotification) -> TrialPeriodNotificationRowViewModel {
            return TrialPeriodNotificationRowViewModel(
                            notification: notification,
                            capabilityService: capabilityService,
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
        
        internal func makeTwoFACompletionViewModel(option: TFAOption, response: TOTPActivationResponse, accountAPIClient: AccountAPIClientProtocol, completion: @escaping () -> Void) -> TwoFACompletionViewModel {
            return TwoFACompletionViewModel(
                            option: option,
                            response: response,
                            session: session,
                            sessionsContainer: appServices.sessionContainer,
                            keychainService: appServices.keychainService,
                            accountAPIClient: accountAPIClient,
                            persistor: appServices.authenticatorDatabaseService,
                            authenticatorCommunicator: authenticatorAppCommunicator,
                            syncService: syncService,
                            resetMasterPasswordService: resetMasterPasswordService,
                            databaseDriver: databaseDriver,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            activityReporter: activityReporter,
                            authenticatedAPIClient: userDeviceAPIClient,
                            appAPIClient: appServices.appAPIClient,
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
                            logger: appServices.rootLogger,
                            authenticatorCommunicator: authenticatorAppCommunicator,
                            syncService: syncService,
                            keychainService: appServices.keychainService,
                            sessionCryptoUpdater: sessionCryptoUpdater,
                            activityReporter: activityReporter,
                            resetMasterPasswordService: resetMasterPasswordService,
                            databaseDriver: databaseDriver,
                            persistor: appServices.authenticatorDatabaseService,
                            sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
                            isTwoFAEnforced: isTwoFAEnforced,
                            recover2faWebService: recover2faWebService
            )
        }
        
}

extension SessionServicesContainer {
        @MainActor
        internal func makeTwoFAPhoneNumberSetupViewModel(accountAPIClient: AccountAPIClientProtocol, option: TFAOption, completion: @escaping (TOTPActivationResponse?) -> Void) -> TwoFAPhoneNumberSetupViewModel {
            return TwoFAPhoneNumberSetupViewModel(
                            accountAPIClient: accountAPIClient,
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
                            authenticatedAPIClient: userDeviceAPIClient,
                            nonAuthenticatedUKIBasedWebService: legacyWebService,
                            logger: appServices.rootLogger,
                            isTwoFAEnforced: isTwoFAEnforced,
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
        internal func makeTwoFactorEnforcementViewModel(accountAPIClient: AccountAPIClientProtocol, logout: @escaping () -> Void) -> TwoFactorEnforcementViewModel {
            return TwoFactorEnforcementViewModel(
                            accountAPIClient: accountAPIClient,
                            lockService: lockService,
                            twoFASetupViewModelFactory: InjectedFactory(makeTwoFASetupViewModel),
                            logout: logout
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeUnresolvedAlertViewModel() -> UnresolvedAlertViewModel {
            return UnresolvedAlertViewModel(
                            usageLogService: activityReporter.legacyUsage,
                            identityDashboardService: identityDashboardService,
                            deeplinkService: appServices.deepLinkingService,
                            passwordHealthFlowViewModelFactory: InjectedFactory(makePasswordHealthFlowViewModel)
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeUserSpaceSwitcherViewModel() -> UserSpaceSwitcherViewModel {
            return UserSpaceSwitcherViewModel(
                            teamSpacesService: teamSpacesService,
                            activityReporter: activityReporter
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
                            sessionServices: self,
                            usageLogService: activityReporter.legacyUsage
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

extension SessionServicesContainer {
        
        internal func makeVaultItemRowModel(configuration: VaultItemRowModel.Configuration, additionalConfiguration: VaultItemRowModel.AdditionalConfiguration? = nil) -> VaultItemRowModel {
            return VaultItemRowModel(
                            configuration: configuration,
                            additionalConfiguration: additionalConfiguration,
                            vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
                            quickActionsMenuViewModelFactory: InjectedFactory(makeQuickActionsMenuViewModel),
                            userSettings: spiegelUserSettings,
                            accessControl: accessControl,
                            usageLogService: activityReporter.legacyUsage,
                            activityReporter: activityReporter,
                            teamSpacesService: teamSpacesService,
                            vaultItemsService: vaultItemsService,
                            sharingPermissionProvider: sharingService
            )
        }
        
}

extension SessionServicesContainer {
        
        internal func makeVaultListViewModel(filter: VaultListFilter, completion: @escaping (VaultListCompletion) -> Void) -> VaultListViewModel {
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
        
        internal func makeVaultSearchViewModel(activeFilter: VaultListFilter, completion: @escaping (VaultListCompletion) -> Void) -> VaultSearchViewModel {
            return VaultSearchViewModel(
                            vaultItemsService: vaultItemsService,
                            capabilityService: capabilityService,
                            sharingService: sharingService,
                            featureService: featureService,
                            activityReporter: activityReporter,
                            teamSpacesService: teamSpacesService,
                            userSwitcherViewModel: makeUserSpaceSwitcherViewModel,
                            usageLogService: activityReporter.legacyUsage,
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
                            usageLogService: activityReporter.legacyUsage,
                            documentStorageService: documentStorageService,
                            deepLinkService: appServices.deepLinkingService,
                            activityReporter: activityReporter,
                            iconViewModelProvider: makeVaultItemIconViewModel,
                            logger: appServices.rootLogger,
                            accessControl: accessControl,
                            userSettings: spiegelUserSettings,
                            attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
                            attachmentsListViewModelProvider: makeAttachmentsListViewModel
            )
        }
                
        internal func makeWebsiteDetailViewModel(service: DetailService<PersonalWebsite>) -> WebsiteDetailViewModel {
            return WebsiteDetailViewModel(
                            service: service
            )
        }
        
}


internal typealias _AddAttachmentButtonViewModelFactory =  (
    _ editingItem: VaultItem,
    _ logger: AttachmentsListUsageLogger,
    _ shouldDisplayRenameAlert: Bool,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AddAttachmentButtonViewModel

internal extension InjectedFactory where T == _AddAttachmentButtonViewModelFactory {
    
    func make(editingItem: VaultItem, logger: AttachmentsListUsageLogger, shouldDisplayRenameAlert: Bool = true, itemPublisher: AnyPublisher<VaultItem, Never>) -> AddAttachmentButtonViewModel {
       return factory(
              editingItem,
              logger,
              shouldDisplayRenameAlert,
              itemPublisher
       )
    }
}

extension AddAttachmentButtonViewModel {
        internal typealias Factory = InjectedFactory<_AddAttachmentButtonViewModelFactory>
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


internal typealias _AttachmentRowViewModelFactory =  (
    _ attachment: Attachment,
    _ attachmentPublisher: AnyPublisher<Attachment, Never>,
    _ editingItem: DocumentAttachable,
    _ deleteAction: @escaping (Attachment) -> Void
) -> AttachmentRowViewModel

internal extension InjectedFactory where T == _AttachmentRowViewModelFactory {
    
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
        internal typealias Factory = InjectedFactory<_AttachmentRowViewModelFactory>
}


internal typealias _AttachmentsListViewModelFactory =  (
    _ editingItem: VaultItem,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsListViewModel

internal extension InjectedFactory where T == _AttachmentsListViewModelFactory {
    
    func make(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel {
       return factory(
              editingItem,
              itemPublisher
       )
    }
}

extension AttachmentsListViewModel {
        internal typealias Factory = InjectedFactory<_AttachmentsListViewModelFactory>
}


internal typealias _AttachmentsSectionViewModelFactory =  (
    _ item: VaultItem,
    _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsSectionViewModel

internal extension InjectedFactory where T == _AttachmentsSectionViewModelFactory {
    
    func make(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>) -> AttachmentsSectionViewModel {
       return factory(
              item,
              itemPublisher
       )
    }
}

extension AttachmentsSectionViewModel {
        internal typealias Factory = InjectedFactory<_AttachmentsSectionViewModelFactory>
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


internal typealias _DWMEmailConfirmationViewModelFactory =  (
    _ accountEmail: String,
    _ context: DWMOnboardingPresentationContext,
    _ emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy,
    _ completion: @escaping (DWMEmailConfirmationViewModel.Completion) -> Void
) -> DWMEmailConfirmationViewModel

internal extension InjectedFactory where T == _DWMEmailConfirmationViewModelFactory {
    
    func make(accountEmail: String, context: DWMOnboardingPresentationContext, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy, completion: @escaping (DWMEmailConfirmationViewModel.Completion) -> Void) -> DWMEmailConfirmationViewModel {
       return factory(
              accountEmail,
              context,
              emailStatusCheck,
              completion
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


internal typealias _DWMRegistrationInGuidedOnboardingViewModelFactory =  (
    _ email: String,
    _ completion: ((DWMRegistrationViewModel.Completion) -> Void)?
) -> DWMRegistrationInGuidedOnboardingViewModel

internal extension InjectedFactory where T == _DWMRegistrationInGuidedOnboardingViewModelFactory {
    
    func make(email: String, completion: ((DWMRegistrationViewModel.Completion) -> Void)?) -> DWMRegistrationInGuidedOnboardingViewModel {
       return factory(
              email,
              completion
       )
    }
}

extension DWMRegistrationInGuidedOnboardingViewModel {
        internal typealias Factory = InjectedFactory<_DWMRegistrationInGuidedOnboardingViewModelFactory>
}


internal typealias _DWMRegistrationInOnboardingChecklistViewModelFactory =  (
    _ email: String,
    _ completion: ((DWMRegistrationInOnboardingChecklistViewModel.Completion) -> Void)?
) -> DWMRegistrationInOnboardingChecklistViewModel

internal extension InjectedFactory where T == _DWMRegistrationInOnboardingChecklistViewModelFactory {
    
    func make(email: String, completion: ((DWMRegistrationInOnboardingChecklistViewModel.Completion) -> Void)?) -> DWMRegistrationInOnboardingChecklistViewModel {
       return factory(
              email,
              completion
       )
    }
}

extension DWMRegistrationInOnboardingChecklistViewModel {
        internal typealias Factory = InjectedFactory<_DWMRegistrationInOnboardingChecklistViewModelFactory>
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
    _ usageLogService: DWMLogService,
    _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?
) -> DarkWebMonitoringDetailsViewModel

internal extension InjectedFactory where T == _DarkWebMonitoringDetailsViewModelFactory {
    
    func make(breach: DWMSimplifiedBreach, breachViewModel: BreachViewModel, usageLogService: DWMLogService, actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil) -> DarkWebMonitoringDetailsViewModel {
       return factory(
              breach,
              breachViewModel,
              usageLogService,
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


internal typealias _GeneralSettingsViewModelFactory =  (
) -> GeneralSettingsViewModel

internal extension InjectedFactory where T == _GeneralSettingsViewModelFactory {
    
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
    _ changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher
) -> LockViewModel

internal extension InjectedFactory where T == _LockViewModelFactory {
    @MainActor
    func make(locker: ScreenLocker, changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher) -> LockViewModel {
       return factory(
              locker,
              changeMasterPasswordLauncher
       )
    }
}

extension LockViewModel {
        internal typealias Factory = InjectedFactory<_LockViewModelFactory>
}


public typealias _LoginKitServicesContainerFactory =  (
    _ logger: LoginInstallerLogger
) -> LoginKitServicesContainer

public extension InjectedFactory where T == _LoginKitServicesContainerFactory {
    
    func make(logger: LoginInstallerLogger) -> LoginKitServicesContainer {
       return factory(
              logger
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


internal typealias _MainSettingsViewModelFactory =  (
    _ labsService: LabsService
) -> MainSettingsViewModel

internal extension InjectedFactory where T == _MainSettingsViewModelFactory {
    
    func make(labsService: LabsService) -> MainSettingsViewModel {
       return factory(
              labsService
       )
    }
}

extension MainSettingsViewModel {
        internal typealias Factory = InjectedFactory<_MainSettingsViewModelFactory>
}


internal typealias _MasterPasswordResetActivationViewModelFactory =  (
    _ actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
) -> MasterPasswordResetActivationViewModel

internal extension InjectedFactory where T == _MasterPasswordResetActivationViewModelFactory {
    
    func make(actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void) -> MasterPasswordResetActivationViewModel {
       return factory(
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


internal typealias _MiniBrowserViewModelFactory =  (
    _ email: String,
    _ password: String,
    _ displayableDomain: String,
    _ url: URL,
    _ usageLogService: DWMLogService,
    _ completion: @escaping (MiniBrowserViewModel.Completion) -> Void
) -> MiniBrowserViewModel

internal extension InjectedFactory where T == _MiniBrowserViewModelFactory {
    
    func make(email: String, password: String, displayableDomain: String, url: URL, usageLogService: DWMLogService, completion: @escaping (MiniBrowserViewModel.Completion) -> Void) -> MiniBrowserViewModel {
       return factory(
              email,
              password,
              displayableDomain,
              url,
              usageLogService,
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
    _ authenticatorDatabaseService: OTPDatabaseService,
    _ domainIconLibray: DomainIconLibraryProtocol,
    _ actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void
) -> OTPTokenListViewModel

internal extension InjectedFactory where T == _OTPTokenListViewModelFactory {
    
    func make(authenticatorDatabaseService: OTPDatabaseService, domainIconLibray: DomainIconLibraryProtocol, actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void) -> OTPTokenListViewModel {
       return factory(
              authenticatorDatabaseService,
              domainIconLibray,
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
    _ logsService: OnboardingChecklistLogsService,
    _ action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
) -> OnboardingChecklistViewModel

internal extension InjectedFactory where T == _OnboardingChecklistViewModelFactory {
    
    func make(logsService: OnboardingChecklistLogsService, action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void) -> OnboardingChecklistViewModel {
       return factory(
              logsService,
              action
       )
    }
}

extension OnboardingChecklistViewModel {
        internal typealias Factory = InjectedFactory<_OnboardingChecklistViewModelFactory>
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
) -> PasswordGeneratorToolsFlowViewModel

internal extension InjectedFactory where T == _PasswordGeneratorToolsFlowViewModelFactory {
    @MainActor
    func make() -> PasswordGeneratorToolsFlowViewModel {
       return factory(
       )
    }
}

extension PasswordGeneratorToolsFlowViewModel {
        internal typealias Factory = InjectedFactory<_PasswordGeneratorToolsFlowViewModelFactory>
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


internal typealias _PreAccountCreationOnboardingViewModelFactory =  (
    _ localDataRemover: LocalDataRemover
) -> PreAccountCreationOnboardingViewModel

internal extension InjectedFactory where T == _PreAccountCreationOnboardingViewModelFactory {
    
    func make(localDataRemover: LocalDataRemover) -> PreAccountCreationOnboardingViewModel {
       return factory(
              localDataRemover
       )
    }
}

extension PreAccountCreationOnboardingViewModel {
        internal typealias Factory = InjectedFactory<_PreAccountCreationOnboardingViewModelFactory>
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


internal typealias _SecuritySettingsViewModelFactory =  (
) -> SecuritySettingsViewModel

internal extension InjectedFactory where T == _SecuritySettingsViewModelFactory {
    
    func make() -> SecuritySettingsViewModel {
       return factory(
       )
    }
}

extension SecuritySettingsViewModel {
        internal typealias Factory = InjectedFactory<_SecuritySettingsViewModelFactory>
}


internal typealias _SettingsAccountSectionViewModelFactory =  (
    _ actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
) -> SettingsAccountSectionViewModel

internal extension InjectedFactory where T == _SettingsAccountSectionViewModelFactory {
    
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
    _ accountAPIClient: AccountAPIClientProtocol,
    _ completion: @escaping () -> Void
) -> TwoFACompletionViewModel

internal extension InjectedFactory where T == _TwoFACompletionViewModelFactory {
    
    func make(option: TFAOption, response: TOTPActivationResponse, accountAPIClient: AccountAPIClientProtocol, completion: @escaping () -> Void) -> TwoFACompletionViewModel {
       return factory(
              option,
              response,
              accountAPIClient,
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
    _ accountAPIClient: AccountAPIClientProtocol,
    _ option: TFAOption,
    _ completion: @escaping (TOTPActivationResponse?) -> Void
) -> TwoFAPhoneNumberSetupViewModel

internal extension InjectedFactory where T == _TwoFAPhoneNumberSetupViewModelFactory {
    @MainActor
    func make(accountAPIClient: AccountAPIClientProtocol, option: TFAOption, completion: @escaping (TOTPActivationResponse?) -> Void) -> TwoFAPhoneNumberSetupViewModel {
       return factory(
              accountAPIClient,
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
    _ accountAPIClient: AccountAPIClientProtocol,
    _ logout: @escaping () -> Void
) -> TwoFactorEnforcementViewModel

internal extension InjectedFactory where T == _TwoFactorEnforcementViewModelFactory {
    @MainActor
    func make(accountAPIClient: AccountAPIClientProtocol, logout: @escaping () -> Void) -> TwoFactorEnforcementViewModel {
       return factory(
              accountAPIClient,
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


internal typealias _UserSpaceSwitcherViewModelFactory =  (
) -> UserSpaceSwitcherViewModel

internal extension InjectedFactory where T == _UserSpaceSwitcherViewModelFactory {
    
    func make() -> UserSpaceSwitcherViewModel {
       return factory(
       )
    }
}

extension UserSpaceSwitcherViewModel {
        internal typealias Factory = InjectedFactory<_UserSpaceSwitcherViewModelFactory>
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
    _ filter: VaultListFilter,
    _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultListViewModel

internal extension InjectedFactory where T == _VaultListViewModelFactory {
    
    func make(filter: VaultListFilter, completion: @escaping (VaultListCompletion) -> Void) -> VaultListViewModel {
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
    _ activeFilter: VaultListFilter,
    _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultSearchViewModel

internal extension InjectedFactory where T == _VaultSearchViewModelFactory {
    
    func make(activeFilter: VaultListFilter, completion: @escaping (VaultListCompletion) -> Void) -> VaultSearchViewModel {
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

