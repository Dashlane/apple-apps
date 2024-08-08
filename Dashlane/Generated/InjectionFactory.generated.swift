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
#if canImport(CoreActivityLogs)
  import CoreActivityLogs
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
#if canImport(MacrosKit)
  import MacrosKit
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

internal protocol AccountCreationFlowDependenciesInjecting {}

extension AccountCreationFlowDependenciesContainer {
  @MainActor
  internal func makeAccountCreationFlowViewModel(
    completion: @MainActor @escaping (AccountCreationFlowViewModel.CompletionResult) -> Void
  ) -> AccountCreationFlowViewModel {
    return AccountCreationFlowViewModel(
      evaluator: passwordEvaluator,
      activityReporter: activityReporter,
      emailViewModelFactory: InjectedFactory(makeAccountEmailViewModel),
      masterPasswordAccountCreationModelFactory: InjectedFactory(
        makeMasterPasswordAccountCreationFlowViewModel),
      passwordLessAccountCreationModelFactory: InjectedFactory(
        makePasswordLessAccountCreationFlowViewModel),
      completion: completion
    )
  }

}

extension AccountCreationFlowDependenciesContainer {
  @MainActor
  internal func makeAccountEmailViewModel(
    completion: @escaping (_ result: AccountEmailViewModel.CompletionResult) -> Void
  ) -> AccountEmailViewModel {
    return AccountEmailViewModel(
      appAPIClient: appAPIClient,
      activityReporter: activityReporter,
      completion: completion
    )
  }

}

extension AccountCreationFlowDependenciesContainer {

  internal func makeFastLocalSetupInAccountCreationViewModel(
    biometry: Biometry? = Device.biometryType,
    completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void
  ) -> FastLocalSetupInAccountCreationViewModel {
    return FastLocalSetupInAccountCreationViewModel(
      biometry: biometry,
      completion: completion
    )
  }

}

extension AccountCreationFlowDependenciesContainer {

  internal func makeFastLocalSetupInLoginViewModel(
    masterPassword: String?, biometry: Biometry?, lockService: LockService,
    masterPasswordResetService: ResetMasterPasswordService, userSettings: UserSettings,
    completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
  ) -> FastLocalSetupInLoginViewModel {
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
  internal func makeMasterPasswordAccountCreationFlowViewModel(
    configuration: AccountCreationConfiguration,
    completion: @MainActor @escaping (MasterPasswordAccountCreationFlowViewModel.CompletionResult)
      -> Void
  ) -> MasterPasswordAccountCreationFlowViewModel {
    return MasterPasswordAccountCreationFlowViewModel(
      configuration: configuration,
      activityReporter: activityReporter,
      accountCreationService: accountCreationService,
      userConsentViewModelFactory: InjectedFactory(makeUserConsentViewModel),
      fastLocalSetupViewModelFactory: InjectedFactory(makeFastLocalSetupInAccountCreationViewModel),
      completion: completion
    )
  }

}

extension AccountCreationFlowDependenciesContainer {
  @MainActor
  internal func makePasswordLessAccountCreationFlowViewModel(
    configuration: AccountCreationConfiguration,
    completion: @MainActor @escaping (PasswordLessAccountCreationFlowViewModel.CompletionResult) ->
      Void
  ) -> PasswordLessAccountCreationFlowViewModel {
    return PasswordLessAccountCreationFlowViewModel(
      configuration: configuration,
      accountCreationService: accountCreationService,
      userConsentViewModelFactory: InjectedFactory(makeUserConsentViewModel),
      fastLocalSetupViewModelFactory: InjectedFactory(makeFastLocalSetupInAccountCreationViewModel),
      completion: completion
    )
  }

}

extension AccountCreationFlowDependenciesContainer {
  @MainActor
  internal func makeUserConsentViewModel(
    completion: @escaping (UserConsentViewModel.Completion) -> Void
  ) -> UserConsentViewModel {
    return UserConsentViewModel(
      userCountryProvider: userCountryProvider,
      completion: completion
    )
  }

}

internal protocol AppServicesInjecting {}

extension AppServicesContainer {

  internal func makeLoginKitServicesContainer() -> LoginKitServicesContainer {
    return LoginKitServicesContainer(
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      sessionCleaner: sessionCleaner,
      settingsManager: spiegelSettingsManager,
      keychainService: keychainService,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      sessionContainer: sessionContainer,
      rootLogger: rootLogger,
      nitroClient: nitroClient,
      passwordEvaluator: passwordEvaluator
    )
  }

}

internal protocol MockVaultConnectedInjecting {}

extension MockVaultConnectedContainer {

  internal func makeAddAttachmentButtonViewModel(
    editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AddAttachmentButtonViewModel {
    return AddAttachmentButtonViewModel(
      documentStorageService: documentStorageService,
      activityReporter: activityReporter,
      featureService: featureService,
      editingItem: editingItem,
      capabilityService: capabilityService,
      shouldDisplayRenameAlert: shouldDisplayRenameAlert,
      itemPublisher: itemPublisher
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeAddLoginDetailsViewModel(
    website: String, credential: Credential?, supportDashlane2FA: Bool,
    completion: @escaping (OTPInfo) -> Void
  ) -> AddLoginDetailsViewModel {
    return AddLoginDetailsViewModel(
      website: website,
      credential: credential,
      supportDashlane2FA: supportDashlane2FA,
      completion: completion
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeAddOTPFlowViewModel(
    mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void
  ) -> AddOTPFlowViewModel {
    return AddOTPFlowViewModel(
      activityReporter: activityReporter,
      vaultItemsStore: vaultItemsStore,
      vaultItemDatabase: vaultItemDatabase,
      matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
      addOTPManuallyFlowViewModelFactory: InjectedFactory(makeAddOTPManuallyFlowViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      mode: mode,
      completion: completion
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeAddOTPManuallyFlowViewModel(
    credential: Credential?, completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void
  ) -> AddOTPManuallyFlowViewModel {
    return AddOTPManuallyFlowViewModel(
      credential: credential,
      vaultItemsStore: vaultItemsStore,
      vaultItemDatabase: vaultItemDatabase,
      matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
      chooseWebsiteViewModelFactory: InjectedFactory(makeChooseWebsiteViewModel),
      addLoginDetailsViewModelFactory: InjectedFactory(makeAddLoginDetailsViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      completion: completion
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeAddressDetailViewModel(
    item: Address, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> AddressDetailViewModel {
    return AddressDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      activityLogsService: activityLogsService,
      regionInformationService: regionInformationService,
      userSettings: userSettings,
      documentStorageService: documentStorageService,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      dismiss: dismiss
    )
  }

  internal func makeAddressDetailViewModel(service: DetailService<Address>)
    -> AddressDetailViewModel
  {
    return AddressDetailViewModel(
      service: service,
      regionInformationService: regionInformationService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeAttachmentRowViewModel(
    attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>,
    editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void
  ) -> AttachmentRowViewModel {
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

  internal func makeAttachmentsListViewModel(
    editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AttachmentsListViewModel {
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

  internal func makeAttachmentsSectionViewModel(
    item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AttachmentsSectionViewModel {
    return AttachmentsSectionViewModel(
      item: item,
      documentStorageService: documentStorageService,
      vaultCollectionsStore: vaultCollectionsStore,
      attachmentsListViewModelProvider: makeAttachmentsListViewModel,
      makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
      itemPublisher: itemPublisher
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeBankAccountDetailViewModel(item: BankAccount, mode: DetailMode = .viewing)
    -> BankAccountDetailViewModel
  {
    return BankAccountDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
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

  internal func makeBankAccountDetailViewModel(service: DetailService<BankAccount>)
    -> BankAccountDetailViewModel
  {
    return BankAccountDetailViewModel(
      service: service,
      regionInformationService: regionInformationService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeChooseWebsiteViewModel(completion: @escaping (String) -> Void)
    -> ChooseWebsiteViewModel
  {
    return ChooseWebsiteViewModel(
      categorizer: categorizer,
      activityReporter: activityReporter,
      placeholderViewModelFactory: InjectedFactory(makePlaceholderWebsiteViewModel),
      completion: completion
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeCollectionShareFlowViewModel(
    collection: VaultCollection, userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> CollectionShareFlowViewModel {
    return CollectionShareFlowViewModel(
      collection: collection,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      sharingService: sharingServiceProtocol,
      vaultCollectionDatabase: vaultCollectionDatabase,
      userSpacesService: userSpacesService,
      recipientsViewModelFactory: InjectedFactory(makeShareRecipientsSelectionViewModel)
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeCompanyDetailViewModel(item: Company, mode: DetailMode = .viewing)
    -> CompanyDetailViewModel
  {
    return CompanyDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeCompanyDetailViewModel(service: DetailService<Company>)
    -> CompanyDetailViewModel
  {
    return CompanyDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeCredentialDetailViewModel(
    item: Credential, mode: DetailMode = .viewing,
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil
  ) -> CredentialDetailViewModel {
    return CredentialDetailViewModel(
      item: item,
      session: session,
      mode: mode,
      generatedPasswordToLink: generatedPasswordToLink,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      actionPublisher: actionPublisher,
      origin: origin,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      featureService: featureService,
      iconService: iconService,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      passwordEvaluator: passwordEvaluator,
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
  @MainActor
  internal func makeCredentialDetailViewModel(
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil,
    service: DetailService<Credential>
  ) -> CredentialDetailViewModel {
    return CredentialDetailViewModel(
      generatedPasswordToLink: generatedPasswordToLink,
      actionPublisher: actionPublisher,
      origin: origin,
      featureService: featureService,
      iconService: iconService,
      passwordEvaluator: passwordEvaluator,
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

  internal func makeCredentialMainSectionModel(
    service: DetailService<Credential>, isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>
  ) -> CredentialMainSectionModel {
    return CredentialMainSectionModel(
      service: service,
      isAutoFillDemoModalShown: isAutoFillDemoModalShown,
      isAdd2FAFlowPresented: isAdd2FAFlowPresented,
      passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel)
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeCreditCardDetailViewModel(
    item: CreditCard, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> CreditCardDetailViewModel {
    return CreditCardDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
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

  internal func makeCreditCardDetailViewModel(service: DetailService<CreditCard>)
    -> CreditCardDetailViewModel
  {
    return CreditCardDetailViewModel(
      service: service,
      regionInformationService: regionInformationService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeDomainsSectionModel(service: DetailService<Credential>) -> DomainsSectionModel {
    return DomainsSectionModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeDrivingLicenseDetailViewModel(item: DrivingLicence, mode: DetailMode = .viewing)
    -> DrivingLicenseDetailViewModel
  {
    return DrivingLicenseDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
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

  internal func makeDrivingLicenseDetailViewModel(service: DetailService<DrivingLicence>)
    -> DrivingLicenseDetailViewModel
  {
    return DrivingLicenseDetailViewModel(
      service: service,
      regionInformationService: regionInformationService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeEmailDetailViewModel(item: CorePersonalData.Email, mode: DetailMode = .viewing)
    -> EmailDetailViewModel
  {
    return EmailDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeEmailDetailViewModel(service: DetailService<CorePersonalData.Email>)
    -> EmailDetailViewModel
  {
    return EmailDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeFiscalInformationDetailViewModel(
    item: FiscalInformation, mode: DetailMode = .viewing
  ) -> FiscalInformationDetailViewModel {
    return FiscalInformationDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeFiscalInformationDetailViewModel(service: DetailService<FiscalInformation>)
    -> FiscalInformationDetailViewModel
  {
    return FiscalInformationDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeGravatarIconViewModel(email: String, iconLibrary: GravatarIconLibraryProtocol)
    -> GravatarIconViewModel
  {
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

  internal func makeIDCardDetailViewModel(item: IDCard, mode: DetailMode = .viewing)
    -> IDCardDetailViewModel
  {
    return IDCardDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
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

  internal func makeIdentityDetailViewModel(item: Identity, mode: DetailMode = .viewing)
    -> IdentityDetailViewModel
  {
    return IdentityDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeIdentityDetailViewModel(service: DetailService<Identity>)
    -> IdentityDetailViewModel
  {
    return IdentityDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeMatchingCredentialListViewModel(
    website: String, matchingCredentials: [Credential],
    completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void
  ) -> MatchingCredentialListViewModel {
    return MatchingCredentialListViewModel(
      website: website,
      matchingCredentials: matchingCredentials,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
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
  @MainActor
  internal func makePasskeyDetailViewModel(
    item: CorePersonalData.Passkey, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> PasskeyDetailViewModel {
    return PasskeyDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
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
  @MainActor
  internal func makePasskeyDetailViewModel(service: DetailService<CorePersonalData.Passkey>)
    -> PasskeyDetailViewModel
  {
    return PasskeyDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makePassportDetailViewModel(item: Passport, mode: DetailMode = .viewing)
    -> PassportDetailViewModel
  {
    return PassportDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makePassportDetailViewModel(service: DetailService<Passport>)
    -> PassportDetailViewModel
  {
    return PassportDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makePasswordAccessorySectionModel(service: DetailService<Credential>)
    -> PasswordAccessorySectionModel
  {
    return PasswordAccessorySectionModel(
      service: service,
      passwordEvaluator: passwordEvaluator
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makePasswordGeneratorViewModel(
    mode: PasswordGeneratorMode,
    saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
    savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
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

  internal func makePasswordGeneratorViewModel(
    mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true,
    copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
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

  internal func makePasswordGeneratorViewModel(
    mode: PasswordGeneratorMode, copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
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

  internal func makePasswordHealthSectionModel(service: DetailService<Credential>)
    -> PasswordHealthSectionModel
  {
    return PasswordHealthSectionModel(
      service: service,
      passwordEvaluator: passwordEvaluator,
      identityDashboardService: identityDashboardService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makePhoneDetailViewModel(item: Phone, mode: DetailMode = .viewing)
    -> PhoneDetailViewModel
  {
    return PhoneDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
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
  @MainActor
  internal func makeQuickActionsMenuViewModel(
    item: VaultItem, origin: ActionableVaultItemRowViewModel.Origin, isSuggestedItem: Bool
  ) -> QuickActionsMenuViewModel {
    return QuickActionsMenuViewModel(
      item: item,
      sharingService: sharedVaultHandling,
      accessControl: accessControl,
      vaultItemDatabase: vaultItemDatabase,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      userSpacesService: userSpacesService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel),
      origin: origin,
      pasteboardService: pasteboardService,
      isSuggestedItem: isSuggestedItem
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeSecretDetailViewModel(item: Secret, mode: DetailMode = .viewing)
    -> SecretDetailViewModel
  {
    return SecretDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      documentStorageService: documentStorageService,
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
      pasteboardService: pasteboardService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings
    )
  }

  internal func makeSecretDetailViewModel(service: DetailService<Secret>) -> SecretDetailViewModel {
    return SecretDetailViewModel(
      service: service,
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel)
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeSecureNotesDetailFieldsModel(service: DetailService<SecureNote>)
    -> SecureNotesDetailFieldsModel
  {
    return SecureNotesDetailFieldsModel(
      service: service,
      featureService: featureService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeSecureNotesDetailNavigationBarModel(
    service: DetailService<SecureNote>, isEditingContent: FocusState<Bool>.Binding
  ) -> SecureNotesDetailNavigationBarModel {
    return SecureNotesDetailNavigationBarModel(
      service: service,
      isEditingContent: isEditingContent,
      featureService: featureService
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeSecureNotesDetailToolbarModel(service: DetailService<SecureNote>)
    -> SecureNotesDetailToolbarModel
  {
    return SecureNotesDetailToolbarModel(
      service: service,
      session: session,
      shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel)
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeSecureNotesDetailViewModel(item: SecureNote, mode: DetailMode = .viewing)
    -> SecureNotesDetailViewModel
  {
    return SecureNotesDetailViewModel(
      item: item,
      session: session,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      pasteboardService: pasteboardService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      secureNotesDetailNavigationBarModelFactory: InjectedFactory(
        makeSecureNotesDetailNavigationBarModel),
      secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
      secureNotesDetailToolbarModelFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
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

  internal func makeSecureNotesDetailViewModel(service: DetailService<SecureNote>)
    -> SecureNotesDetailViewModel
  {
    return SecureNotesDetailViewModel(
      session: session,
      service: service,
      secureNotesDetailNavigationBarModelFactory: InjectedFactory(
        makeSecureNotesDetailNavigationBarModel),
      secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
      secureNotesDetailToolbarFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
      sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
      shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel)
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeShareButtonViewModel(
    items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> ShareButtonViewModel {
    return ShareButtonViewModel(
      items: items,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      userSpacesService: userSpacesService,
      shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel)
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeShareFlowViewModel(
    items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> ShareFlowViewModel {
    return ShareFlowViewModel(
      items: items,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      sharingService: sharingServiceProtocol,
      capabilityService: capabilityService,
      itemsViewModelFactory: InjectedFactory(makeShareItemsSelectionViewModel),
      recipientsViewModelFactory: InjectedFactory(makeShareRecipientsSelectionViewModel)
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeShareItemsSelectionViewModel(
    completion: @MainActor @escaping ([VaultItem]) -> Void
  ) -> ShareItemsSelectionViewModel {
    return ShareItemsSelectionViewModel(
      vaultItemsStore: vaultItemsStore,
      userSpacesService: userSpacesService,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      completion: completion
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeShareRecipientsSelectionViewModel(
    configuration: RecipientsConfiguration = .init(), showPermissionLevelSelector: Bool = true,
    showTeamOnly: Bool = false, completion: @MainActor @escaping (RecipientsConfiguration) -> Void
  ) -> ShareRecipientsSelectionViewModel {
    return ShareRecipientsSelectionViewModel(
      session: session,
      configuration: configuration,
      showPermissionLevelSelector: showPermissionLevelSelector,
      showTeamOnly: showTeamOnly,
      sharingService: sharingServiceProtocol,
      premiumStatusProvider: premiumStatusProvider,
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
  internal func makeSharingMembersDetailLinkModel(item: VaultItem) -> SharingMembersDetailLinkModel
  {
    return SharingMembersDetailLinkModel(
      item: item,
      sharingService: sharingServiceProtocol,
      detailViewModelFactory: InjectedFactory(makeSharingMembersDetailViewModel)
    )
  }

}

extension MockVaultConnectedContainer {
  @MainActor
  internal func makeSharingMembersDetailViewModel(members: ItemSharingMembers, item: VaultItem)
    -> SharingMembersDetailViewModel
  {
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

  internal func makeSocialSecurityDetailViewModel(
    item: SocialSecurityInformation, mode: DetailMode = .viewing
  ) -> SocialSecurityDetailViewModel {
    return SocialSecurityDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeSocialSecurityDetailViewModel(service: DetailService<SocialSecurityInformation>)
    -> SocialSecurityDetailViewModel
  {
    return SocialSecurityDetailViewModel(
      service: service
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeVaultCollectionEditionService(collection: VaultCollection)
    -> VaultCollectionEditionService
  {
    return VaultCollectionEditionService(
      collection: collection,
      logger: logger,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharingServiceProtocol
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeVaultItemIconViewModel(item: VaultItem) -> VaultItemIconViewModel {
    return VaultItemIconViewModel(
      item: item,
      domainIconLibrary: domainIconLibrary
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeVaultItemRow(item: VaultItem, userSpace: UserSpace?) -> VaultItemRow {
    return VaultItemRow(
      item: item,
      userSpace: userSpace,
      vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel)
    )
  }

}

extension MockVaultConnectedContainer {

  internal func makeWebsiteDetailViewModel(item: PersonalWebsite, mode: DetailMode = .viewing)
    -> WebsiteDetailViewModel
  {
    return WebsiteDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemsStore: vaultItemsStore,
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      sharingService: sharedVaultHandling,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: logger,
      accessControl: accessControl,
      userSettings: userSettings,
      pasteboardService: pasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeWebsiteDetailViewModel(service: DetailService<PersonalWebsite>)
    -> WebsiteDetailViewModel
  {
    return WebsiteDetailViewModel(
      service: service
    )
  }

}

internal protocol SessionServicesInjecting {}

extension SessionServicesContainer {
  @MainActor
  internal func makeAccountRecoveryActivationEmbeddedFlowModel(
    context: AccountRecoveryActivationContext, completion: @MainActor @escaping () -> Void
  ) -> AccountRecoveryActivationEmbeddedFlowModel {
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
  internal func makeAccountRecoveryActivationFlowModel(context: AccountRecoveryActivationContext)
    -> AccountRecoveryActivationFlowModel
  {
    return AccountRecoveryActivationFlowModel(
      context: context,
      activityReporter: activityReporter,
      recoveryActivationViewModelFactory: InjectedFactory(
        makeAccountRecoveryActivationEmbeddedFlowModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeAccountRecoveryKeyDisabledAlertViewModel(
    authenticationMethod: AuthenticationMethod
  ) -> AccountRecoveryKeyDisabledAlertViewModel {
    return AccountRecoveryKeyDisabledAlertViewModel(
      authenticationMethod: authenticationMethod,
      deeplinkService: appServices.deepLinkingService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAccountRecoveryKeyStatusDetailViewModel(isEnabled: Bool)
    -> AccountRecoveryKeyStatusDetailViewModel
  {
    return AccountRecoveryKeyStatusDetailViewModel(
      isEnabled: isEnabled,
      session: session,
      accountRecoveryKeyService: accountRecoveryKeyService,
      accountRecoveryActivationFlowModelFactory: InjectedFactory(
        makeAccountRecoveryActivationFlowModel),
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
      recoveryKeyStatusDetailViewModelFactory: InjectedFactory(
        makeAccountRecoveryKeyStatusDetailViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeAccountSummaryViewModel() -> AccountSummaryViewModel {
    return AccountSummaryViewModel(
      session: session,
      userDeviceAPI: userDeviceAPIClient,
      accessControl: vaultKitAccessControl,
      changeContactEmailViewModelFactory: InjectedFactory(makeChangeContactEmailViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeActionableVaultItemRowViewModel(
    item: VaultItem, isSuggested: Bool, origin: ActionableVaultItemRowViewModel.Origin
  ) -> ActionableVaultItemRowViewModel {
    return ActionableVaultItemRowViewModel(
      item: item,
      isSuggested: isSuggested,
      origin: origin,
      quickActionsMenuViewModelFactory: InjectedFactory(makeQuickActionsMenuViewModel),
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      accessControl: vaultKitAccessControl,
      pasteboardService: vaultKitPasteboardService,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      sharingPermissionProvider: vaultKitSharingServiceHandler,
      activityReporter: activityReporter,
      userSpacesService: userSpacesService
    )
  }

}

extension SessionServicesContainer {

  internal func makeAddAttachmentButtonViewModel(
    editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AddAttachmentButtonViewModel {
    return AddAttachmentButtonViewModel(
      documentStorageService: documentStorageService,
      activityReporter: activityReporter,
      featureService: featureService,
      editingItem: editingItem,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      shouldDisplayRenameAlert: shouldDisplayRenameAlert,
      itemPublisher: itemPublisher
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAddItemFlowViewModel(
    displayMode: AddItemFlowViewModel.DisplayMode,
    completion: @escaping (AddItemFlowViewModel.Completion) -> Void
  ) -> AddItemFlowViewModel {
    return AddItemFlowViewModel(
      displayMode: displayMode,
      completion: completion,
      detailViewModelFactory: InjectedFactory(makeVaultDetailViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      addPrefilledCredentialViewModelFactory: InjectedFactory(makeAddPrefilledCredentialViewModel),
      autofillOnboardingFlowViewModelFactory: InjectedFactory(makeAutofillOnboardingFlowViewModel),
      sessionServices: self
    )
  }

}

extension SessionServicesContainer {

  internal func makeAddLoginDetailsViewModel(
    website: String, credential: Credential?, supportDashlane2FA: Bool,
    completion: @escaping (OTPInfo) -> Void
  ) -> AddLoginDetailsViewModel {
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
  internal func makeAddNewDeviceViewModel(qrCodeViaSystemCamera: String? = nil)
    -> AddNewDeviceViewModel
  {
    return AddNewDeviceViewModel(
      session: session,
      apiClient: userDeviceAPIClient,
      activityReporter: activityReporter,
      sessionCryptoEngineProvider: appServices.sessionCryptoEngineProvider,
      securityChallengeFlowModelFactory: InjectedFactory(makeSecurityChallengeFlowModel),
      qrCodeViaSystemCamera: qrCodeViaSystemCamera
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAddOTPFlowViewModel(
    mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void
  ) -> AddOTPFlowViewModel {
    return AddOTPFlowViewModel(
      activityReporter: activityReporter,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
      addOTPManuallyFlowViewModelFactory: InjectedFactory(makeAddOTPManuallyFlowViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      mode: mode,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAddOTPManuallyFlowViewModel(
    credential: Credential?, completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void
  ) -> AddOTPManuallyFlowViewModel {
    return AddOTPManuallyFlowViewModel(
      credential: credential,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      matchingCredentialListViewModelFactory: InjectedFactory(makeMatchingCredentialListViewModel),
      chooseWebsiteViewModelFactory: InjectedFactory(makeChooseWebsiteViewModel),
      addLoginDetailsViewModelFactory: InjectedFactory(makeAddLoginDetailsViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeAddPrefilledCredentialViewModel(
    didChooseCredential: @escaping (Credential, Bool) -> Void
  ) -> AddPrefilledCredentialViewModel {
    return AddPrefilledCredentialViewModel(
      iconViewModelProvider: makeVaultItemIconViewModel,
      session: session,
      categorizer: appServices.categorizer,
      personalDataURLDecoder: personalDataURLDecoder,
      prefilledCredentialsProvider: vaultServicesSuit.prefilledCredentialsProvider,
      didChooseCredential: didChooseCredential
    )
  }

}

extension SessionServicesContainer {

  internal func makeAddressDetailViewModel(
    item: Address, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> AddressDetailViewModel {
    return AddressDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      activityLogsService: activityLogsService,
      regionInformationService: appServices.regionInformationService,
      userSettings: vaultKitUserSettings,
      documentStorageService: documentStorageService,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      dismiss: dismiss
    )
  }

  internal func makeAddressDetailViewModel(service: DetailService<Address>)
    -> AddressDetailViewModel
  {
    return AddressDetailViewModel(
      service: service,
      regionInformationService: appServices.regionInformationService
    )
  }

}

extension SessionServicesContainer {

  internal func makeAttachmentRowViewModel(
    attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>,
    editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void
  ) -> AttachmentRowViewModel {
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

  internal func makeAttachmentsListViewModel(
    editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AttachmentsListViewModel {
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

  internal func makeAttachmentsSectionViewModel(
    item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AttachmentsSectionViewModel {
    return AttachmentsSectionViewModel(
      item: item,
      documentStorageService: documentStorageService,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      attachmentsListViewModelProvider: makeAttachmentsListViewModel,
      makeAddAttachmentButtonViewModel: InjectedFactory(makeAddAttachmentButtonViewModel),
      itemPublisher: itemPublisher
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAuthenticatorToolFlowViewModel() -> AuthenticatorToolFlowViewModel {
    return AuthenticatorToolFlowViewModel(
      activityReporter: activityReporter,
      deepLinkingService: appServices.deepLinkingService,
      otpDatabaseService: otpDatabaseService,
      iconService: iconService,
      otpExplorerViewModelFactory: InjectedFactory(makeOTPExplorerViewModel),
      otpTokenListViewModelFactory: InjectedFactory(makeOTPTokenListViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      addOTPFlowViewModelFactory: InjectedFactory(makeAddOTPFlowViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeBankAccountDetailViewModel(item: BankAccount, mode: DetailMode = .viewing)
    -> BankAccountDetailViewModel
  {
    return BankAccountDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      regionInformationService: appServices.regionInformationService,
      userSettings: vaultKitUserSettings,
      documentStorageService: documentStorageService,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeBankAccountDetailViewModel(service: DetailService<BankAccount>)
    -> BankAccountDetailViewModel
  {
    return BankAccountDetailViewModel(
      service: service,
      regionInformationService: appServices.regionInformationService
    )
  }

}

extension SessionServicesContainer {

  internal func makeBreachViewModel(
    hasBeenAddressed: Bool, url: PersonalDataURL, leakedPassword: String?, leakDate: Date?,
    email: String? = nil, otherLeakedData: [String]? = nil,
    simplifiedBreach: DWMSimplifiedBreach? = nil
  ) -> BreachViewModel {
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
  @MainActor
  internal func makeChangeContactEmailViewModel(
    currentContactEmail: String, onSaveAction: @escaping () -> Void
  ) -> ChangeContactEmailViewModel {
    return ChangeContactEmailViewModel(
      userDeviceAPI: userDeviceAPIClient,
      accessControl: vaultKitAccessControl,
      logger: appServices.rootLogger,
      currentContactEmail: currentContactEmail,
      onSaveAction: onSaveAction
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeChangeMasterPasswordFlowViewModel() -> ChangeMasterPasswordFlowViewModel {
    return ChangeMasterPasswordFlowViewModel(
      session: session,
      sessionsContainer: appServices.sessionContainer,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      passwordEvaluator: appServices.passwordEvaluator,
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

  internal func makeChooseWebsiteViewModel(completion: @escaping (String) -> Void)
    -> ChooseWebsiteViewModel
  {
    return ChooseWebsiteViewModel(
      categorizer: appServices.categorizer,
      activityReporter: activityReporter,
      placeholderViewModelFactory: InjectedFactory(makePlaceholderWebsiteViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeCollectionDetailViewModel(collection: VaultCollection)
    -> CollectionDetailViewModel
  {
    return CollectionDetailViewModel(
      collection: collection,
      logger: appServices.rootLogger,
      featureService: featureService,
      activityReporter: activityReporter,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      userSpacesService: userSpacesService,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      collectionQuickActionsMenuViewModelFactory: InjectedFactory(
        makeCollectionQuickActionsMenuViewModel),
      rowModelFactory: InjectedFactory(makeActionableVaultItemRowViewModel),
      vaultCollectionEditionServiceFactory: InjectedFactory(makeVaultCollectionEditionService)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeCollectionShareFlowViewModel(
    collection: VaultCollection, userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> CollectionShareFlowViewModel {
    return CollectionShareFlowViewModel(
      collection: collection,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      sharingService: vaultKitSharingService,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      userSpacesService: userSpacesService,
      recipientsViewModelFactory: InjectedFactory(makeShareRecipientsSelectionViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeCollectionsFlowViewModel(initialStep: CollectionsFlowViewModel.Step = .list)
    -> CollectionsFlowViewModel
  {
    return CollectionsFlowViewModel(
      initialStep: initialStep,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      database: database,
      detailViewModelFactory: InjectedFactory(makeVaultDetailViewModel),
      collectionsListViewModelFactory: InjectedFactory(makeCollectionsListViewModel),
      collectionDetailViewModelFactory: InjectedFactory(makeCollectionDetailViewModel),
      collectionShareFlowViewModelFactory: InjectedFactory(makeCollectionShareFlowViewModel),
      sharingCollectionMembersViewModelFactory: InjectedFactory(
        makeSharingCollectionMembersDetailViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeCompanyDetailViewModel(item: Company, mode: DetailMode = .viewing)
    -> CompanyDetailViewModel
  {
    return CompanyDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeCompanyDetailViewModel(service: DetailService<Company>)
    -> CompanyDetailViewModel
  {
    return CompanyDetailViewModel(
      service: service
    )
  }

}

extension SessionServicesContainer {

  internal func makeConnectedEnvironmentModel() -> ConnectedEnvironmentModel {
    return ConnectedEnvironmentModel(
      featureService: featureService,
      userSpaceService: userSpacesService,
      capabilitiesService: premiumStatusServicesSuit.capabilityService,
      activityReportProtocol: activityReporter,
      syncedSettings: syncedSettings
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeConnectedIpadMacRootViewModel() -> ConnectedIpadMacRootViewModel {
    return ConnectedIpadMacRootViewModel(
      deepLinkingService: appServices.deepLinkingService,
      sidebarViewModelFactory: InjectedFactory(makeSidebarViewModel),
      homeFlowViewModelFactory: InjectedFactory(makeHomeFlowViewModel),
      notificationViewModelFactory: InjectedFactory(makeNotificationsFlowViewModel),
      vaultFlowModelFactory: InjectedFactory(makeVaultFlowViewModel),
      collectionFlowModelFactory: InjectedFactory(makeCollectionsFlowViewModel),
      toolsFlowViewModelFactory: InjectedFactory(makeToolsFlowViewModel),
      settingsFlowViewModelFactory: InjectedFactory(makeSettingsFlowViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeConnectedIphoneRootViewModel() -> ConnectedIphoneRootViewModel {
    return ConnectedIphoneRootViewModel(
      deepLinkingService: appServices.deepLinkingService,
      homeFlowViewModelFactory: InjectedFactory(makeHomeFlowViewModel),
      notificationViewModelFactory: InjectedFactory(makeNotificationsFlowViewModel),
      passwordGeneratorToolsFlowViewModelFactory: InjectedFactory(
        makePasswordGeneratorToolsFlowViewModel),
      toolsFlowViewModelFactory: InjectedFactory(makeToolsFlowViewModel),
      settingsFlowViewModelFactory: InjectedFactory(makeSettingsFlowViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeConnectedRootViewModel() -> ConnectedRootViewModel {
    return ConnectedRootViewModel(
      iphoneRootViewModelFactory: InjectedFactory(makeConnectedIphoneRootViewModel),
      ipadMacRootViewModelFactory: InjectedFactory(makeConnectedIpadMacRootViewModel),
      connectedEnvironmentModelFactory: InjectedFactory(makeConnectedEnvironmentModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeCredentialDetailViewModel(
    item: Credential, mode: DetailMode = .viewing,
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil
  ) -> CredentialDetailViewModel {
    return CredentialDetailViewModel(
      item: item,
      session: session,
      mode: mode,
      generatedPasswordToLink: generatedPasswordToLink,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      actionPublisher: actionPublisher,
      origin: origin,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      featureService: featureService,
      iconService: iconService,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      passwordEvaluator: appServices.passwordEvaluator,
      onboardingService: onboardingService,
      autofillService: autofillService,
      documentStorageService: documentStorageService,
      pasteboardService: vaultKitPasteboardService,
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
  @MainActor
  internal func makeCredentialDetailViewModel(
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil,
    service: DetailService<Credential>
  ) -> CredentialDetailViewModel {
    return CredentialDetailViewModel(
      generatedPasswordToLink: generatedPasswordToLink,
      actionPublisher: actionPublisher,
      origin: origin,
      featureService: featureService,
      iconService: iconService,
      passwordEvaluator: appServices.passwordEvaluator,
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

  internal func makeCredentialMainSectionModel(
    service: DetailService<Credential>, isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>
  ) -> CredentialMainSectionModel {
    return CredentialMainSectionModel(
      service: service,
      isAutoFillDemoModalShown: isAutoFillDemoModalShown,
      isAdd2FAFlowPresented: isAdd2FAFlowPresented,
      passwordAccessorySectionModelFactory: InjectedFactory(makePasswordAccessorySectionModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeCreditCardDetailViewModel(
    item: CreditCard, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> CreditCardDetailViewModel {
    return CreditCardDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      regionInformationService: appServices.regionInformationService,
      userSettings: vaultKitUserSettings,
      documentStorageService: documentStorageService,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      dismiss: dismiss
    )
  }

  internal func makeCreditCardDetailViewModel(service: DetailService<CreditCard>)
    -> CreditCardDetailViewModel
  {
    return CreditCardDetailViewModel(
      service: service,
      regionInformationService: appServices.regionInformationService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeDWMEmailConfirmationViewModel(
    accountEmail: String, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy
  ) -> DWMEmailConfirmationViewModel {
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
  internal func makeDWMOnboardingFlowViewModel(
    transitionHandler: GuidedOnboardingTransitionHandler?,
    completion: @escaping (DWMOnboardingFlowViewModel.Completion) -> Void
  ) -> DWMOnboardingFlowViewModel {
    return DWMOnboardingFlowViewModel(
      transitionHandler: transitionHandler,
      session: session,
      dwmOnboardingSettings: dwmOnboardingSettings,
      registrationInGuidedOnboardingVModelFactory: InjectedFactory(
        makeDWMRegistrationInGuidedOnboardingViewModel),
      emailConfirmationViewModelFactory: InjectedFactory(makeDWMEmailConfirmationViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeDWMRegistrationInGuidedOnboardingViewModel(email: String)
    -> DWMRegistrationInGuidedOnboardingViewModel
  {
    return DWMRegistrationInGuidedOnboardingViewModel(
      email: email,
      dwmOnboardingService: dwmOnboardingService,
      userSettings: vaultKitUserSettings
    )
  }

}

extension SessionServicesContainer {

  internal func makeDarkWebMonitoringBreachListViewModel(
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?
  ) -> DarkWebMonitoringBreachListViewModel {
    return DarkWebMonitoringBreachListViewModel(
      darkWebMonitoringService: darkWebMonitoringService,
      activityReporter: activityReporter,
      actionPublisher: actionPublisher,
      breachRowProvider: makeBreachViewModel
    )
  }

}

extension SessionServicesContainer {

  internal func makeDarkWebMonitoringDetailsViewModel(
    breach: DWMSimplifiedBreach, breachViewModel: BreachViewModel,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil
  ) -> DarkWebMonitoringDetailsViewModel {
    return DarkWebMonitoringDetailsViewModel(
      breach: breach,
      breachViewModel: breachViewModel,
      darkWebMonitoringService: darkWebMonitoringService,
      domainParser: domainParser,
      userSettings: vaultKitUserSettings,
      actionPublisher: actionPublisher
    )
  }

}

extension SessionServicesContainer {

  internal func makeDarkWebMonitoringEmailRowViewModel(
    email: DataLeakEmail,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  ) -> DarkWebMonitoringEmailRowViewModel {
    return DarkWebMonitoringEmailRowViewModel(
      email: email,
      iconService: iconService,
      actionPublisher: actionPublisher
    )
  }

}

extension SessionServicesContainer {

  internal func makeDarkWebMonitoringMonitoredEmailsViewModel(
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  ) -> DarkWebMonitoringMonitoredEmailsViewModel {
    return DarkWebMonitoringMonitoredEmailsViewModel(
      darkWebMonitoringService: darkWebMonitoringService,
      iconService: iconService,
      actionPublisher: actionPublisher
    )
  }

}

extension SessionServicesContainer {

  internal func makeDarkWebMonitoringViewModel(
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never> = .init()
  ) -> DarkWebMonitoringViewModel {
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
      userSettings: vaultKitUserSettings,
      darkWebMonitoringService: darkWebMonitoringService,
      deepLinkingService: appServices.deepLinkingService,
      darkWebMonitoringViewModelFactory: InjectedFactory(makeDarkWebMonitoringViewModel),
      dataLeakMonitoringAddEmailViewModelFactory: InjectedFactory(
        makeDataLeakMonitoringAddEmailViewModel),
      darkWebMonitoringDetailsViewModelFactory: InjectedFactory(
        makeDarkWebMonitoringDetailsViewModel),
      breachViewModelFactory: InjectedFactory(makeBreachViewModel),
      userDeviceAPIClient: userDeviceAPIClient,
      notificationService: notificationService,
      identityDashboardService: identityDashboardService,
      logger: appServices.rootLogger,
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeDataLeakMonitoringAddEmailViewModel(
    login: Login, dataLeakService: DataLeakMonitoringRegisterServiceProtocol
  ) -> DataLeakMonitoringAddEmailViewModel {
    return DataLeakMonitoringAddEmailViewModel(
      login: login,
      dataLeakService: dataLeakService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeDeviceListViewModel() -> DeviceListViewModel {
    return DeviceListViewModel(
      userDeviceAPIClient: userDeviceAPIClient,
      session: session,
      reachability: appServices.networkReachability,
      logoutHandler: appServices.sessionLifeCycleHandler
    )
  }
  @MainActor
  internal func makeDeviceListViewModel(currentDeviceId: String) -> DeviceListViewModel {
    return DeviceListViewModel(
      userDeviceAPIClient: userDeviceAPIClient,
      currentDeviceId: currentDeviceId,
      reachability: appServices.networkReachability
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeDeviceTransferPendingRequestViewModel(
    login: String, pendingTransfer: PendingTransfer,
    senderSecurityChallengeService: SenderSecurityChallengeService,
    completion: @escaping (DeviceTransferPendingRequestViewModel.CompletionType) -> Void
  ) -> DeviceTransferPendingRequestViewModel {
    return DeviceTransferPendingRequestViewModel(
      login: login,
      pendingTransfer: pendingTransfer,
      senderSecurityChallengeService: senderSecurityChallengeService,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeDomainsSectionModel(service: DetailService<Credential>) -> DomainsSectionModel {
    return DomainsSectionModel(
      service: service
    )
  }

}

extension SessionServicesContainer {

  internal func makeDrivingLicenseDetailViewModel(item: DrivingLicence, mode: DetailMode = .viewing)
    -> DrivingLicenseDetailViewModel
  {
    return DrivingLicenseDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      regionInformationService: appServices.regionInformationService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      documentStorageService: documentStorageService,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeDrivingLicenseDetailViewModel(service: DetailService<DrivingLicence>)
    -> DrivingLicenseDetailViewModel
  {
    return DrivingLicenseDetailViewModel(
      service: service,
      regionInformationService: appServices.regionInformationService
    )
  }

}

extension SessionServicesContainer {

  internal func makeEmailDetailViewModel(item: CorePersonalData.Email, mode: DetailMode = .viewing)
    -> EmailDetailViewModel
  {
    return EmailDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeEmailDetailViewModel(service: DetailService<CorePersonalData.Email>)
    -> EmailDetailViewModel
  {
    return EmailDetailViewModel(
      service: service
    )
  }

}

extension SessionServicesContainer {

  internal func makeExportSecureArchiveViewModel(onlyExportPersonalSpace: Bool = false)
    -> ExportSecureArchiveViewModel
  {
    return ExportSecureArchiveViewModel(
      databaseDriver: databaseDriver,
      reporter: activityReporter,
      userSpacesService: userSpacesService,
      onlyExportPersonalSpace: onlyExportPersonalSpace,
      evaluator: appServices.passwordEvaluator
    )
  }

}

extension SessionServicesContainer {

  internal func makeFastLocalSetupInLoginViewModel(
    masterPassword: String?, biometry: Biometry?,
    completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
  ) -> FastLocalSetupInLoginViewModel {
    return FastLocalSetupInLoginViewModel(
      masterPassword: masterPassword,
      biometry: biometry,
      lockService: lockService,
      masterPasswordResetService: resetMasterPasswordService,
      userSettings: vaultKitUserSettings,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeFiscalInformationDetailViewModel(
    item: FiscalInformation, mode: DetailMode = .viewing
  ) -> FiscalInformationDetailViewModel {
    return FiscalInformationDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeFiscalInformationDetailViewModel(service: DetailService<FiscalInformation>)
    -> FiscalInformationDetailViewModel
  {
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
      userSettings: vaultKitUserSettings,
      secureArchiveSectionContentViewModelFactory: InjectedFactory(
        makeSecureArchiveSectionContentViewModel),
      dashImportFlowViewModelFactory: InjectedFactory(makeDashImportFlowViewModel),
      duplicateItemsViewModelFactory: InjectedFactory(makeDuplicateItemsViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeGravatarIconViewModel(email: String, iconLibrary: GravatarIconLibraryProtocol)
    -> GravatarIconViewModel
  {
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

  internal func makeGuidedOnboardingFlowViewModel(
    navigator: DashlaneNavigationController? = nil, completion: @escaping () -> Void
  ) -> GuidedOnboardingFlowViewModel {
    return GuidedOnboardingFlowViewModel(
      navigator: navigator,
      sessionServices: self,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeGuidedOnboardingViewModel(
    guidedOnboardingService: GuidedOnboardingService, step: GuidedOnboardingSurveyStep,
    completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
  ) -> GuidedOnboardingViewModel {
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
    return HelpCenterSettingsViewModel()
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeHomeBottomBannerViewModel(
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
  ) -> HomeBottomBannerViewModel {
    return HomeBottomBannerViewModel(
      userSettings: vaultKitUserSettings,
      deepLinkingService: appServices.deepLinkingService,
      autofillService: autofillService,
      action: action,
      onboardingChecklistViewModelFactory: InjectedFactory(makeOnboardingChecklistViewModel),
      onboardingAction: onboardingAction
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeHomeFlowViewModel() -> HomeFlowViewModel {
    return HomeFlowViewModel(
      sessionServices: self,
      userSettings: vaultKitUserSettings,
      onboardingService: onboardingService,
      featureService: featureService,
      lockService: lockService,
      deeplinkService: appServices.deepLinkingService,
      homeModalAnnouncementsViewModelFactory: InjectedFactory(makeHomeModalAnnouncementsViewModel),
      lastpassImportFlowViewModelFactory: InjectedFactory(makeLastpassImportFlowViewModel),
      vaultFlowViewModelFactory: InjectedFactory(makeVaultFlowViewModel),
      onboardingChecklistFlowViewModel: InjectedFactory(makeOnboardingChecklistFlowViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeHomeListViewModel(
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> HomeListViewModel {
    return HomeListViewModel(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      userSettings: vaultKitUserSettings,
      autofillService: autofillService,
      lockService: lockService,
      onboardingAction: onboardingAction,
      action: action,
      vaultItemsListFactory: InjectedFactory(makeVaultItemsListViewModel),
      homeBottomBannerFactory: InjectedFactory(makeHomeBottomBannerViewModel),
      homeTopBannerFactory: InjectedFactory(makeHomeTopBannerViewModel),
      lastpassDetector: lastpassDetector,
      sessionActivityReporter: activityReporter,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeHomeViewModel(
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void
  ) -> HomeViewModel {
    return HomeViewModel(
      onboardingAction: onboardingAction,
      action: action,
      homeListViewModelFactory: InjectedFactory(makeHomeListViewModel),
      searchFactory: InjectedFactory(makeVaultSearchViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeIDCardDetailViewModel(item: IDCard, mode: DetailMode = .viewing)
    -> IDCardDetailViewModel
  {
    return IDCardDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
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

  internal func makeIdentityBreachAlertViewModel(breachesToPresent: [PopupAlertProtocol])
    -> IdentityBreachAlertViewModel
  {
    return IdentityBreachAlertViewModel(
      breachesToPresent: breachesToPresent,
      identityDashboardService: identityDashboardService,
      deepLinkingService: appServices.deepLinkingService,
      featureService: featureService
    )
  }

}

extension SessionServicesContainer {

  internal func makeIdentityDetailViewModel(item: Identity, mode: DetailMode = .viewing)
    -> IdentityDetailViewModel
  {
    return IdentityDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeIdentityDetailViewModel(service: DetailService<Identity>)
    -> IdentityDetailViewModel
  {
    return IdentityDetailViewModel(
      service: service
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeImportMethodFlowViewModel(
    mode: ImportMethodMode, completion: @escaping (ImportMethodFlowViewModel.Completion) -> Void
  ) -> ImportMethodFlowViewModel {
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

  internal func makeImportMethodViewModel(
    importService: ImportMethodServiceProtocol,
    completion: @escaping (ImportMethodCompletion) -> Void
  ) -> ImportMethodViewModel {
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
  @MainActor
  internal func makeLabsSettingsViewModel() -> LabsSettingsViewModel {
    return LabsSettingsViewModel(
      featureService: featureService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeLockViewModel(
    locker: ScreenLocker, newMasterPassword: String? = nil,
    changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher
  ) -> LockViewModel {
    return LockViewModel(
      locker: locker,
      session: session,
      appServices: appServices,
      appAPIClient: appServices.appAPIClient,
      userDeviceAPIClient: userDeviceAPIClient,
      nitroClient: appServices.nitroClient,
      keychainService: appServices.keychainService,
      userSettings: vaultKitUserSettings,
      resetMasterPasswordService: resetMasterPasswordService,
      activityReporter: activityReporter,
      userSpacesService: userSpacesService,
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
      postARKChangeMasterPasswordViewModelFactory: InjectedFactory(
        makePostARKChangeMasterPasswordViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeM2WSettings() -> M2WSettings {
    return M2WSettings(
      userSettings: vaultKitUserSettings
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeMainSettingsViewModel() -> MainSettingsViewModel {
    return MainSettingsViewModel(
      session: session,
      sessionCryptoEngineProvider: appServices.sessionCryptoEngineProvider,
      lockService: lockService,
      userSettings: vaultKitUserSettings,
      featureService: featureService,
      userDeviceAPIClient: userDeviceAPIClient,
      appAPIClient: appServices.appAPIClient,
      settingsStatusSectionViewModelFactory: InjectedFactory(makeSettingsStatusSectionViewModel),
      accountSummaryViewModelFactory: InjectedFactory(makeAccountSummaryViewModel),
      addNewDeviceFactory: InjectedFactory(makeAddNewDeviceViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeMasterPasswordResetActivationViewModel(
    masterPassword: String,
    actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
  ) -> MasterPasswordResetActivationViewModel {
    return MasterPasswordResetActivationViewModel(
      masterPassword: masterPassword,
      resetMasterPasswordService: resetMasterPasswordService,
      lockService: lockService,
      actionHandler: actionHandler
    )
  }

}

extension SessionServicesContainer {

  internal func makeMatchingCredentialListViewModel(
    website: String, matchingCredentials: [Credential],
    completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void
  ) -> MatchingCredentialListViewModel {
    return MatchingCredentialListViewModel(
      website: website,
      matchingCredentials: matchingCredentials,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeMigrationProgressViewModel(
    type: MigrationType, accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    context: MigrationProgressViewModel.Context, isProgress: Bool = true, isSuccess: Bool = true,
    completion: @escaping (Result<Session, Error>) -> Void
  ) -> MigrationProgressViewModel {
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
      userSettings: vaultKitUserSettings,
      lockService: lockService,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      identityDashboardService: identityDashboardService,
      resetMasterPasswordService: resetMasterPasswordService,
      sharingService: vaultKitSharingService,
      userSpacesService: userSpacesService,
      abtestService: authenticatedABTestingService,
      keychainService: appServices.keychainService,
      featureService: featureService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeNotificationsFlowViewModel() -> NotificationsFlowViewModel {
    return NotificationsFlowViewModel(
      notificationCenterService: InjectedFactory(makeNotificationCenterService),
      deeplinkService: appServices.deepLinkingService,
      notificationsListViewModelFactory: InjectedFactory(makeNotificationsListViewModel)
    )
  }
  @MainActor
  internal func makeNotificationsFlowViewModel(
    notificationCenterService: NotificationCenterServiceProtocol
  ) -> NotificationsFlowViewModel {
    return NotificationsFlowViewModel(
      notificationCenterService: notificationCenterService,
      deeplinkService: appServices.deepLinkingService,
      notificationsListViewModelFactory: InjectedFactory(makeNotificationsListViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeNotificationsListViewModel(
    notificationCenterService: NotificationCenterServiceProtocol
  ) -> NotificationsListViewModel {
    return NotificationsListViewModel(
      session: session,
      settings: spiegelLocalSettingsStore,
      deeplinkService: appServices.deepLinkingService,
      userSettings: vaultKitUserSettings,
      resetMasterPasswordService: resetMasterPasswordService,
      lockService: lockService,
      userSpacesService: userSpacesService,
      abtestService: authenticatedABTestingService,
      keychainService: appServices.keychainService,
      featureService: featureService,
      notificationCenterService: notificationCenterService,
      identityDashboardService: identityDashboardService,
      resetMasterPasswordNotificationFactory: makeResetMasterPasswordNotificationRowViewModel,
      trialPeriodNotificationFactory: makeTrialPeriodNotificationRowViewModel,
      secureLockNotificationFactory: makeSecureLockNotificationRowViewModel,
      sharingItemNotificationFactory: makeSharingRequestNotificationRowViewModel,
      securityAlertNotificationFactory: makeSecurityAlertNotificationRowViewModel
    )
  }

}

extension SessionServicesContainer {

  internal func makeOTPExplorerViewModel(
    otpSupportedDomainsRepository: OTPSupportedDomainsRepository,
    actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void
  ) -> OTPExplorerViewModel {
    return OTPExplorerViewModel(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      otpSupportedDomainsRepository: otpSupportedDomainsRepository,
      rowModelFactory: InjectedFactory(makeActionableVaultItemRowViewModel),
      actionHandler: actionHandler
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeOTPTokenListViewModel(
    actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void
  ) -> OTPTokenListViewModel {
    return OTPTokenListViewModel(
      activityReporter: activityReporter,
      authenticatorDatabaseService: otpDatabaseService,
      domainParser: domainParser,
      domainIconLibrary: domainIconLibrary,
      actionHandler: actionHandler
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeOnboardingChecklistFlowViewModel(
    displayMode: OnboardingChecklistFlowViewModel.DisplayMode,
    onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil,
    completion: @escaping (OnboardingChecklistFlowViewModel.Completion) -> Void
  ) -> OnboardingChecklistFlowViewModel {
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
  @MainActor
  internal func makeOnboardingChecklistViewModel(
    action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
  ) -> OnboardingChecklistViewModel {
    return OnboardingChecklistViewModel(
      session: session,
      userSettings: vaultKitUserSettings,
      dwmOnboardingSettings: dwmOnboardingSettings,
      dwmOnboardingService: dwmOnboardingService,
      capabilityService: premiumStatusServicesSuit.capabilityService,
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
  @MainActor
  internal func makePasskeyDetailViewModel(
    item: CorePersonalData.Passkey, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> PasskeyDetailViewModel {
    return PasskeyDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      documentStorageService: documentStorageService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      dismiss: dismiss
    )
  }
  @MainActor
  internal func makePasskeyDetailViewModel(service: DetailService<CorePersonalData.Passkey>)
    -> PasskeyDetailViewModel
  {
    return PasskeyDetailViewModel(
      service: service
    )
  }

}

extension SessionServicesContainer {

  internal func makePassportDetailViewModel(item: Passport, mode: DetailMode = .viewing)
    -> PassportDetailViewModel
  {
    return PassportDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makePassportDetailViewModel(service: DetailService<Passport>)
    -> PassportDetailViewModel
  {
    return PassportDetailViewModel(
      service: service
    )
  }

}

extension SessionServicesContainer {

  internal func makePasswordAccessorySectionModel(service: DetailService<Credential>)
    -> PasswordAccessorySectionModel
  {
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
      userSettings: vaultKitUserSettings,
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
      pasteboardService: vaultKitPasteboardService,
      passwordGeneratorViewModelFactory: InjectedFactory(makePasswordGeneratorViewModel),
      passwordGeneratorHistoryViewModelFactory: InjectedFactory(
        makePasswordGeneratorHistoryViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makePasswordGeneratorViewModel(
    mode: PasswordGeneratorMode,
    saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
    savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
    return PasswordGeneratorViewModel(
      mode: mode,
      saveGeneratedPassword: saveGeneratedPassword,
      passwordEvaluator: appServices.passwordEvaluator,
      sessionActivityReporter: activityReporter,
      userSettings: vaultKitUserSettings,
      savePreferencesOnChange: savePreferencesOnChange,
      copyAction: copyAction
    )
  }

  internal func makePasswordGeneratorViewModel(
    mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true,
    copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
    return PasswordGeneratorViewModel(
      mode: mode,
      database: database,
      passwordEvaluator: appServices.passwordEvaluator,
      sessionActivityReporter: activityReporter,
      userSettings: vaultKitUserSettings,
      savePreferencesOnChange: savePreferencesOnChange,
      copyAction: copyAction
    )
  }

  internal func makePasswordGeneratorViewModel(
    mode: PasswordGeneratorMode, copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
    return PasswordGeneratorViewModel(
      mode: mode,
      database: database,
      passwordEvaluator: appServices.passwordEvaluator,
      sessionActivityReporter: activityReporter,
      userSettings: vaultKitUserSettings,
      copyAction: copyAction
    )
  }

}

extension SessionServicesContainer {

  internal func makePasswordHealthDetailedListViewModel(
    kind: PasswordHealthKind, origin: PasswordHealthFlowViewModel.Origin
  ) -> PasswordHealthDetailedListViewModel {
    return PasswordHealthDetailedListViewModel(
      kind: kind,
      origin: origin,
      passwordHealthListViewModelFactory: InjectedFactory(makePasswordHealthListViewModel),
      passwordHealthService: identityDashboardService,
      userSpacesService: userSpacesService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makePasswordHealthFlowViewModel(origin: PasswordHealthFlowViewModel.Origin)
    -> PasswordHealthFlowViewModel
  {
    return PasswordHealthFlowViewModel(
      passwordHealthViewModelFactory: InjectedFactory(makePasswordHealthViewModel),
      passwordHealthDetailedListViewModelFactory: InjectedFactory(
        makePasswordHealthDetailedListViewModel),
      credentialDetailViewModelFactory: InjectedFactory(makeCredentialDetailViewModel),
      deeplinkingService: appServices.deepLinkingService,
      activityReporter: activityReporter,
      origin: origin
    )
  }

}

extension SessionServicesContainer {

  internal func makePasswordHealthListRowView(
    item: Credential, exclude: @escaping () -> Void, replace: @escaping () -> Void,
    detail: @escaping (Credential) -> Void
  ) -> PasswordHealthListRowView {
    return PasswordHealthListRowView(
      item: item,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      exclude: exclude,
      replace: replace,
      detail: detail
    )
  }

}

extension SessionServicesContainer {

  internal func makePasswordHealthListViewModel(
    kind: PasswordHealthKind, maximumCredentialsCount: Int? = nil,
    origin: PasswordHealthFlowViewModel.Origin
  ) -> PasswordHealthListViewModel {
    return PasswordHealthListViewModel(
      kind: kind,
      maximumCredentialsCount: maximumCredentialsCount,
      passwordHealthService: identityDashboardService,
      origin: origin,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      userSpacesService: userSpacesService,
      rowViewFactory: InjectedFactory(makePasswordHealthListRowView)
    )
  }

}

extension SessionServicesContainer {

  internal func makePasswordHealthSectionModel(service: DetailService<Credential>)
    -> PasswordHealthSectionModel
  {
    return PasswordHealthSectionModel(
      service: service,
      passwordEvaluator: appServices.passwordEvaluator,
      identityDashboardService: identityDashboardService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makePasswordHealthViewModel(origin: PasswordHealthFlowViewModel.Origin)
    -> PasswordHealthViewModel
  {
    return PasswordHealthViewModel(
      passwordHealthListViewModelFactory: InjectedFactory(makePasswordHealthListViewModel),
      passwordHealthService: identityDashboardService,
      origin: origin,
      userSpacesService: userSpacesService,
      userSpaceSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makePasswordLessCompletionViewModel(completion: @escaping () -> Void)
    -> PasswordLessCompletionViewModel
  {
    return PasswordLessCompletionViewModel(
      accountRecoveryActivationFlowFactory: InjectedFactory(
        makeAccountRecoveryActivationEmbeddedFlowModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makePhoneDetailViewModel(item: Phone, mode: DetailMode = .viewing)
    -> PhoneDetailViewModel
  {
    return PhoneDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
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

  internal func makePinCodeSettingsViewModel(
    actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void
  ) -> PinCodeSettingsViewModel {
    return PinCodeSettingsViewModel(
      session: session,
      lockService: lockService,
      userSpacesService: userSpacesService,
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
  @MainActor
  internal func makePostARKChangeMasterPasswordViewModel(
    accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void
  ) -> PostARKChangeMasterPasswordViewModel {
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
  @MainActor
  internal func makePremiumAnnouncementsViewModel(
    excludedAnnouncements: Set<PremiumAnnouncement> = []
  ) -> PremiumAnnouncementsViewModel {
    return PremiumAnnouncementsViewModel(
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      productInfoUpdater: productInfoUpdater,
      featureService: featureService,
      deeplinkService: appServices.deepLinkingService,
      sessionActivityReporter: activityReporter,
      itemsLimitNotificationProvider: vaultServicesSuit.vaultItemsLimitService,
      userDeviceAPI: userDeviceAPIClient,
      excludedAnnouncements: excludedAnnouncements
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeQuickActionsMenuViewModel(
    item: VaultItem, origin: ActionableVaultItemRowViewModel.Origin, isSuggestedItem: Bool
  ) -> QuickActionsMenuViewModel {
    return QuickActionsMenuViewModel(
      item: item,
      sharingService: vaultKitSharingServiceHandler,
      accessControl: vaultKitAccessControl,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      userSpacesService: userSpacesService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel),
      origin: origin,
      pasteboardService: vaultKitPasteboardService,
      isSuggestedItem: isSuggestedItem
    )
  }

}

extension SessionServicesContainer {

  internal func makeRememberMasterPasswordToggleViewModel(
    actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void
  ) -> RememberMasterPasswordToggleViewModel {
    return RememberMasterPasswordToggleViewModel(
      lockService: lockService,
      userSpacesService: userSpacesService,
      actionHandler: actionHandler
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeResetMasterPasswordNotificationRowViewModel(notification: DashlaneNotification)
    -> ResetMasterPasswordNotificationRowViewModel
  {
    return ResetMasterPasswordNotificationRowViewModel(
      notification: notification,
      resetMasterPasswordIntroViewModelFactory: InjectedFactory(
        makeResetMasterPasswordIntroViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeSSOEnableBiometricsOrPinViewModel() -> SSOEnableBiometricsOrPinViewModel {
    return SSOEnableBiometricsOrPinViewModel(
      userSettings: vaultKitUserSettings,
      lockService: lockService
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecretDetailViewModel(item: Secret, mode: DetailMode = .viewing)
    -> SecretDetailViewModel
  {
    return SecretDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      documentStorageService: documentStorageService,
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
      pasteboardService: vaultKitPasteboardService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings
    )
  }

  internal func makeSecretDetailViewModel(service: DetailService<Secret>) -> SecretDetailViewModel {
    return SecretDetailViewModel(
      service: service,
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecureArchiveSectionContentViewModel() -> SecureArchiveSectionContentViewModel {
    return SecureArchiveSectionContentViewModel(
      exportSecureArchiveViewModelFactory: InjectedFactory(makeExportSecureArchiveViewModel),
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecureLockNotificationRowViewModel(notification: DashlaneNotification)
    -> SecureLockNotificationRowViewModel
  {
    return SecureLockNotificationRowViewModel(
      notification: notification,
      lockService: lockService
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecureNotesDetailFieldsModel(service: DetailService<SecureNote>)
    -> SecureNotesDetailFieldsModel
  {
    return SecureNotesDetailFieldsModel(
      service: service,
      featureService: featureService
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecureNotesDetailNavigationBarModel(
    service: DetailService<SecureNote>, isEditingContent: FocusState<Bool>.Binding
  ) -> SecureNotesDetailNavigationBarModel {
    return SecureNotesDetailNavigationBarModel(
      service: service,
      isEditingContent: isEditingContent,
      featureService: featureService
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecureNotesDetailToolbarModel(service: DetailService<SecureNote>)
    -> SecureNotesDetailToolbarModel
  {
    return SecureNotesDetailToolbarModel(
      service: service,
      session: session,
      shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecureNotesDetailViewModel(item: SecureNote, mode: DetailMode = .viewing)
    -> SecureNotesDetailViewModel
  {
    return SecureNotesDetailViewModel(
      item: item,
      session: session,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      pasteboardService: vaultKitPasteboardService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      secureNotesDetailNavigationBarModelFactory: InjectedFactory(
        makeSecureNotesDetailNavigationBarModel),
      secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
      secureNotesDetailToolbarModelFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
      sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
      shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel),
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel),
      logger: appServices.rootLogger,
      documentStorageService: documentStorageService,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings
    )
  }

  internal func makeSecureNotesDetailViewModel(service: DetailService<SecureNote>)
    -> SecureNotesDetailViewModel
  {
    return SecureNotesDetailViewModel(
      session: session,
      service: service,
      secureNotesDetailNavigationBarModelFactory: InjectedFactory(
        makeSecureNotesDetailNavigationBarModel),
      secureNotesDetailFieldsModelFactory: InjectedFactory(makeSecureNotesDetailFieldsModel),
      secureNotesDetailToolbarFactory: InjectedFactory(makeSecureNotesDetailToolbarModel),
      sharingDetailSectionModelFactory: InjectedFactory(makeSharingDetailSectionModel),
      sharingMembersDetailLinkModelFactory: InjectedFactory(makeSharingMembersDetailLinkModel),
      shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
      attachmentsListViewModelFactory: InjectedFactory(makeAttachmentsListViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeSecurityAlertNotificationRowViewModel(notification: DashlaneNotification)
    -> SecurityAlertNotificationRowViewModel
  {
    return SecurityAlertNotificationRowViewModel(
      notification: notification,
      deepLinkingService: appServices.deepLinkingService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSecurityChallengeFlowModel(
    login: String, transfer: PendingTransfer,
    senderSecurityChallengeService: SenderSecurityChallengeService,
    completion: @escaping (SecurityChallengeFlowModel.CompletionType) -> Void
  ) -> SecurityChallengeFlowModel {
    return SecurityChallengeFlowModel(
      login: login,
      transfer: transfer,
      senderSecurityChallengeService: senderSecurityChallengeService,
      deviceTransferPendingRequestViewModelFactory: InjectedFactory(
        makeDeviceTransferPendingRequestViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSecuritySettingsViewModel() -> SecuritySettingsViewModel {
    return SecuritySettingsViewModel(
      session: session,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      featureService: featureService,
      lockService: lockService,
      syncedSettings: syncedSettings,
      settingsLockSectionViewModelFactory: InjectedFactory(makeSettingsLockSectionViewModel),
      settingsAccountSectionViewModelFactory: InjectedFactory(makeSettingsAccountSectionViewModel),
      settingsBiometricToggleViewModelFactory: InjectedFactory(
        makeSettingsBiometricToggleViewModel),
      masterPasswordResetActivationViewModelFactory: InjectedFactory(
        makeMasterPasswordResetActivationViewModel),
      pinCodeSettingsViewModelFactory: InjectedFactory(makePinCodeSettingsViewModel),
      rememberMasterPasswordToggleViewModelFactory: InjectedFactory(
        makeRememberMasterPasswordToggleViewModel),
      twoFASettingsViewModelFactory: InjectedFactory(makeTwoFASettingsViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSettingsAccountSectionViewModel(
    actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
  ) -> SettingsAccountSectionViewModel {
    return SettingsAccountSectionViewModel(
      session: session,
      featureService: featureService,
      userSpacesService: userSpacesService,
      deviceListViewModel: makeDeviceListViewModel,
      activityReporter: activityReporter,
      sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
      deepLinkingService: appServices.deepLinkingService,
      userDeviceAPIClient: userDeviceAPIClient,
      masterPasswordResetActivationViewModelFactory: InjectedFactory(
        makeMasterPasswordResetActivationViewModel),
      changeMasterPasswordFlowViewModelFactory: InjectedFactory(
        makeChangeMasterPasswordFlowViewModel),
      accountRecoveryKeyStatusViewModelFactory: InjectedFactory(
        makeAccountRecoveryKeyStatusViewModel),
      actionHandler: actionHandler
    )
  }

}

extension SessionServicesContainer {

  internal func makeSettingsBiometricToggleViewModel(
    actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void
  ) -> SettingsBiometricToggleViewModel {
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
      accountSummaryViewModelFactory: InjectedFactory(makeAccountSummaryViewModel),
      deepLinkingService: appServices.deepLinkingService
    )
  }

}

extension SessionServicesContainer {

  internal func makeSettingsLockSectionViewModel() -> SettingsLockSectionViewModel {
    return SettingsLockSectionViewModel(
      lockService: lockService,
      accessControl: vaultKitAccessControl
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSettingsStatusSectionViewModel() -> SettingsStatusSectionViewModel {
    return SettingsStatusSectionViewModel(
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      deepLinkingService: appServices.deepLinkingService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeShareButtonViewModel(
    items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> ShareButtonViewModel {
    return ShareButtonViewModel(
      items: items,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      userSpacesService: userSpacesService,
      shareFlowViewModelFactory: InjectedFactory(makeShareFlowViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeShareFlowViewModel(
    items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> ShareFlowViewModel {
    return ShareFlowViewModel(
      items: items,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      sharingService: vaultKitSharingService,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      itemsViewModelFactory: InjectedFactory(makeShareItemsSelectionViewModel),
      recipientsViewModelFactory: InjectedFactory(makeShareRecipientsSelectionViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeShareItemsSelectionViewModel(
    completion: @MainActor @escaping ([VaultItem]) -> Void
  ) -> ShareItemsSelectionViewModel {
    return ShareItemsSelectionViewModel(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      userSpacesService: userSpacesService,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeShareRecipientsSelectionViewModel(
    configuration: RecipientsConfiguration = .init(), showPermissionLevelSelector: Bool = true,
    showTeamOnly: Bool = false, completion: @MainActor @escaping (RecipientsConfiguration) -> Void
  ) -> ShareRecipientsSelectionViewModel {
    return ShareRecipientsSelectionViewModel(
      session: session,
      configuration: configuration,
      showPermissionLevelSelector: showPermissionLevelSelector,
      showTeamOnly: showTeamOnly,
      sharingService: vaultKitSharingService,
      premiumStatusProvider: premiumStatusServicesSuit.statusProvider,
      gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingCollectionMembersDetailViewModel(collection: VaultCollection)
    -> SharingCollectionMembersDetailViewModel
  {
    return SharingCollectionMembersDetailViewModel(
      collection: collection,
      session: session,
      sharingService: vaultKitSharingService,
      gravatarViewModelFactory: InjectedFactory(makeGravatarIconViewModel)
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
  internal func makeSharingItemsUserDetailViewModel(
    user: SharingEntitiesUser, userUpdatePublisher: AnyPublisher<SharingEntitiesUser, Never>,
    itemsProvider: SharingToolItemsProvider
  ) -> SharingItemsUserDetailViewModel {
    return SharingItemsUserDetailViewModel(
      user: user,
      userUpdatePublisher: userUpdatePublisher,
      itemsProvider: itemsProvider,
      vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
      detailViewModelFactory: InjectedFactory(makeVaultDetailViewModel),
      userSpacesService: userSpacesService,
      sharingService: vaultKitSharingService,
      accessControl: vaultKitAccessControl
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingItemsUserGroupDetailViewModel(
    userGroup: SharingEntitiesUserGroup,
    userGroupUpdatePublisher: AnyPublisher<SharingEntitiesUserGroup, Never>,
    itemsProvider: SharingToolItemsProvider
  ) -> SharingItemsUserGroupDetailViewModel {
    return SharingItemsUserGroupDetailViewModel(
      userGroup: userGroup,
      userGroupUpdatePublisher: userGroupUpdatePublisher,
      itemsProvider: itemsProvider,
      vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
      userSpacesService: userSpacesService,
      detailViewModelFactory: InjectedFactory(makeVaultDetailViewModel),
      sharingService: vaultKitSharingService,
      accessControl: vaultKitAccessControl
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingMembersDetailLinkModel(item: VaultItem) -> SharingMembersDetailLinkModel
  {
    return SharingMembersDetailLinkModel(
      item: item,
      sharingService: vaultKitSharingService,
      detailViewModelFactory: InjectedFactory(makeSharingMembersDetailViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingMembersDetailViewModel(members: ItemSharingMembers, item: VaultItem)
    -> SharingMembersDetailViewModel
  {
    return SharingMembersDetailViewModel(
      members: members,
      item: item,
      session: session,
      personalDataBD: database,
      gravatarViewModelFactory: InjectedFactory(makeGravatarIconViewModel),
      shareButtonModelFactory: InjectedFactory(makeShareButtonViewModel),
      sharingService: vaultKitSharingService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingPendingEntitiesSectionViewModel()
    -> SharingPendingEntitiesSectionViewModel
  {
    return SharingPendingEntitiesSectionViewModel(
      sharingService: vaultKitSharingService,
      userSpacesService: userSpacesService,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingPendingUserGroupsSectionViewModel()
    -> SharingPendingUserGroupsSectionViewModel
  {
    return SharingPendingUserGroupsSectionViewModel(
      userSpacesService: userSpacesService,
      sharingService: vaultKitSharingService
    )
  }

}

extension SessionServicesContainer {

  internal func makeSharingRequestNotificationRowViewModel(notification: DashlaneNotification)
    -> SharingRequestNotificationRowViewModel
  {
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
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      userSpacesService: userSpacesService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingToolViewModel() -> SharingToolViewModel {
    return SharingToolViewModel(
      itemsProviderFactory: InjectedFactory(makeSharingToolItemsProvider),
      pendingUserGroupsSectionViewModelFactory: InjectedFactory(
        makeSharingPendingUserGroupsSectionViewModel),
      pendingEntititesViewModelFactory: InjectedFactory(makeSharingPendingEntitiesSectionViewModel),
      userGroupsSectionViewModelFactory: InjectedFactory(makeSharingUserGroupsSectionViewModel),
      usersSectionViewModelFactory: InjectedFactory(makeSharingUsersSectionViewModel),
      userSpaceSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel),
      shareButtonViewModelFactory: InjectedFactory(makeShareButtonViewModel),
      sharingService: vaultKitSharingService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingToolsFlowViewModel() -> SharingToolsFlowViewModel {
    return SharingToolsFlowViewModel(
      accessControl: vaultKitAccessControl,
      detailViewModelFactory: InjectedFactory(makeVaultDetailViewModel),
      sharingToolViewModelFactory: InjectedFactory(makeSharingToolViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingUserGroupsSectionViewModel(itemsProvider: SharingToolItemsProvider)
    -> SharingUserGroupsSectionViewModel
  {
    return SharingUserGroupsSectionViewModel(
      itemsProvider: itemsProvider,
      detailViewModelFactory: InjectedFactory(makeSharingItemsUserGroupDetailViewModel),
      sharingService: vaultKitSharingService,
      userSpacesService: userSpacesService
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSharingUsersSectionViewModel(itemsProvider: SharingToolItemsProvider)
    -> SharingUsersSectionViewModel
  {
    return SharingUsersSectionViewModel(
      itemsProvider: itemsProvider,
      sharingService: vaultKitSharingService,
      detailViewModelFactory: InjectedFactory(makeSharingItemsUserDetailViewModel),
      gravatarIconViewModelFactory: InjectedFactory(makeGravatarIconViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeSidebarViewModel() -> SidebarViewModel {
    return SidebarViewModel(
      toolsService: toolsService,
      userSpacesService: userSpacesService,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      deeplinkingService: appServices.deepLinkingService,
      settingsFlowViewModelFactory: InjectedFactory(makeSettingsFlowViewModel),
      collectionNamingViewModelFactory: InjectedFactory(makeCollectionNamingViewModel),
      vaultCollectionEditionServiceFactory: InjectedFactory(makeVaultCollectionEditionService)
    )
  }

}

extension SessionServicesContainer {

  internal func makeSocialSecurityDetailViewModel(
    item: SocialSecurityInformation, mode: DetailMode = .viewing
  ) -> SocialSecurityDetailViewModel {
    return SocialSecurityDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeSocialSecurityDetailViewModel(service: DetailService<SocialSecurityInformation>)
    -> SocialSecurityDetailViewModel
  {
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
      session: session,
      userSettings: vaultKitUserSettings,
      vpnService: vpnService,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      deepLinkingService: appServices.deepLinkingService,
      darkWebMonitoringService: darkWebMonitoringService,
      toolsViewModelFactory: InjectedFactory(makeToolsViewModel),
      passwordHealthFlowViewModelFactory: InjectedFactory(makePasswordHealthFlowViewModel),
      authenticatorToolFlowViewModelFactory: InjectedFactory(makeAuthenticatorToolFlowViewModel),
      passwordGeneratorToolsFlowViewModelFactory: InjectedFactory(
        makePasswordGeneratorToolsFlowViewModel),
      vpnAvailableToolsFlowViewModelFactory: InjectedFactory(makeVPNAvailableToolsFlowViewModel),
      sharingToolsFlowViewModelFactory: InjectedFactory(makeSharingToolsFlowViewModel),
      darkWebToolsFlowViewModelFactory: InjectedFactory(makeDarkWebToolsFlowViewModel),
      unresolvedAlertViewModelFactory: InjectedFactory(makeUnresolvedAlertViewModel),
      collectionsFlowViewModelFactory: InjectedFactory(makeCollectionsFlowViewModel),
      addNewDeviceFactory: InjectedFactory(makeAddNewDeviceViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeToolsViewModel(didSelectItem: PassthroughSubject<ToolsItem, Never>)
    -> ToolsViewModel
  {
    return ToolsViewModel(
      toolsService: toolsService,
      didSelectItem: didSelectItem
    )
  }

}

extension SessionServicesContainer {

  internal func makeTrialPeriodNotificationRowViewModel(notification: DashlaneNotification)
    -> TrialPeriodNotificationRowViewModel
  {
    return TrialPeriodNotificationRowViewModel(
      notification: notification,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      deepLinkingService: appServices.deepLinkingService,
      activityReporter: activityReporter
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeTwoFADeactivationViewModel(isTwoFAEnforced: Bool) -> TwoFADeactivationViewModel
  {
    return TwoFADeactivationViewModel(
      session: session,
      sessionsContainer: appServices.sessionContainer,
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
      isTwoFAEnforced: isTwoFAEnforced
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeTwoFASettingsViewModel(
    login: Login, loginOTPOption: ThirdPartyOTPOption?, isTwoFAEnforced: Bool
  ) -> TwoFASettingsViewModel {
    return TwoFASettingsViewModel(
      login: login,
      loginOTPOption: loginOTPOption,
      userAPIClient: userDeviceAPIClient,
      logger: appServices.rootLogger,
      isTwoFAEnforced: isTwoFAEnforced,
      reachability: appServices.networkReachability,
      sessionLifeCycleHandler: appServices.sessionLifeCycleHandler,
      twoFADeactivationViewModelFactory: InjectedFactory(makeTwoFADeactivationViewModel),
      twoFactorEnforcementViewModelFactory: InjectedFactory(makeTwoFactorEnforcementViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeTwoFactorEnforcementViewModel(logout: @escaping () -> Void)
    -> TwoFactorEnforcementViewModel
  {
    return TwoFactorEnforcementViewModel(
      userDeviceAPIClient: userDeviceAPIClient,
      lockService: lockService,
      logout: logout
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeUnresolvedAlertViewModel() -> UnresolvedAlertViewModel {
    return UnresolvedAlertViewModel(
      identityDashboardService: identityDashboardService,
      deeplinkService: appServices.deepLinkingService,
      passwordHealthFlowViewModelFactory: InjectedFactory(makePasswordHealthFlowViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeVPNActivationViewModel(
    actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>,
    activationState: VPNActivationState = .initial
  ) -> VPNActivationViewModel {
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

  internal func makeVPNMainViewModel(
    mode: VPNMainViewModel.VPNMainViewMode, credential: Credential? = nil,
    actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>? = nil
  ) -> VPNMainViewModel {
    return VPNMainViewModel(
      mode: mode,
      credential: credential,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      userSettings: vaultKitUserSettings,
      activityReporter: activityReporter,
      accessControl: vaultKitAccessControl,
      iconService: iconService,
      pasteboardService: vaultKitPasteboardService,
      actionPublisher: actionPublisher
    )
  }

}

extension SessionServicesContainer {

  internal func makeVaultActiveSearchViewModel(
    searchCriteriaPublisher: AnyPublisher<String, Never>,
    searchResult: SearchResult = SearchResult(searchCriteria: "", sections: []),
    searchCategory: ItemCategory?, completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultActiveSearchViewModel {
    return VaultActiveSearchViewModel(
      searchCriteriaPublisher: searchCriteriaPublisher,
      searchResult: searchResult,
      searchCategory: searchCategory,
      activityReporter: activityReporter,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      rowModelFactory: InjectedFactory(makeActionableVaultItemRowViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeVaultCollectionEditionService(collection: VaultCollection)
    -> VaultCollectionEditionService
  {
    return VaultCollectionEditionService(
      collection: collection,
      logger: appServices.rootLogger,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingService
    )
  }

}

extension SessionServicesContainer {

  internal func makeVaultDetailViewModel() -> VaultDetailViewModel {
    return VaultDetailViewModel(
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
      secretFactory: InjectedFactory(makeSecretDetailViewModel),
      addressFactory: InjectedFactory(makeAddressDetailViewModel),
      creditCardFactory: InjectedFactory(makeCreditCardDetailViewModel),
      bankAccountFactory: InjectedFactory(makeBankAccountDetailViewModel),
      secureNoteFactory: InjectedFactory(makeSecureNotesDetailViewModel),
      passkeyFactory: InjectedFactory(makePasskeyDetailViewModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeVaultFlowViewModel(
    itemCategory: ItemCategory? = nil,
    onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil
  ) -> VaultFlowViewModel {
    return VaultFlowViewModel(
      itemCategory: itemCategory,
      onboardingChecklistViewAction: onboardingChecklistViewAction,
      deepLinkingService: appServices.deepLinkingService,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsLimitService: vaultServicesSuit.vaultItemsLimitService,
      accessControl: vaultKitAccessControl,
      userSpacesService: userSpacesService,
      activityReporter: activityReporter,
      detailViewModelFactory: InjectedFactory(makeVaultDetailViewModel),
      homeViewModelFactory: InjectedFactory(makeHomeViewModel),
      vaultListViewModelFactory: InjectedFactory(makeVaultListViewModel),
      addItemFlowViewModelFactory: InjectedFactory(makeAddItemFlowViewModel),
      autofillOnboardingFlowViewModelFactory: InjectedFactory(makeAutofillOnboardingFlowViewModel),
      onboardingChecklistFlowViewModelFactory: InjectedFactory(makeOnboardingChecklistFlowViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeVaultItemIconViewModel(item: VaultItem) -> VaultItemIconViewModel {
    return VaultItemIconViewModel(
      item: item,
      domainIconLibrary: domainIconLibrary
    )
  }

}

extension SessionServicesContainer {

  internal func makeVaultItemRow(item: VaultItem, userSpace: UserSpace?) -> VaultItemRow {
    return VaultItemRow(
      item: item,
      userSpace: userSpace,
      vaultIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeVaultItemsListViewModel(
    activeFilter: ItemCategory?, activeFilterPublisher: AnyPublisher<ItemCategory?, Never>,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultItemsListViewModel {
    return VaultItemsListViewModel(
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      userSettings: vaultKitUserSettings,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      sharingService: vaultKitSharingServiceHandler,
      featureService: featureService,
      activityReporter: activityReporter,
      rowModelFactory: InjectedFactory(makeActionableVaultItemRowViewModel),
      activeFilter: activeFilter,
      activeFilterPublisher: activeFilterPublisher,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeVaultListViewModel(
    activeFilter: ItemCategory?,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultListViewModel {
    return VaultListViewModel(
      activeFilter: activeFilter,
      onboardingAction: onboardingAction,
      vaultItemsListFactory: InjectedFactory(makeVaultItemsListViewModel),
      searchFactory: InjectedFactory(makeVaultSearchViewModel),
      action: action,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeVaultSearchViewModel(
    searchCriteria: String = "", searchCategory: ItemCategory?,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultSearchViewModel {
    return VaultSearchViewModel(
      searchCriteria: searchCriteria,
      searchCategory: searchCategory,
      activityReporter: activityReporter,
      deeplinkingService: appServices.deepLinkingService,
      activeSearchFactory: InjectedFactory(makeVaultActiveSearchViewModel),
      userSwitcherViewModelFactory: InjectedFactory(makeUserSpaceSwitcherViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeWebsiteDetailViewModel(item: PersonalWebsite, mode: DetailMode = .viewing)
    -> WebsiteDetailViewModel
  {
    return WebsiteDetailViewModel(
      item: item,
      mode: mode,
      vaultItemDatabase: vaultServicesSuit.vaultItemDatabase,
      vaultItemsStore: vaultServicesSuit.vaultItemsStore,
      vaultCollectionDatabase: vaultServicesSuit.vaultCollectionDatabase,
      vaultCollectionsStore: vaultServicesSuit.vaultCollectionsStore,
      sharingService: vaultKitSharingServiceHandler,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      deepLinkService: vaultKitDeepLinkingService,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService,
      iconViewModelProvider: makeVaultItemIconViewModel,
      logger: appServices.rootLogger,
      accessControl: vaultKitAccessControl,
      userSettings: vaultKitUserSettings,
      pasteboardService: vaultKitPasteboardService,
      attachmentSectionFactory: InjectedFactory(makeAttachmentsSectionViewModel)
    )
  }

  internal func makeWebsiteDetailViewModel(service: DetailService<PersonalWebsite>)
    -> WebsiteDetailViewModel
  {
    return WebsiteDetailViewModel(
      service: service
    )
  }

}

internal typealias _AccountCreationFlowViewModelFactory = @MainActor (
  _ completion: @MainActor @escaping (AccountCreationFlowViewModel.CompletionResult) -> Void
) -> AccountCreationFlowViewModel

extension InjectedFactory where T == _AccountCreationFlowViewModelFactory {
  @MainActor
  func make(
    completion: @MainActor @escaping (AccountCreationFlowViewModel.CompletionResult) -> Void
  ) -> AccountCreationFlowViewModel {
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

extension InjectedFactory where T == _AccountEmailViewModelFactory {
  @MainActor
  func make(completion: @escaping (_ result: AccountEmailViewModel.CompletionResult) -> Void)
    -> AccountEmailViewModel
  {
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

extension InjectedFactory where T == _AccountRecoveryActivationEmbeddedFlowModelFactory {
  @MainActor
  func make(context: AccountRecoveryActivationContext, completion: @MainActor @escaping () -> Void)
    -> AccountRecoveryActivationEmbeddedFlowModel
  {
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

extension InjectedFactory where T == _AccountRecoveryActivationFlowModelFactory {
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

internal typealias _AccountRecoveryKeyDisabledAlertViewModelFactory = (
  _ authenticationMethod: AuthenticationMethod
) -> AccountRecoveryKeyDisabledAlertViewModel

extension InjectedFactory where T == _AccountRecoveryKeyDisabledAlertViewModelFactory {

  func make(authenticationMethod: AuthenticationMethod) -> AccountRecoveryKeyDisabledAlertViewModel
  {
    return factory(
      authenticationMethod
    )
  }
}

extension AccountRecoveryKeyDisabledAlertViewModel {
  internal typealias Factory = InjectedFactory<_AccountRecoveryKeyDisabledAlertViewModelFactory>
}

internal typealias _AccountRecoveryKeyStatusDetailViewModelFactory = @MainActor (
  _ isEnabled: Bool
) -> AccountRecoveryKeyStatusDetailViewModel

extension InjectedFactory where T == _AccountRecoveryKeyStatusDetailViewModelFactory {
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

extension InjectedFactory where T == _AccountRecoveryKeyStatusViewModelFactory {
  @MainActor
  func make() -> AccountRecoveryKeyStatusViewModel {
    return factory()
  }
}

extension AccountRecoveryKeyStatusViewModel {
  internal typealias Factory = InjectedFactory<_AccountRecoveryKeyStatusViewModelFactory>
}

internal typealias _AccountSummaryViewModelFactory = (
) -> AccountSummaryViewModel

extension InjectedFactory where T == _AccountSummaryViewModelFactory {

  func make() -> AccountSummaryViewModel {
    return factory()
  }
}

extension AccountSummaryViewModel {
  internal typealias Factory = InjectedFactory<_AccountSummaryViewModelFactory>
}

internal typealias _ActionableVaultItemRowViewModelFactory = (
  _ item: VaultItem,
  _ isSuggested: Bool,
  _ origin: ActionableVaultItemRowViewModel.Origin
) -> ActionableVaultItemRowViewModel

extension InjectedFactory where T == _ActionableVaultItemRowViewModelFactory {

  func make(item: VaultItem, isSuggested: Bool, origin: ActionableVaultItemRowViewModel.Origin)
    -> ActionableVaultItemRowViewModel
  {
    return factory(
      item,
      isSuggested,
      origin
    )
  }
}

extension ActionableVaultItemRowViewModel {
  internal typealias Factory = InjectedFactory<_ActionableVaultItemRowViewModelFactory>
}

public typealias _AddAttachmentButtonViewModelFactory = (
  _ editingItem: VaultItem,
  _ shouldDisplayRenameAlert: Bool,
  _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AddAttachmentButtonViewModel

extension InjectedFactory where T == _AddAttachmentButtonViewModelFactory {

  public func make(
    editingItem: VaultItem, shouldDisplayRenameAlert: Bool = true,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) -> AddAttachmentButtonViewModel {
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

extension InjectedFactory where T == _AddItemFlowViewModelFactory {
  @MainActor
  func make(
    displayMode: AddItemFlowViewModel.DisplayMode,
    completion: @escaping (AddItemFlowViewModel.Completion) -> Void
  ) -> AddItemFlowViewModel {
    return factory(
      displayMode,
      completion
    )
  }
}

extension AddItemFlowViewModel {
  internal typealias Factory = InjectedFactory<_AddItemFlowViewModelFactory>
}

public typealias _AddLoginDetailsViewModelFactory = (
  _ website: String,
  _ credential: Credential?,
  _ supportDashlane2FA: Bool,
  _ completion: @escaping (OTPInfo) -> Void
) -> AddLoginDetailsViewModel

extension InjectedFactory where T == _AddLoginDetailsViewModelFactory {

  public func make(
    website: String, credential: Credential?, supportDashlane2FA: Bool,
    completion: @escaping (OTPInfo) -> Void
  ) -> AddLoginDetailsViewModel {
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

extension InjectedFactory where T == _AddNewDeviceViewModelFactory {
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

internal typealias _AddOTPFlowViewModelFactory = @MainActor (
  _ mode: AddOTPFlowViewModel.Mode,
  _ completion: @escaping () -> Void
) -> AddOTPFlowViewModel

extension InjectedFactory where T == _AddOTPFlowViewModelFactory {
  @MainActor
  func make(mode: AddOTPFlowViewModel.Mode, completion: @escaping () -> Void) -> AddOTPFlowViewModel
  {
    return factory(
      mode,
      completion
    )
  }
}

extension AddOTPFlowViewModel {
  internal typealias Factory = InjectedFactory<_AddOTPFlowViewModelFactory>
}

internal typealias _AddOTPManuallyFlowViewModelFactory = @MainActor (
  _ credential: Credential?,
  _ completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void
) -> AddOTPManuallyFlowViewModel

extension InjectedFactory where T == _AddOTPManuallyFlowViewModelFactory {
  @MainActor
  func make(
    credential: Credential?, completion: @escaping (AddOTPManuallyFlowViewModel.Completion) -> Void
  ) -> AddOTPManuallyFlowViewModel {
    return factory(
      credential,
      completion
    )
  }
}

extension AddOTPManuallyFlowViewModel {
  internal typealias Factory = InjectedFactory<_AddOTPManuallyFlowViewModelFactory>
}

internal typealias _AddPrefilledCredentialViewModelFactory = (
  _ didChooseCredential: @escaping (Credential, Bool) -> Void
) -> AddPrefilledCredentialViewModel

extension InjectedFactory where T == _AddPrefilledCredentialViewModelFactory {

  func make(didChooseCredential: @escaping (Credential, Bool) -> Void)
    -> AddPrefilledCredentialViewModel
  {
    return factory(
      didChooseCredential
    )
  }
}

extension AddPrefilledCredentialViewModel {
  internal typealias Factory = InjectedFactory<_AddPrefilledCredentialViewModelFactory>
}

internal typealias _AddressDetailViewModelFactory = (
  _ item: Address,
  _ mode: DetailMode,
  _ dismiss: (() -> Void)?
) -> AddressDetailViewModel

extension InjectedFactory where T == _AddressDetailViewModelFactory {

  func make(item: Address, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil)
    -> AddressDetailViewModel
  {
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

internal typealias _AddressDetailViewModelSecondFactory = (
  _ service: DetailService<Address>
) -> AddressDetailViewModel

extension InjectedFactory where T == _AddressDetailViewModelSecondFactory {

  func make(service: DetailService<Address>) -> AddressDetailViewModel {
    return factory(
      service
    )
  }
}

extension AddressDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_AddressDetailViewModelSecondFactory>
}

public typealias _AttachmentRowViewModelFactory = (
  _ attachment: Attachment,
  _ attachmentPublisher: AnyPublisher<Attachment, Never>,
  _ editingItem: DocumentAttachable,
  _ deleteAction: @escaping (Attachment) -> Void
) -> AttachmentRowViewModel

extension InjectedFactory where T == _AttachmentRowViewModelFactory {

  public func make(
    attachment: Attachment, attachmentPublisher: AnyPublisher<Attachment, Never>,
    editingItem: DocumentAttachable, deleteAction: @escaping (Attachment) -> Void
  ) -> AttachmentRowViewModel {
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

public typealias _AttachmentsListViewModelFactory = (
  _ editingItem: VaultItem,
  _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsListViewModel

extension InjectedFactory where T == _AttachmentsListViewModelFactory {

  public func make(editingItem: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>)
    -> AttachmentsListViewModel
  {
    return factory(
      editingItem,
      itemPublisher
    )
  }
}

extension AttachmentsListViewModel {
  public typealias Factory = InjectedFactory<_AttachmentsListViewModelFactory>
}

public typealias _AttachmentsSectionViewModelFactory = (
  _ item: VaultItem,
  _ itemPublisher: AnyPublisher<VaultItem, Never>
) -> AttachmentsSectionViewModel

extension InjectedFactory where T == _AttachmentsSectionViewModelFactory {

  public func make(item: VaultItem, itemPublisher: AnyPublisher<VaultItem, Never>)
    -> AttachmentsSectionViewModel
  {
    return factory(
      item,
      itemPublisher
    )
  }
}

extension AttachmentsSectionViewModel {
  public typealias Factory = InjectedFactory<_AttachmentsSectionViewModelFactory>
}

internal typealias _AuthenticatorToolFlowViewModelFactory = @MainActor (
) -> AuthenticatorToolFlowViewModel

extension InjectedFactory where T == _AuthenticatorToolFlowViewModelFactory {
  @MainActor
  func make() -> AuthenticatorToolFlowViewModel {
    return factory()
  }
}

extension AuthenticatorToolFlowViewModel {
  internal typealias Factory = InjectedFactory<_AuthenticatorToolFlowViewModelFactory>
}

internal typealias _BankAccountDetailViewModelFactory = (
  _ item: BankAccount,
  _ mode: DetailMode
) -> BankAccountDetailViewModel

extension InjectedFactory where T == _BankAccountDetailViewModelFactory {

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

internal typealias _BankAccountDetailViewModelSecondFactory = (
  _ service: DetailService<BankAccount>
) -> BankAccountDetailViewModel

extension InjectedFactory where T == _BankAccountDetailViewModelSecondFactory {

  func make(service: DetailService<BankAccount>) -> BankAccountDetailViewModel {
    return factory(
      service
    )
  }
}

extension BankAccountDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_BankAccountDetailViewModelSecondFactory>
}

internal typealias _BreachViewModelFactory = (
  _ hasBeenAddressed: Bool,
  _ url: PersonalDataURL,
  _ leakedPassword: String?,
  _ leakDate: Date?,
  _ email: String?,
  _ otherLeakedData: [String]?,
  _ simplifiedBreach: DWMSimplifiedBreach?
) -> BreachViewModel

extension InjectedFactory where T == _BreachViewModelFactory {

  func make(
    hasBeenAddressed: Bool, url: PersonalDataURL, leakedPassword: String?, leakDate: Date?,
    email: String? = nil, otherLeakedData: [String]? = nil,
    simplifiedBreach: DWMSimplifiedBreach? = nil
  ) -> BreachViewModel {
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

internal typealias _BreachViewModelSecondFactory = (
  _ breach: DWMSimplifiedBreach
) -> BreachViewModel

extension InjectedFactory where T == _BreachViewModelSecondFactory {

  func make(breach: DWMSimplifiedBreach) -> BreachViewModel {
    return factory(
      breach
    )
  }
}

extension BreachViewModel {
  internal typealias SecondFactory = InjectedFactory<_BreachViewModelSecondFactory>
}

internal typealias _BreachViewModelThirdFactory = (
  _ credential: Credential
) -> BreachViewModel

extension InjectedFactory where T == _BreachViewModelThirdFactory {

  func make(credential: Credential) -> BreachViewModel {
    return factory(
      credential
    )
  }
}

extension BreachViewModel {
  internal typealias ThirdFactory = InjectedFactory<_BreachViewModelThirdFactory>
}

internal typealias _ChangeContactEmailViewModelFactory = @MainActor (
  _ currentContactEmail: String,
  _ onSaveAction: @escaping () -> Void
) -> ChangeContactEmailViewModel

extension InjectedFactory where T == _ChangeContactEmailViewModelFactory {
  @MainActor
  func make(currentContactEmail: String, onSaveAction: @escaping () -> Void)
    -> ChangeContactEmailViewModel
  {
    return factory(
      currentContactEmail,
      onSaveAction
    )
  }
}

extension ChangeContactEmailViewModel {
  internal typealias Factory = InjectedFactory<_ChangeContactEmailViewModelFactory>
}

internal typealias _ChangeMasterPasswordFlowViewModelFactory = @MainActor (
) -> ChangeMasterPasswordFlowViewModel

extension InjectedFactory where T == _ChangeMasterPasswordFlowViewModelFactory {
  @MainActor
  func make() -> ChangeMasterPasswordFlowViewModel {
    return factory()
  }
}

extension ChangeMasterPasswordFlowViewModel {
  internal typealias Factory = InjectedFactory<_ChangeMasterPasswordFlowViewModelFactory>
}

public typealias _ChooseWebsiteViewModelFactory = (
  _ completion: @escaping (String) -> Void
) -> ChooseWebsiteViewModel

extension InjectedFactory where T == _ChooseWebsiteViewModelFactory {

  public func make(completion: @escaping (String) -> Void) -> ChooseWebsiteViewModel {
    return factory(
      completion
    )
  }
}

extension ChooseWebsiteViewModel {
  public typealias Factory = InjectedFactory<_ChooseWebsiteViewModelFactory>
}

internal typealias _CollectionDetailViewModelFactory = @MainActor (
  _ collection: VaultCollection
) -> CollectionDetailViewModel

extension InjectedFactory where T == _CollectionDetailViewModelFactory {
  @MainActor
  func make(collection: VaultCollection) -> CollectionDetailViewModel {
    return factory(
      collection
    )
  }
}

extension CollectionDetailViewModel {
  internal typealias Factory = InjectedFactory<_CollectionDetailViewModelFactory>
}

internal typealias _CollectionShareFlowViewModelFactory = @MainActor (
  _ collection: VaultCollection,
  _ userGroupIds: Set<Identifier>,
  _ userEmails: Set<String>
) -> CollectionShareFlowViewModel

extension InjectedFactory where T == _CollectionShareFlowViewModelFactory {
  @MainActor
  func make(
    collection: VaultCollection, userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> CollectionShareFlowViewModel {
    return factory(
      collection,
      userGroupIds,
      userEmails
    )
  }
}

extension CollectionShareFlowViewModel {
  internal typealias Factory = InjectedFactory<_CollectionShareFlowViewModelFactory>
}

internal typealias _CollectionsFlowViewModelFactory = @MainActor (
  _ initialStep: CollectionsFlowViewModel.Step
) -> CollectionsFlowViewModel

extension InjectedFactory where T == _CollectionsFlowViewModelFactory {
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

internal typealias _CompanyDetailViewModelFactory = (
  _ item: Company,
  _ mode: DetailMode
) -> CompanyDetailViewModel

extension InjectedFactory where T == _CompanyDetailViewModelFactory {

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

internal typealias _CompanyDetailViewModelSecondFactory = (
  _ service: DetailService<Company>
) -> CompanyDetailViewModel

extension InjectedFactory where T == _CompanyDetailViewModelSecondFactory {

  func make(service: DetailService<Company>) -> CompanyDetailViewModel {
    return factory(
      service
    )
  }
}

extension CompanyDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_CompanyDetailViewModelSecondFactory>
}

internal typealias _ConnectedEnvironmentModelFactory = (
) -> ConnectedEnvironmentModel

extension InjectedFactory where T == _ConnectedEnvironmentModelFactory {

  func make() -> ConnectedEnvironmentModel {
    return factory()
  }
}

extension ConnectedEnvironmentModel {
  internal typealias Factory = InjectedFactory<_ConnectedEnvironmentModelFactory>
}

internal typealias _ConnectedIpadMacRootViewModelFactory = @MainActor (
) -> ConnectedIpadMacRootViewModel

extension InjectedFactory where T == _ConnectedIpadMacRootViewModelFactory {
  @MainActor
  func make() -> ConnectedIpadMacRootViewModel {
    return factory()
  }
}

extension ConnectedIpadMacRootViewModel {
  internal typealias Factory = InjectedFactory<_ConnectedIpadMacRootViewModelFactory>
}

internal typealias _ConnectedIphoneRootViewModelFactory = @MainActor (
) -> ConnectedIphoneRootViewModel

extension InjectedFactory where T == _ConnectedIphoneRootViewModelFactory {
  @MainActor
  func make() -> ConnectedIphoneRootViewModel {
    return factory()
  }
}

extension ConnectedIphoneRootViewModel {
  internal typealias Factory = InjectedFactory<_ConnectedIphoneRootViewModelFactory>
}

internal typealias _ConnectedRootViewModelFactory = @MainActor (
) -> ConnectedRootViewModel

extension InjectedFactory where T == _ConnectedRootViewModelFactory {
  @MainActor
  func make() -> ConnectedRootViewModel {
    return factory()
  }
}

extension ConnectedRootViewModel {
  internal typealias Factory = InjectedFactory<_ConnectedRootViewModelFactory>
}

internal typealias _CredentialDetailViewModelFactory = @MainActor (
  _ item: Credential,
  _ mode: DetailMode,
  _ generatedPasswordToLink: GeneratedPassword?,
  _ actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>?,
  _ origin: ItemDetailOrigin,
  _ didSave: (() -> Void)?
) -> CredentialDetailViewModel

extension InjectedFactory where T == _CredentialDetailViewModelFactory {
  @MainActor
  func make(
    item: Credential, mode: DetailMode = .viewing,
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil
  ) -> CredentialDetailViewModel {
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

internal typealias _CredentialDetailViewModelSecondFactory = @MainActor (
  _ generatedPasswordToLink: GeneratedPassword?,
  _ actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>?,
  _ origin: ItemDetailOrigin,
  _ didSave: (() -> Void)?,
  _ service: DetailService<Credential>
) -> CredentialDetailViewModel

extension InjectedFactory where T == _CredentialDetailViewModelSecondFactory {
  @MainActor
  func make(
    generatedPasswordToLink: GeneratedPassword? = nil,
    actionPublisher: PassthroughSubject<CredentialDetailViewModel.Action, Never>? = nil,
    origin: ItemDetailOrigin = ItemDetailOrigin.unknown, didSave: (() -> Void)? = nil,
    service: DetailService<Credential>
  ) -> CredentialDetailViewModel {
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

internal typealias _CredentialMainSectionModelFactory = (
  _ service: DetailService<Credential>,
  _ isAutoFillDemoModalShown: Binding<Bool>,
  _ isAdd2FAFlowPresented: Binding<Bool>
) -> CredentialMainSectionModel

extension InjectedFactory where T == _CredentialMainSectionModelFactory {

  func make(
    service: DetailService<Credential>, isAutoFillDemoModalShown: Binding<Bool>,
    isAdd2FAFlowPresented: Binding<Bool>
  ) -> CredentialMainSectionModel {
    return factory(
      service,
      isAutoFillDemoModalShown,
      isAdd2FAFlowPresented
    )
  }
}

extension CredentialMainSectionModel {
  internal typealias Factory = InjectedFactory<_CredentialMainSectionModelFactory>
}

internal typealias _CreditCardDetailViewModelFactory = (
  _ item: CreditCard,
  _ mode: DetailMode,
  _ dismiss: (() -> Void)?
) -> CreditCardDetailViewModel

extension InjectedFactory where T == _CreditCardDetailViewModelFactory {

  func make(item: CreditCard, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil)
    -> CreditCardDetailViewModel
  {
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

internal typealias _CreditCardDetailViewModelSecondFactory = (
  _ service: DetailService<CreditCard>
) -> CreditCardDetailViewModel

extension InjectedFactory where T == _CreditCardDetailViewModelSecondFactory {

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

extension InjectedFactory where T == _DWMEmailConfirmationViewModelFactory {
  @MainActor
  func make(
    accountEmail: String, emailStatusCheck: DWMEmailConfirmationViewModel.EmailStatusCheckStrategy
  ) -> DWMEmailConfirmationViewModel {
    return factory(
      accountEmail,
      emailStatusCheck
    )
  }
}

extension DWMEmailConfirmationViewModel {
  internal typealias Factory = InjectedFactory<_DWMEmailConfirmationViewModelFactory>
}

internal typealias _DWMItemIconViewModelFactory = (
  _ url: PersonalDataURL
) -> DWMItemIconViewModel

extension InjectedFactory where T == _DWMItemIconViewModelFactory {

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

extension InjectedFactory where T == _DWMOnboardingFlowViewModelFactory {
  @MainActor
  func make(
    transitionHandler: GuidedOnboardingTransitionHandler?,
    completion: @escaping (DWMOnboardingFlowViewModel.Completion) -> Void
  ) -> DWMOnboardingFlowViewModel {
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

extension InjectedFactory where T == _DWMRegistrationInGuidedOnboardingViewModelFactory {
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

internal typealias _DarkWebMonitoringBreachListViewModelFactory = (
  _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?
) -> DarkWebMonitoringBreachListViewModel

extension InjectedFactory where T == _DarkWebMonitoringBreachListViewModelFactory {

  func make(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?)
    -> DarkWebMonitoringBreachListViewModel
  {
    return factory(
      actionPublisher
    )
  }
}

extension DarkWebMonitoringBreachListViewModel {
  internal typealias Factory = InjectedFactory<_DarkWebMonitoringBreachListViewModelFactory>
}

internal typealias _DarkWebMonitoringDetailsViewModelFactory = (
  _ breach: DWMSimplifiedBreach,
  _ breachViewModel: BreachViewModel,
  _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>?
) -> DarkWebMonitoringDetailsViewModel

extension InjectedFactory where T == _DarkWebMonitoringDetailsViewModelFactory {

  func make(
    breach: DWMSimplifiedBreach, breachViewModel: BreachViewModel,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>? = nil
  ) -> DarkWebMonitoringDetailsViewModel {
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

internal typealias _DarkWebMonitoringEmailRowViewModelFactory = (
  _ email: DataLeakEmail,
  _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
) -> DarkWebMonitoringEmailRowViewModel

extension InjectedFactory where T == _DarkWebMonitoringEmailRowViewModelFactory {

  func make(
    email: DataLeakEmail,
    actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
  ) -> DarkWebMonitoringEmailRowViewModel {
    return factory(
      email,
      actionPublisher
    )
  }
}

extension DarkWebMonitoringEmailRowViewModel {
  internal typealias Factory = InjectedFactory<_DarkWebMonitoringEmailRowViewModelFactory>
}

internal typealias _DarkWebMonitoringMonitoredEmailsViewModelFactory = (
  _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
) -> DarkWebMonitoringMonitoredEmailsViewModel

extension InjectedFactory where T == _DarkWebMonitoringMonitoredEmailsViewModelFactory {

  func make(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>)
    -> DarkWebMonitoringMonitoredEmailsViewModel
  {
    return factory(
      actionPublisher
    )
  }
}

extension DarkWebMonitoringMonitoredEmailsViewModel {
  internal typealias Factory = InjectedFactory<_DarkWebMonitoringMonitoredEmailsViewModelFactory>
}

internal typealias _DarkWebMonitoringViewModelFactory = (
  _ actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never>
) -> DarkWebMonitoringViewModel

extension InjectedFactory where T == _DarkWebMonitoringViewModelFactory {

  func make(actionPublisher: PassthroughSubject<DarkWebToolsFlowViewModel.Action, Never> = .init())
    -> DarkWebMonitoringViewModel
  {
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

extension InjectedFactory where T == _DarkWebToolsFlowViewModelFactory {
  @MainActor
  func make() -> DarkWebToolsFlowViewModel {
    return factory()
  }
}

extension DarkWebToolsFlowViewModel {
  internal typealias Factory = InjectedFactory<_DarkWebToolsFlowViewModelFactory>
}

internal typealias _DataLeakMonitoringAddEmailViewModelFactory = @MainActor (
  _ login: Login,
  _ dataLeakService: DataLeakMonitoringRegisterServiceProtocol
) -> DataLeakMonitoringAddEmailViewModel

extension InjectedFactory where T == _DataLeakMonitoringAddEmailViewModelFactory {
  @MainActor
  func make(login: Login, dataLeakService: DataLeakMonitoringRegisterServiceProtocol)
    -> DataLeakMonitoringAddEmailViewModel
  {
    return factory(
      login,
      dataLeakService
    )
  }
}

extension DataLeakMonitoringAddEmailViewModel {
  internal typealias Factory = InjectedFactory<_DataLeakMonitoringAddEmailViewModelFactory>
}

internal typealias _DeviceListViewModelFactory = @MainActor (
) -> DeviceListViewModel

extension InjectedFactory where T == _DeviceListViewModelFactory {
  @MainActor
  func make() -> DeviceListViewModel {
    return factory()
  }
}

extension DeviceListViewModel {
  internal typealias Factory = InjectedFactory<_DeviceListViewModelFactory>
}

internal typealias _DeviceListViewModelSecondFactory = @MainActor (
  _ currentDeviceId: String
) -> DeviceListViewModel

extension InjectedFactory where T == _DeviceListViewModelSecondFactory {
  @MainActor
  func make(currentDeviceId: String) -> DeviceListViewModel {
    return factory(
      currentDeviceId
    )
  }
}

extension DeviceListViewModel {
  internal typealias SecondFactory = InjectedFactory<_DeviceListViewModelSecondFactory>
}

internal typealias _DeviceTransferPendingRequestViewModelFactory = @MainActor (
  _ login: String,
  _ pendingTransfer: PendingTransfer,
  _ senderSecurityChallengeService: SenderSecurityChallengeService,
  _ completion: @escaping (DeviceTransferPendingRequestViewModel.CompletionType) -> Void
) -> DeviceTransferPendingRequestViewModel

extension InjectedFactory where T == _DeviceTransferPendingRequestViewModelFactory {
  @MainActor
  func make(
    login: String, pendingTransfer: PendingTransfer,
    senderSecurityChallengeService: SenderSecurityChallengeService,
    completion: @escaping (DeviceTransferPendingRequestViewModel.CompletionType) -> Void
  ) -> DeviceTransferPendingRequestViewModel {
    return factory(
      login,
      pendingTransfer,
      senderSecurityChallengeService,
      completion
    )
  }
}

extension DeviceTransferPendingRequestViewModel {
  internal typealias Factory = InjectedFactory<_DeviceTransferPendingRequestViewModelFactory>
}

internal typealias _DomainsSectionModelFactory = (
  _ service: DetailService<Credential>
) -> DomainsSectionModel

extension InjectedFactory where T == _DomainsSectionModelFactory {

  func make(service: DetailService<Credential>) -> DomainsSectionModel {
    return factory(
      service
    )
  }
}

extension DomainsSectionModel {
  internal typealias Factory = InjectedFactory<_DomainsSectionModelFactory>
}

internal typealias _DrivingLicenseDetailViewModelFactory = (
  _ item: DrivingLicence,
  _ mode: DetailMode
) -> DrivingLicenseDetailViewModel

extension InjectedFactory where T == _DrivingLicenseDetailViewModelFactory {

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

internal typealias _DrivingLicenseDetailViewModelSecondFactory = (
  _ service: DetailService<DrivingLicence>
) -> DrivingLicenseDetailViewModel

extension InjectedFactory where T == _DrivingLicenseDetailViewModelSecondFactory {

  func make(service: DetailService<DrivingLicence>) -> DrivingLicenseDetailViewModel {
    return factory(
      service
    )
  }
}

extension DrivingLicenseDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_DrivingLicenseDetailViewModelSecondFactory>
}

internal typealias _EmailDetailViewModelFactory = (
  _ item: CorePersonalData.Email,
  _ mode: DetailMode
) -> EmailDetailViewModel

extension InjectedFactory where T == _EmailDetailViewModelFactory {

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

internal typealias _EmailDetailViewModelSecondFactory = (
  _ service: DetailService<CorePersonalData.Email>
) -> EmailDetailViewModel

extension InjectedFactory where T == _EmailDetailViewModelSecondFactory {

  func make(service: DetailService<CorePersonalData.Email>) -> EmailDetailViewModel {
    return factory(
      service
    )
  }
}

extension EmailDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_EmailDetailViewModelSecondFactory>
}

internal typealias _ExportSecureArchiveViewModelFactory = (
  _ onlyExportPersonalSpace: Bool
) -> ExportSecureArchiveViewModel

extension InjectedFactory where T == _ExportSecureArchiveViewModelFactory {

  func make(onlyExportPersonalSpace: Bool = false) -> ExportSecureArchiveViewModel {
    return factory(
      onlyExportPersonalSpace
    )
  }
}

extension ExportSecureArchiveViewModel {
  internal typealias Factory = InjectedFactory<_ExportSecureArchiveViewModelFactory>
}

internal typealias _FastLocalSetupInAccountCreationViewModelFactory = (
  _ biometry: Biometry?,
  _ completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void
) -> FastLocalSetupInAccountCreationViewModel

extension InjectedFactory where T == _FastLocalSetupInAccountCreationViewModelFactory {

  func make(
    biometry: Biometry? = Device.biometryType,
    completion: @escaping (FastLocalSetupInAccountCreationViewModel.Completion) -> Void
  ) -> FastLocalSetupInAccountCreationViewModel {
    return factory(
      biometry,
      completion
    )
  }
}

extension FastLocalSetupInAccountCreationViewModel {
  internal typealias Factory = InjectedFactory<_FastLocalSetupInAccountCreationViewModelFactory>
}

internal typealias _FastLocalSetupInLoginViewModelFactory = (
  _ masterPassword: String?,
  _ biometry: Biometry?,
  _ completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
) -> FastLocalSetupInLoginViewModel

extension InjectedFactory where T == _FastLocalSetupInLoginViewModelFactory {

  func make(
    masterPassword: String?, biometry: Biometry?,
    completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
  ) -> FastLocalSetupInLoginViewModel {
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

internal typealias _FastLocalSetupInLoginViewModelSecondFactory = (
  _ masterPassword: String?,
  _ biometry: Biometry?,
  _ lockService: LockService,
  _ masterPasswordResetService: ResetMasterPasswordService,
  _ userSettings: UserSettings,
  _ completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
) -> FastLocalSetupInLoginViewModel

extension InjectedFactory where T == _FastLocalSetupInLoginViewModelSecondFactory {

  func make(
    masterPassword: String?, biometry: Biometry?, lockService: LockService,
    masterPasswordResetService: ResetMasterPasswordService, userSettings: UserSettings,
    completion: @escaping (FastLocalSetupInLoginViewModel.Completion) -> Void
  ) -> FastLocalSetupInLoginViewModel {
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

internal typealias _FiscalInformationDetailViewModelFactory = (
  _ item: FiscalInformation,
  _ mode: DetailMode
) -> FiscalInformationDetailViewModel

extension InjectedFactory where T == _FiscalInformationDetailViewModelFactory {

  func make(item: FiscalInformation, mode: DetailMode = .viewing)
    -> FiscalInformationDetailViewModel
  {
    return factory(
      item,
      mode
    )
  }
}

extension FiscalInformationDetailViewModel {
  internal typealias Factory = InjectedFactory<_FiscalInformationDetailViewModelFactory>
}

internal typealias _FiscalInformationDetailViewModelSecondFactory = (
  _ service: DetailService<FiscalInformation>
) -> FiscalInformationDetailViewModel

extension InjectedFactory where T == _FiscalInformationDetailViewModelSecondFactory {

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

extension InjectedFactory where T == _GeneralSettingsViewModelFactory {
  @MainActor
  func make() -> GeneralSettingsViewModel {
    return factory()
  }
}

extension GeneralSettingsViewModel {
  internal typealias Factory = InjectedFactory<_GeneralSettingsViewModelFactory>
}

internal typealias _GravatarIconViewModelFactory = (
  _ email: String,
  _ iconLibrary: GravatarIconLibraryProtocol
) -> GravatarIconViewModel

extension InjectedFactory where T == _GravatarIconViewModelFactory {

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

internal typealias _GravatarIconViewModelSecondFactory = (
  _ email: String
) -> GravatarIconViewModel

extension InjectedFactory where T == _GravatarIconViewModelSecondFactory {

  func make(email: String) -> GravatarIconViewModel {
    return factory(
      email
    )
  }
}

extension GravatarIconViewModel {
  internal typealias SecondFactory = InjectedFactory<_GravatarIconViewModelSecondFactory>
}

internal typealias _GuidedOnboardingFlowViewModelFactory = (
  _ navigator: DashlaneNavigationController?,
  _ completion: @escaping () -> Void
) -> GuidedOnboardingFlowViewModel

extension InjectedFactory where T == _GuidedOnboardingFlowViewModelFactory {

  func make(navigator: DashlaneNavigationController? = nil, completion: @escaping () -> Void)
    -> GuidedOnboardingFlowViewModel
  {
    return factory(
      navigator,
      completion
    )
  }
}

extension GuidedOnboardingFlowViewModel {
  internal typealias Factory = InjectedFactory<_GuidedOnboardingFlowViewModelFactory>
}

internal typealias _GuidedOnboardingViewModelFactory = (
  _ guidedOnboardingService: GuidedOnboardingService,
  _ step: GuidedOnboardingSurveyStep,
  _ completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
) -> GuidedOnboardingViewModel

extension InjectedFactory where T == _GuidedOnboardingViewModelFactory {

  func make(
    guidedOnboardingService: GuidedOnboardingService, step: GuidedOnboardingSurveyStep,
    completion: ((GuidedOnboardingViewModelCompletion) -> Void)?
  ) -> GuidedOnboardingViewModel {
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

internal typealias _HelpCenterSettingsViewModelFactory = (
) -> HelpCenterSettingsViewModel

extension InjectedFactory where T == _HelpCenterSettingsViewModelFactory {

  func make() -> HelpCenterSettingsViewModel {
    return factory()
  }
}

extension HelpCenterSettingsViewModel {
  internal typealias Factory = InjectedFactory<_HelpCenterSettingsViewModelFactory>
}

internal typealias _HomeBottomBannerViewModelFactory = @MainActor (
  _ action: @escaping (VaultFlowViewModel.Action) -> Void,
  _ onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
) -> HomeBottomBannerViewModel

extension InjectedFactory where T == _HomeBottomBannerViewModelFactory {
  @MainActor
  func make(
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
  ) -> HomeBottomBannerViewModel {
    return factory(
      action,
      onboardingAction
    )
  }
}

extension HomeBottomBannerViewModel {
  internal typealias Factory = InjectedFactory<_HomeBottomBannerViewModelFactory>
}

internal typealias _HomeFlowViewModelFactory = @MainActor (
) -> HomeFlowViewModel

extension InjectedFactory where T == _HomeFlowViewModelFactory {
  @MainActor
  func make() -> HomeFlowViewModel {
    return factory()
  }
}

extension HomeFlowViewModel {
  internal typealias Factory = InjectedFactory<_HomeFlowViewModelFactory>
}

internal typealias _HomeListViewModelFactory = @MainActor (
  _ onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
  _ action: @escaping (VaultFlowViewModel.Action) -> Void,
  _ completion: @escaping (VaultListCompletion) -> Void
) -> HomeListViewModel

extension InjectedFactory where T == _HomeListViewModelFactory {
  @MainActor
  func make(
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> HomeListViewModel {
    return factory(
      onboardingAction,
      action,
      completion
    )
  }
}

extension HomeListViewModel {
  internal typealias Factory = InjectedFactory<_HomeListViewModelFactory>
}

internal typealias _HomeViewModelFactory = @MainActor (
  _ onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
  _ action: @escaping (VaultFlowViewModel.Action) -> Void
) -> HomeViewModel

extension InjectedFactory where T == _HomeViewModelFactory {
  @MainActor
  func make(
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void
  ) -> HomeViewModel {
    return factory(
      onboardingAction,
      action
    )
  }
}

extension HomeViewModel {
  internal typealias Factory = InjectedFactory<_HomeViewModelFactory>
}

internal typealias _IDCardDetailViewModelFactory = (
  _ item: IDCard,
  _ mode: DetailMode
) -> IDCardDetailViewModel

extension InjectedFactory where T == _IDCardDetailViewModelFactory {

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

internal typealias _IDCardDetailViewModelSecondFactory = (
  _ service: DetailService<IDCard>
) -> IDCardDetailViewModel

extension InjectedFactory where T == _IDCardDetailViewModelSecondFactory {

  func make(service: DetailService<IDCard>) -> IDCardDetailViewModel {
    return factory(
      service
    )
  }
}

extension IDCardDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_IDCardDetailViewModelSecondFactory>
}

internal typealias _IdentityBreachAlertViewModelFactory = (
  _ breachesToPresent: [PopupAlertProtocol]
) -> IdentityBreachAlertViewModel

extension InjectedFactory where T == _IdentityBreachAlertViewModelFactory {

  func make(breachesToPresent: [PopupAlertProtocol]) -> IdentityBreachAlertViewModel {
    return factory(
      breachesToPresent
    )
  }
}

extension IdentityBreachAlertViewModel {
  internal typealias Factory = InjectedFactory<_IdentityBreachAlertViewModelFactory>
}

internal typealias _IdentityDetailViewModelFactory = (
  _ item: Identity,
  _ mode: DetailMode
) -> IdentityDetailViewModel

extension InjectedFactory where T == _IdentityDetailViewModelFactory {

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

internal typealias _IdentityDetailViewModelSecondFactory = (
  _ service: DetailService<Identity>
) -> IdentityDetailViewModel

extension InjectedFactory where T == _IdentityDetailViewModelSecondFactory {

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

extension InjectedFactory where T == _ImportMethodFlowViewModelFactory {
  @MainActor
  func make(
    mode: ImportMethodMode, completion: @escaping (ImportMethodFlowViewModel.Completion) -> Void
  ) -> ImportMethodFlowViewModel {
    return factory(
      mode,
      completion
    )
  }
}

extension ImportMethodFlowViewModel {
  internal typealias Factory = InjectedFactory<_ImportMethodFlowViewModelFactory>
}

internal typealias _ImportMethodViewModelFactory = (
  _ importService: ImportMethodServiceProtocol,
  _ completion: @escaping (ImportMethodCompletion) -> Void
) -> ImportMethodViewModel

extension InjectedFactory where T == _ImportMethodViewModelFactory {

  func make(
    importService: ImportMethodServiceProtocol,
    completion: @escaping (ImportMethodCompletion) -> Void
  ) -> ImportMethodViewModel {
    return factory(
      importService,
      completion
    )
  }
}

extension ImportMethodViewModel {
  internal typealias Factory = InjectedFactory<_ImportMethodViewModelFactory>
}

internal typealias _LabsSettingsViewModelFactory = @MainActor (
) -> LabsSettingsViewModel

extension InjectedFactory where T == _LabsSettingsViewModelFactory {
  @MainActor
  func make() -> LabsSettingsViewModel {
    return factory()
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

extension InjectedFactory where T == _LockViewModelFactory {
  @MainActor
  func make(
    locker: ScreenLocker, newMasterPassword: String? = nil,
    changeMasterPasswordLauncher: @escaping ChangeMasterPasswordLauncher
  ) -> LockViewModel {
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

public typealias _LoginKitServicesContainerFactory = (
  _ sessionCryptoEngineProvider: CryptoEngineProvider
) -> LoginKitServicesContainer

extension InjectedFactory where T == _LoginKitServicesContainerFactory {

  public func make(sessionCryptoEngineProvider: CryptoEngineProvider) -> LoginKitServicesContainer {
    return factory(
      sessionCryptoEngineProvider
    )
  }
}

extension LoginKitServicesContainer {
  public typealias Factory = InjectedFactory<_LoginKitServicesContainerFactory>
}

internal typealias _M2WSettingsFactory = (
) -> M2WSettings

extension InjectedFactory where T == _M2WSettingsFactory {

  func make() -> M2WSettings {
    return factory()
  }
}

extension M2WSettings {
  internal typealias Factory = InjectedFactory<_M2WSettingsFactory>
}

internal typealias _MainSettingsViewModelFactory = @MainActor (
) -> MainSettingsViewModel

extension InjectedFactory where T == _MainSettingsViewModelFactory {
  @MainActor
  func make() -> MainSettingsViewModel {
    return factory()
  }
}

extension MainSettingsViewModel {
  internal typealias Factory = InjectedFactory<_MainSettingsViewModelFactory>
}

internal typealias _MasterPasswordAccountCreationFlowViewModelFactory = @MainActor (
  _ configuration: AccountCreationConfiguration,
  _ completion: @MainActor @escaping (MasterPasswordAccountCreationFlowViewModel.CompletionResult)
    -> Void
) -> MasterPasswordAccountCreationFlowViewModel

extension InjectedFactory where T == _MasterPasswordAccountCreationFlowViewModelFactory {
  @MainActor
  func make(
    configuration: AccountCreationConfiguration,
    completion: @MainActor @escaping (MasterPasswordAccountCreationFlowViewModel.CompletionResult)
      -> Void
  ) -> MasterPasswordAccountCreationFlowViewModel {
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

extension InjectedFactory where T == _MasterPasswordResetActivationViewModelFactory {
  @MainActor
  func make(
    masterPassword: String,
    actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
  ) -> MasterPasswordResetActivationViewModel {
    return factory(
      masterPassword,
      actionHandler
    )
  }
}

extension MasterPasswordResetActivationViewModel {
  internal typealias Factory = InjectedFactory<_MasterPasswordResetActivationViewModelFactory>
}

internal typealias _MatchingCredentialListViewModelFactory = (
  _ website: String,
  _ matchingCredentials: [Credential],
  _ completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void
) -> MatchingCredentialListViewModel

extension InjectedFactory where T == _MatchingCredentialListViewModelFactory {

  func make(
    website: String, matchingCredentials: [Credential],
    completion: @escaping (MatchingCredentialListViewModel.Completion) -> Void
  ) -> MatchingCredentialListViewModel {
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

internal typealias _MigrationProgressViewModelFactory = (
  _ type: MigrationType,
  _ accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
  _ context: MigrationProgressViewModel.Context,
  _ isProgress: Bool,
  _ isSuccess: Bool,
  _ completion: @escaping (Result<Session, Error>) -> Void
) -> MigrationProgressViewModel

extension InjectedFactory where T == _MigrationProgressViewModelFactory {

  func make(
    type: MigrationType, accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    context: MigrationProgressViewModel.Context, isProgress: Bool = true, isSuccess: Bool = true,
    completion: @escaping (Result<Session, Error>) -> Void
  ) -> MigrationProgressViewModel {
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

internal typealias _NotesSectionModelFactory = (
  _ service: DetailService<Credential>
) -> NotesSectionModel

extension InjectedFactory where T == _NotesSectionModelFactory {

  func make(service: DetailService<Credential>) -> NotesSectionModel {
    return factory(
      service
    )
  }
}

extension NotesSectionModel {
  internal typealias Factory = InjectedFactory<_NotesSectionModelFactory>
}

internal typealias _NotificationCenterServiceFactory = (
) -> NotificationCenterService

extension InjectedFactory where T == _NotificationCenterServiceFactory {

  func make() -> NotificationCenterService {
    return factory()
  }
}

extension NotificationCenterService {
  internal typealias Factory = InjectedFactory<_NotificationCenterServiceFactory>
}

internal typealias _NotificationsFlowViewModelFactory = @MainActor (
) -> NotificationsFlowViewModel

extension InjectedFactory where T == _NotificationsFlowViewModelFactory {
  @MainActor
  func make() -> NotificationsFlowViewModel {
    return factory()
  }
}

extension NotificationsFlowViewModel {
  internal typealias Factory = InjectedFactory<_NotificationsFlowViewModelFactory>
}

internal typealias _NotificationsFlowViewModelSecondFactory = @MainActor (
  _ notificationCenterService: NotificationCenterServiceProtocol
) -> NotificationsFlowViewModel

extension InjectedFactory where T == _NotificationsFlowViewModelSecondFactory {
  @MainActor
  func make(notificationCenterService: NotificationCenterServiceProtocol)
    -> NotificationsFlowViewModel
  {
    return factory(
      notificationCenterService
    )
  }
}

extension NotificationsFlowViewModel {
  internal typealias SecondFactory = InjectedFactory<_NotificationsFlowViewModelSecondFactory>
}

internal typealias _NotificationsListViewModelFactory = (
  _ notificationCenterService: NotificationCenterServiceProtocol
) -> NotificationsListViewModel

extension InjectedFactory where T == _NotificationsListViewModelFactory {

  func make(notificationCenterService: NotificationCenterServiceProtocol)
    -> NotificationsListViewModel
  {
    return factory(
      notificationCenterService
    )
  }
}

extension NotificationsListViewModel {
  internal typealias Factory = InjectedFactory<_NotificationsListViewModelFactory>
}

internal typealias _OTPExplorerViewModelFactory = (
  _ otpSupportedDomainsRepository: OTPSupportedDomainsRepository,
  _ actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void
) -> OTPExplorerViewModel

extension InjectedFactory where T == _OTPExplorerViewModelFactory {

  func make(
    otpSupportedDomainsRepository: OTPSupportedDomainsRepository,
    actionHandler: @escaping (OTPExplorerViewModel.Action) -> Void
  ) -> OTPExplorerViewModel {
    return factory(
      otpSupportedDomainsRepository,
      actionHandler
    )
  }
}

extension OTPExplorerViewModel {
  internal typealias Factory = InjectedFactory<_OTPExplorerViewModelFactory>
}

internal typealias _OTPTokenListViewModelFactory = @MainActor (
  _ actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void
) -> OTPTokenListViewModel

extension InjectedFactory where T == _OTPTokenListViewModelFactory {
  @MainActor
  func make(actionHandler: @escaping (OTPTokenListViewModel.Action) -> Void)
    -> OTPTokenListViewModel
  {
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

extension InjectedFactory where T == _OnboardingChecklistFlowViewModelFactory {
  @MainActor
  func make(
    displayMode: OnboardingChecklistFlowViewModel.DisplayMode,
    onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil,
    completion: @escaping (OnboardingChecklistFlowViewModel.Completion) -> Void
  ) -> OnboardingChecklistFlowViewModel {
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

internal typealias _OnboardingChecklistViewModelFactory = @MainActor (
  _ action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void
) -> OnboardingChecklistViewModel

extension InjectedFactory where T == _OnboardingChecklistViewModelFactory {
  @MainActor
  func make(action: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void)
    -> OnboardingChecklistViewModel
  {
    return factory(
      action
    )
  }
}

extension OnboardingChecklistViewModel {
  internal typealias Factory = InjectedFactory<_OnboardingChecklistViewModelFactory>
}

internal typealias _PasskeyDetailViewModelFactory = @MainActor (
  _ item: CorePersonalData.Passkey,
  _ mode: DetailMode,
  _ dismiss: (() -> Void)?
) -> PasskeyDetailViewModel

extension InjectedFactory where T == _PasskeyDetailViewModelFactory {
  @MainActor
  func make(
    item: CorePersonalData.Passkey, mode: DetailMode = .viewing, dismiss: (() -> Void)? = nil
  ) -> PasskeyDetailViewModel {
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

internal typealias _PasskeyDetailViewModelSecondFactory = @MainActor (
  _ service: DetailService<CorePersonalData.Passkey>
) -> PasskeyDetailViewModel

extension InjectedFactory where T == _PasskeyDetailViewModelSecondFactory {
  @MainActor
  func make(service: DetailService<CorePersonalData.Passkey>) -> PasskeyDetailViewModel {
    return factory(
      service
    )
  }
}

extension PasskeyDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_PasskeyDetailViewModelSecondFactory>
}

internal typealias _PassportDetailViewModelFactory = (
  _ item: Passport,
  _ mode: DetailMode
) -> PassportDetailViewModel

extension InjectedFactory where T == _PassportDetailViewModelFactory {

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

internal typealias _PassportDetailViewModelSecondFactory = (
  _ service: DetailService<Passport>
) -> PassportDetailViewModel

extension InjectedFactory where T == _PassportDetailViewModelSecondFactory {

  func make(service: DetailService<Passport>) -> PassportDetailViewModel {
    return factory(
      service
    )
  }
}

extension PassportDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_PassportDetailViewModelSecondFactory>
}

internal typealias _PasswordAccessorySectionModelFactory = (
  _ service: DetailService<Credential>
) -> PasswordAccessorySectionModel

extension InjectedFactory where T == _PasswordAccessorySectionModelFactory {

  func make(service: DetailService<Credential>) -> PasswordAccessorySectionModel {
    return factory(
      service
    )
  }
}

extension PasswordAccessorySectionModel {
  internal typealias Factory = InjectedFactory<_PasswordAccessorySectionModelFactory>
}

internal typealias _PasswordGeneratorHistoryViewModelFactory = (
) -> PasswordGeneratorHistoryViewModel

extension InjectedFactory where T == _PasswordGeneratorHistoryViewModelFactory {

  func make() -> PasswordGeneratorHistoryViewModel {
    return factory()
  }
}

extension PasswordGeneratorHistoryViewModel {
  internal typealias Factory = InjectedFactory<_PasswordGeneratorHistoryViewModelFactory>
}

internal typealias _PasswordGeneratorToolsFlowViewModelFactory = @MainActor (
) -> PasswordGeneratorToolsFlowViewModel

extension InjectedFactory where T == _PasswordGeneratorToolsFlowViewModelFactory {
  @MainActor
  func make() -> PasswordGeneratorToolsFlowViewModel {
    return factory()
  }
}

extension PasswordGeneratorToolsFlowViewModel {
  internal typealias Factory = InjectedFactory<_PasswordGeneratorToolsFlowViewModelFactory>
}

public typealias _PasswordGeneratorViewModelFactory = (
  _ mode: PasswordGeneratorMode,
  _ saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
  _ savePreferencesOnChange: Bool,
  _ copyAction: @escaping (String) -> Void
) -> PasswordGeneratorViewModel

extension InjectedFactory where T == _PasswordGeneratorViewModelFactory {

  public func make(
    mode: PasswordGeneratorMode,
    saveGeneratedPassword: @escaping (GeneratedPassword) -> GeneratedPassword,
    savePreferencesOnChange: Bool = true, copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
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

public typealias _PasswordGeneratorViewModelSecondFactory = (
  _ mode: PasswordGeneratorMode,
  _ savePreferencesOnChange: Bool,
  _ copyAction: @escaping (String) -> Void
) -> PasswordGeneratorViewModel

extension InjectedFactory where T == _PasswordGeneratorViewModelSecondFactory {

  public func make(
    mode: PasswordGeneratorMode, savePreferencesOnChange: Bool = true,
    copyAction: @escaping (String) -> Void
  ) -> PasswordGeneratorViewModel {
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

public typealias _PasswordGeneratorViewModelThirdFactory = (
  _ mode: PasswordGeneratorMode,
  _ copyAction: @escaping (String) -> Void
) -> PasswordGeneratorViewModel

extension InjectedFactory where T == _PasswordGeneratorViewModelThirdFactory {

  public func make(mode: PasswordGeneratorMode, copyAction: @escaping (String) -> Void)
    -> PasswordGeneratorViewModel
  {
    return factory(
      mode,
      copyAction
    )
  }
}

extension PasswordGeneratorViewModel {
  public typealias ThirdFactory = InjectedFactory<_PasswordGeneratorViewModelThirdFactory>
}

internal typealias _PasswordHealthDetailedListViewModelFactory = (
  _ kind: PasswordHealthKind,
  _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthDetailedListViewModel

extension InjectedFactory where T == _PasswordHealthDetailedListViewModelFactory {

  func make(kind: PasswordHealthKind, origin: PasswordHealthFlowViewModel.Origin)
    -> PasswordHealthDetailedListViewModel
  {
    return factory(
      kind,
      origin
    )
  }
}

extension PasswordHealthDetailedListViewModel {
  internal typealias Factory = InjectedFactory<_PasswordHealthDetailedListViewModelFactory>
}

internal typealias _PasswordHealthFlowViewModelFactory = @MainActor (
  _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthFlowViewModel

extension InjectedFactory where T == _PasswordHealthFlowViewModelFactory {
  @MainActor
  func make(origin: PasswordHealthFlowViewModel.Origin) -> PasswordHealthFlowViewModel {
    return factory(
      origin
    )
  }
}

extension PasswordHealthFlowViewModel {
  internal typealias Factory = InjectedFactory<_PasswordHealthFlowViewModelFactory>
}

internal typealias _PasswordHealthListRowViewFactory = (
  _ item: Credential,
  _ exclude: @escaping () -> Void,
  _ replace: @escaping () -> Void,
  _ detail: @escaping (Credential) -> Void
) -> PasswordHealthListRowView

extension InjectedFactory where T == _PasswordHealthListRowViewFactory {

  func make(
    item: Credential, exclude: @escaping () -> Void, replace: @escaping () -> Void,
    detail: @escaping (Credential) -> Void
  ) -> PasswordHealthListRowView {
    return factory(
      item,
      exclude,
      replace,
      detail
    )
  }
}

extension PasswordHealthListRowView {
  internal typealias Factory = InjectedFactory<_PasswordHealthListRowViewFactory>
}

internal typealias _PasswordHealthListViewModelFactory = (
  _ kind: PasswordHealthKind,
  _ maximumCredentialsCount: Int?,
  _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthListViewModel

extension InjectedFactory where T == _PasswordHealthListViewModelFactory {

  func make(
    kind: PasswordHealthKind, maximumCredentialsCount: Int? = nil,
    origin: PasswordHealthFlowViewModel.Origin
  ) -> PasswordHealthListViewModel {
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

internal typealias _PasswordHealthSectionModelFactory = (
  _ service: DetailService<Credential>
) -> PasswordHealthSectionModel

extension InjectedFactory where T == _PasswordHealthSectionModelFactory {

  func make(service: DetailService<Credential>) -> PasswordHealthSectionModel {
    return factory(
      service
    )
  }
}

extension PasswordHealthSectionModel {
  internal typealias Factory = InjectedFactory<_PasswordHealthSectionModelFactory>
}

internal typealias _PasswordHealthViewModelFactory = @MainActor (
  _ origin: PasswordHealthFlowViewModel.Origin
) -> PasswordHealthViewModel

extension InjectedFactory where T == _PasswordHealthViewModelFactory {
  @MainActor
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
  _ completion: @MainActor @escaping (PasswordLessAccountCreationFlowViewModel.CompletionResult) ->
    Void
) -> PasswordLessAccountCreationFlowViewModel

extension InjectedFactory where T == _PasswordLessAccountCreationFlowViewModelFactory {
  @MainActor
  func make(
    configuration: AccountCreationConfiguration,
    completion: @MainActor @escaping (PasswordLessAccountCreationFlowViewModel.CompletionResult) ->
      Void
  ) -> PasswordLessAccountCreationFlowViewModel {
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

extension InjectedFactory where T == _PasswordLessCompletionViewModelFactory {
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

internal typealias _PhoneDetailViewModelFactory = (
  _ item: Phone,
  _ mode: DetailMode
) -> PhoneDetailViewModel

extension InjectedFactory where T == _PhoneDetailViewModelFactory {

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

internal typealias _PhoneDetailViewModelSecondFactory = (
  _ service: DetailService<Phone>
) -> PhoneDetailViewModel

extension InjectedFactory where T == _PhoneDetailViewModelSecondFactory {

  func make(service: DetailService<Phone>) -> PhoneDetailViewModel {
    return factory(
      service
    )
  }
}

extension PhoneDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_PhoneDetailViewModelSecondFactory>
}

internal typealias _PinCodeSettingsViewModelFactory = (
  _ actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void
) -> PinCodeSettingsViewModel

extension InjectedFactory where T == _PinCodeSettingsViewModelFactory {

  func make(actionHandler: @escaping (PinCodeSettingsViewModel.Action) -> Void)
    -> PinCodeSettingsViewModel
  {
    return factory(
      actionHandler
    )
  }
}

extension PinCodeSettingsViewModel {
  internal typealias Factory = InjectedFactory<_PinCodeSettingsViewModelFactory>
}

public typealias _PlaceholderWebsiteViewModelFactory = (
  _ website: String
) -> PlaceholderWebsiteViewModel

extension InjectedFactory where T == _PlaceholderWebsiteViewModelFactory {

  public func make(website: String) -> PlaceholderWebsiteViewModel {
    return factory(
      website
    )
  }
}

extension PlaceholderWebsiteViewModel {
  public typealias Factory = InjectedFactory<_PlaceholderWebsiteViewModelFactory>
}

internal typealias _PostARKChangeMasterPasswordViewModelFactory = @MainActor (
  _ accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
  _ completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void
) -> PostARKChangeMasterPasswordViewModel

extension InjectedFactory where T == _PostARKChangeMasterPasswordViewModelFactory {
  @MainActor
  func make(
    accountCryptoChangerService: AccountCryptoChangerServiceProtocol,
    completion: @escaping (PostARKChangeMasterPasswordViewModel.Completion) -> Void
  ) -> PostARKChangeMasterPasswordViewModel {
    return factory(
      accountCryptoChangerService,
      completion
    )
  }
}

extension PostARKChangeMasterPasswordViewModel {
  internal typealias Factory = InjectedFactory<_PostARKChangeMasterPasswordViewModelFactory>
}

public typealias _PremiumAnnouncementsViewModelFactory = @MainActor (
  _ excludedAnnouncements: Set<PremiumAnnouncement>
) -> PremiumAnnouncementsViewModel

extension InjectedFactory where T == _PremiumAnnouncementsViewModelFactory {
  @MainActor
  public func make(excludedAnnouncements: Set<PremiumAnnouncement> = [])
    -> PremiumAnnouncementsViewModel
  {
    return factory(
      excludedAnnouncements
    )
  }
}

extension PremiumAnnouncementsViewModel {
  public typealias Factory = InjectedFactory<_PremiumAnnouncementsViewModelFactory>
}

internal typealias _QuickActionsMenuViewModelFactory = @MainActor (
  _ item: VaultItem,
  _ origin: ActionableVaultItemRowViewModel.Origin,
  _ isSuggestedItem: Bool
) -> QuickActionsMenuViewModel

extension InjectedFactory where T == _QuickActionsMenuViewModelFactory {
  @MainActor
  func make(item: VaultItem, origin: ActionableVaultItemRowViewModel.Origin, isSuggestedItem: Bool)
    -> QuickActionsMenuViewModel
  {
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

internal typealias _RememberMasterPasswordToggleViewModelFactory = (
  _ actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void
) -> RememberMasterPasswordToggleViewModel

extension InjectedFactory where T == _RememberMasterPasswordToggleViewModelFactory {

  func make(actionHandler: @escaping (RememberMasterPasswordToggleViewModel.Action) -> Void)
    -> RememberMasterPasswordToggleViewModel
  {
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

extension InjectedFactory where T == _ResetMasterPasswordNotificationRowViewModelFactory {
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

internal typealias _SSOEnableBiometricsOrPinViewModelFactory = (
) -> SSOEnableBiometricsOrPinViewModel

extension InjectedFactory where T == _SSOEnableBiometricsOrPinViewModelFactory {

  func make() -> SSOEnableBiometricsOrPinViewModel {
    return factory()
  }
}

extension SSOEnableBiometricsOrPinViewModel {
  internal typealias Factory = InjectedFactory<_SSOEnableBiometricsOrPinViewModelFactory>
}

internal typealias _SecretDetailViewModelFactory = (
  _ item: Secret,
  _ mode: DetailMode
) -> SecretDetailViewModel

extension InjectedFactory where T == _SecretDetailViewModelFactory {

  func make(item: Secret, mode: DetailMode = .viewing) -> SecretDetailViewModel {
    return factory(
      item,
      mode
    )
  }
}

extension SecretDetailViewModel {
  internal typealias Factory = InjectedFactory<_SecretDetailViewModelFactory>
}

internal typealias _SecretDetailViewModelSecondFactory = (
  _ service: DetailService<Secret>
) -> SecretDetailViewModel

extension InjectedFactory where T == _SecretDetailViewModelSecondFactory {

  func make(service: DetailService<Secret>) -> SecretDetailViewModel {
    return factory(
      service
    )
  }
}

extension SecretDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_SecretDetailViewModelSecondFactory>
}

internal typealias _SecureArchiveSectionContentViewModelFactory = (
) -> SecureArchiveSectionContentViewModel

extension InjectedFactory where T == _SecureArchiveSectionContentViewModelFactory {

  func make() -> SecureArchiveSectionContentViewModel {
    return factory()
  }
}

extension SecureArchiveSectionContentViewModel {
  internal typealias Factory = InjectedFactory<_SecureArchiveSectionContentViewModelFactory>
}

internal typealias _SecureLockNotificationRowViewModelFactory = (
  _ notification: DashlaneNotification
) -> SecureLockNotificationRowViewModel

extension InjectedFactory where T == _SecureLockNotificationRowViewModelFactory {

  func make(notification: DashlaneNotification) -> SecureLockNotificationRowViewModel {
    return factory(
      notification
    )
  }
}

extension SecureLockNotificationRowViewModel {
  internal typealias Factory = InjectedFactory<_SecureLockNotificationRowViewModelFactory>
}

internal typealias _SecureNotesDetailFieldsModelFactory = (
  _ service: DetailService<SecureNote>
) -> SecureNotesDetailFieldsModel

extension InjectedFactory where T == _SecureNotesDetailFieldsModelFactory {

  func make(service: DetailService<SecureNote>) -> SecureNotesDetailFieldsModel {
    return factory(
      service
    )
  }
}

extension SecureNotesDetailFieldsModel {
  internal typealias Factory = InjectedFactory<_SecureNotesDetailFieldsModelFactory>
}

internal typealias _SecureNotesDetailNavigationBarModelFactory = (
  _ service: DetailService<SecureNote>,
  _ isEditingContent: FocusState<Bool>.Binding
) -> SecureNotesDetailNavigationBarModel

extension InjectedFactory where T == _SecureNotesDetailNavigationBarModelFactory {

  func make(service: DetailService<SecureNote>, isEditingContent: FocusState<Bool>.Binding)
    -> SecureNotesDetailNavigationBarModel
  {
    return factory(
      service,
      isEditingContent
    )
  }
}

extension SecureNotesDetailNavigationBarModel {
  internal typealias Factory = InjectedFactory<_SecureNotesDetailNavigationBarModelFactory>
}

internal typealias _SecureNotesDetailToolbarModelFactory = (
  _ service: DetailService<SecureNote>
) -> SecureNotesDetailToolbarModel

extension InjectedFactory where T == _SecureNotesDetailToolbarModelFactory {

  func make(service: DetailService<SecureNote>) -> SecureNotesDetailToolbarModel {
    return factory(
      service
    )
  }
}

extension SecureNotesDetailToolbarModel {
  internal typealias Factory = InjectedFactory<_SecureNotesDetailToolbarModelFactory>
}

internal typealias _SecureNotesDetailViewModelFactory = (
  _ item: SecureNote,
  _ mode: DetailMode
) -> SecureNotesDetailViewModel

extension InjectedFactory where T == _SecureNotesDetailViewModelFactory {

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

internal typealias _SecureNotesDetailViewModelSecondFactory = (
  _ service: DetailService<SecureNote>
) -> SecureNotesDetailViewModel

extension InjectedFactory where T == _SecureNotesDetailViewModelSecondFactory {

  func make(service: DetailService<SecureNote>) -> SecureNotesDetailViewModel {
    return factory(
      service
    )
  }
}

extension SecureNotesDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_SecureNotesDetailViewModelSecondFactory>
}

internal typealias _SecurityAlertNotificationRowViewModelFactory = (
  _ notification: DashlaneNotification
) -> SecurityAlertNotificationRowViewModel

extension InjectedFactory where T == _SecurityAlertNotificationRowViewModelFactory {

  func make(notification: DashlaneNotification) -> SecurityAlertNotificationRowViewModel {
    return factory(
      notification
    )
  }
}

extension SecurityAlertNotificationRowViewModel {
  internal typealias Factory = InjectedFactory<_SecurityAlertNotificationRowViewModelFactory>
}

internal typealias _SecurityChallengeFlowModelFactory = @MainActor (
  _ login: String,
  _ transfer: PendingTransfer,
  _ senderSecurityChallengeService: SenderSecurityChallengeService,
  _ completion: @escaping (SecurityChallengeFlowModel.CompletionType) -> Void
) -> SecurityChallengeFlowModel

extension InjectedFactory where T == _SecurityChallengeFlowModelFactory {
  @MainActor
  func make(
    login: String, transfer: PendingTransfer,
    senderSecurityChallengeService: SenderSecurityChallengeService,
    completion: @escaping (SecurityChallengeFlowModel.CompletionType) -> Void
  ) -> SecurityChallengeFlowModel {
    return factory(
      login,
      transfer,
      senderSecurityChallengeService,
      completion
    )
  }
}

extension SecurityChallengeFlowModel {
  internal typealias Factory = InjectedFactory<_SecurityChallengeFlowModelFactory>
}

internal typealias _SecuritySettingsViewModelFactory = @MainActor (
) -> SecuritySettingsViewModel

extension InjectedFactory where T == _SecuritySettingsViewModelFactory {
  @MainActor
  func make() -> SecuritySettingsViewModel {
    return factory()
  }
}

extension SecuritySettingsViewModel {
  internal typealias Factory = InjectedFactory<_SecuritySettingsViewModelFactory>
}

internal typealias _SettingsAccountSectionViewModelFactory = @MainActor (
  _ actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void
) -> SettingsAccountSectionViewModel

extension InjectedFactory where T == _SettingsAccountSectionViewModelFactory {
  @MainActor
  func make(actionHandler: @escaping (MasterPasswordResetActivationViewModel.Action) -> Void)
    -> SettingsAccountSectionViewModel
  {
    return factory(
      actionHandler
    )
  }
}

extension SettingsAccountSectionViewModel {
  internal typealias Factory = InjectedFactory<_SettingsAccountSectionViewModelFactory>
}

internal typealias _SettingsBiometricToggleViewModelFactory = (
  _ actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void
) -> SettingsBiometricToggleViewModel

extension InjectedFactory where T == _SettingsBiometricToggleViewModelFactory {

  func make(actionHandler: @escaping (SettingsBiometricToggleViewModel.Action) -> Void)
    -> SettingsBiometricToggleViewModel
  {
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

extension InjectedFactory where T == _SettingsFlowViewModelFactory {
  @MainActor
  func make() -> SettingsFlowViewModel {
    return factory()
  }
}

extension SettingsFlowViewModel {
  internal typealias Factory = InjectedFactory<_SettingsFlowViewModelFactory>
}

internal typealias _SettingsLockSectionViewModelFactory = (
) -> SettingsLockSectionViewModel

extension InjectedFactory where T == _SettingsLockSectionViewModelFactory {

  func make() -> SettingsLockSectionViewModel {
    return factory()
  }
}

extension SettingsLockSectionViewModel {
  internal typealias Factory = InjectedFactory<_SettingsLockSectionViewModelFactory>
}

internal typealias _SettingsStatusSectionViewModelFactory = @MainActor (
) -> SettingsStatusSectionViewModel

extension InjectedFactory where T == _SettingsStatusSectionViewModelFactory {
  @MainActor
  func make() -> SettingsStatusSectionViewModel {
    return factory()
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

extension InjectedFactory where T == _ShareButtonViewModelFactory {
  @MainActor
  func make(
    items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> ShareButtonViewModel {
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

extension InjectedFactory where T == _ShareFlowViewModelFactory {
  @MainActor
  func make(
    items: [VaultItem] = [], userGroupIds: Set<Identifier> = [], userEmails: Set<String> = []
  ) -> ShareFlowViewModel {
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

extension InjectedFactory where T == _ShareItemsSelectionViewModelFactory {
  @MainActor
  func make(completion: @MainActor @escaping ([VaultItem]) -> Void) -> ShareItemsSelectionViewModel
  {
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
  _ showPermissionLevelSelector: Bool,
  _ showTeamOnly: Bool,
  _ completion: @MainActor @escaping (RecipientsConfiguration) -> Void
) -> ShareRecipientsSelectionViewModel

extension InjectedFactory where T == _ShareRecipientsSelectionViewModelFactory {
  @MainActor
  func make(
    configuration: RecipientsConfiguration = .init(), showPermissionLevelSelector: Bool = true,
    showTeamOnly: Bool = false, completion: @MainActor @escaping (RecipientsConfiguration) -> Void
  ) -> ShareRecipientsSelectionViewModel {
    return factory(
      configuration,
      showPermissionLevelSelector,
      showTeamOnly,
      completion
    )
  }
}

extension ShareRecipientsSelectionViewModel {
  internal typealias Factory = InjectedFactory<_ShareRecipientsSelectionViewModelFactory>
}

internal typealias _SharingCollectionMembersDetailViewModelFactory = @MainActor (
  _ collection: VaultCollection
) -> SharingCollectionMembersDetailViewModel

extension InjectedFactory where T == _SharingCollectionMembersDetailViewModelFactory {
  @MainActor
  func make(collection: VaultCollection) -> SharingCollectionMembersDetailViewModel {
    return factory(
      collection
    )
  }
}

extension SharingCollectionMembersDetailViewModel {
  internal typealias Factory = InjectedFactory<_SharingCollectionMembersDetailViewModelFactory>
}

internal typealias _SharingDetailSectionModelFactory = @MainActor (
  _ item: VaultItem
) -> SharingDetailSectionModel

extension InjectedFactory where T == _SharingDetailSectionModelFactory {
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
  _ user: SharingEntitiesUser,
  _ userUpdatePublisher: AnyPublisher<SharingEntitiesUser, Never>,
  _ itemsProvider: SharingToolItemsProvider
) -> SharingItemsUserDetailViewModel

extension InjectedFactory where T == _SharingItemsUserDetailViewModelFactory {
  @MainActor
  func make(
    user: SharingEntitiesUser, userUpdatePublisher: AnyPublisher<SharingEntitiesUser, Never>,
    itemsProvider: SharingToolItemsProvider
  ) -> SharingItemsUserDetailViewModel {
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
  _ userGroup: SharingEntitiesUserGroup,
  _ userGroupUpdatePublisher: AnyPublisher<SharingEntitiesUserGroup, Never>,
  _ itemsProvider: SharingToolItemsProvider
) -> SharingItemsUserGroupDetailViewModel

extension InjectedFactory where T == _SharingItemsUserGroupDetailViewModelFactory {
  @MainActor
  func make(
    userGroup: SharingEntitiesUserGroup,
    userGroupUpdatePublisher: AnyPublisher<SharingEntitiesUserGroup, Never>,
    itemsProvider: SharingToolItemsProvider
  ) -> SharingItemsUserGroupDetailViewModel {
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

extension InjectedFactory where T == _SharingMembersDetailLinkModelFactory {
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

extension InjectedFactory where T == _SharingMembersDetailViewModelFactory {
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

internal typealias _SharingPendingEntitiesSectionViewModelFactory = @MainActor (
) -> SharingPendingEntitiesSectionViewModel

extension InjectedFactory where T == _SharingPendingEntitiesSectionViewModelFactory {
  @MainActor
  func make() -> SharingPendingEntitiesSectionViewModel {
    return factory()
  }
}

extension SharingPendingEntitiesSectionViewModel {
  internal typealias Factory = InjectedFactory<_SharingPendingEntitiesSectionViewModelFactory>
}

internal typealias _SharingPendingUserGroupsSectionViewModelFactory = @MainActor (
) -> SharingPendingUserGroupsSectionViewModel

extension InjectedFactory where T == _SharingPendingUserGroupsSectionViewModelFactory {
  @MainActor
  func make() -> SharingPendingUserGroupsSectionViewModel {
    return factory()
  }
}

extension SharingPendingUserGroupsSectionViewModel {
  internal typealias Factory = InjectedFactory<_SharingPendingUserGroupsSectionViewModelFactory>
}

internal typealias _SharingRequestNotificationRowViewModelFactory = (
  _ notification: DashlaneNotification
) -> SharingRequestNotificationRowViewModel

extension InjectedFactory where T == _SharingRequestNotificationRowViewModelFactory {

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

extension InjectedFactory where T == _SharingToolItemsProviderFactory {
  @MainActor
  func make() -> SharingToolItemsProvider {
    return factory()
  }
}

extension SharingToolItemsProvider {
  internal typealias Factory = InjectedFactory<_SharingToolItemsProviderFactory>
}

internal typealias _SharingToolViewModelFactory = @MainActor (
) -> SharingToolViewModel

extension InjectedFactory where T == _SharingToolViewModelFactory {
  @MainActor
  func make() -> SharingToolViewModel {
    return factory()
  }
}

extension SharingToolViewModel {
  internal typealias Factory = InjectedFactory<_SharingToolViewModelFactory>
}

internal typealias _SharingToolsFlowViewModelFactory = @MainActor (
) -> SharingToolsFlowViewModel

extension InjectedFactory where T == _SharingToolsFlowViewModelFactory {
  @MainActor
  func make() -> SharingToolsFlowViewModel {
    return factory()
  }
}

extension SharingToolsFlowViewModel {
  internal typealias Factory = InjectedFactory<_SharingToolsFlowViewModelFactory>
}

internal typealias _SharingUserGroupsSectionViewModelFactory = @MainActor (
  _ itemsProvider: SharingToolItemsProvider
) -> SharingUserGroupsSectionViewModel

extension InjectedFactory where T == _SharingUserGroupsSectionViewModelFactory {
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

extension InjectedFactory where T == _SharingUsersSectionViewModelFactory {
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

internal typealias _SidebarViewModelFactory = @MainActor (
) -> SidebarViewModel

extension InjectedFactory where T == _SidebarViewModelFactory {
  @MainActor
  func make() -> SidebarViewModel {
    return factory()
  }
}

extension SidebarViewModel {
  internal typealias Factory = InjectedFactory<_SidebarViewModelFactory>
}

internal typealias _SocialSecurityDetailViewModelFactory = (
  _ item: SocialSecurityInformation,
  _ mode: DetailMode
) -> SocialSecurityDetailViewModel

extension InjectedFactory where T == _SocialSecurityDetailViewModelFactory {

  func make(item: SocialSecurityInformation, mode: DetailMode = .viewing)
    -> SocialSecurityDetailViewModel
  {
    return factory(
      item,
      mode
    )
  }
}

extension SocialSecurityDetailViewModel {
  internal typealias Factory = InjectedFactory<_SocialSecurityDetailViewModelFactory>
}

internal typealias _SocialSecurityDetailViewModelSecondFactory = (
  _ service: DetailService<SocialSecurityInformation>
) -> SocialSecurityDetailViewModel

extension InjectedFactory where T == _SocialSecurityDetailViewModelSecondFactory {

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

extension InjectedFactory where T == _ToolsFlowViewModelFactory {
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

internal typealias _ToolsViewModelFactory = (
  _ didSelectItem: PassthroughSubject<ToolsItem, Never>
) -> ToolsViewModel

extension InjectedFactory where T == _ToolsViewModelFactory {

  func make(didSelectItem: PassthroughSubject<ToolsItem, Never>) -> ToolsViewModel {
    return factory(
      didSelectItem
    )
  }
}

extension ToolsViewModel {
  internal typealias Factory = InjectedFactory<_ToolsViewModelFactory>
}

internal typealias _TrialPeriodNotificationRowViewModelFactory = (
  _ notification: DashlaneNotification
) -> TrialPeriodNotificationRowViewModel

extension InjectedFactory where T == _TrialPeriodNotificationRowViewModelFactory {

  func make(notification: DashlaneNotification) -> TrialPeriodNotificationRowViewModel {
    return factory(
      notification
    )
  }
}

extension TrialPeriodNotificationRowViewModel {
  internal typealias Factory = InjectedFactory<_TrialPeriodNotificationRowViewModelFactory>
}

internal typealias _TwoFADeactivationViewModelFactory = @MainActor (
  _ isTwoFAEnforced: Bool
) -> TwoFADeactivationViewModel

extension InjectedFactory where T == _TwoFADeactivationViewModelFactory {
  @MainActor
  func make(isTwoFAEnforced: Bool) -> TwoFADeactivationViewModel {
    return factory(
      isTwoFAEnforced
    )
  }
}

extension TwoFADeactivationViewModel {
  internal typealias Factory = InjectedFactory<_TwoFADeactivationViewModelFactory>
}

internal typealias _TwoFASettingsViewModelFactory = @MainActor (
  _ login: Login,
  _ loginOTPOption: ThirdPartyOTPOption?,
  _ isTwoFAEnforced: Bool
) -> TwoFASettingsViewModel

extension InjectedFactory where T == _TwoFASettingsViewModelFactory {
  @MainActor
  func make(login: Login, loginOTPOption: ThirdPartyOTPOption?, isTwoFAEnforced: Bool)
    -> TwoFASettingsViewModel
  {
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

internal typealias _TwoFactorEnforcementViewModelFactory = @MainActor (
  _ logout: @escaping () -> Void
) -> TwoFactorEnforcementViewModel

extension InjectedFactory where T == _TwoFactorEnforcementViewModelFactory {
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

internal typealias _UnresolvedAlertViewModelFactory = @MainActor (
) -> UnresolvedAlertViewModel

extension InjectedFactory where T == _UnresolvedAlertViewModelFactory {
  @MainActor
  func make() -> UnresolvedAlertViewModel {
    return factory()
  }
}

extension UnresolvedAlertViewModel {
  internal typealias Factory = InjectedFactory<_UnresolvedAlertViewModelFactory>
}

internal typealias _UserConsentViewModelFactory = @MainActor (
  _ completion: @escaping (UserConsentViewModel.Completion) -> Void
) -> UserConsentViewModel

extension InjectedFactory where T == _UserConsentViewModelFactory {
  @MainActor
  func make(completion: @escaping (UserConsentViewModel.Completion) -> Void) -> UserConsentViewModel
  {
    return factory(
      completion
    )
  }
}

extension UserConsentViewModel {
  internal typealias Factory = InjectedFactory<_UserConsentViewModelFactory>
}

internal typealias _VPNActivationViewModelFactory = @MainActor (
  _ actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>,
  _ activationState: VPNActivationState
) -> VPNActivationViewModel

extension InjectedFactory where T == _VPNActivationViewModelFactory {
  @MainActor
  func make(
    actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>,
    activationState: VPNActivationState = .initial
  ) -> VPNActivationViewModel {
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

extension InjectedFactory where T == _VPNAvailableToolsFlowViewModelFactory {
  @MainActor
  func make() -> VPNAvailableToolsFlowViewModel {
    return factory()
  }
}

extension VPNAvailableToolsFlowViewModel {
  internal typealias Factory = InjectedFactory<_VPNAvailableToolsFlowViewModelFactory>
}

internal typealias _VPNMainViewModelFactory = (
  _ mode: VPNMainViewModel.VPNMainViewMode,
  _ credential: Credential?,
  _ actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>?
) -> VPNMainViewModel

extension InjectedFactory where T == _VPNMainViewModelFactory {

  func make(
    mode: VPNMainViewModel.VPNMainViewMode, credential: Credential? = nil,
    actionPublisher: PassthroughSubject<VPNAvailableToolsFlowViewModel.Action, Never>? = nil
  ) -> VPNMainViewModel {
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

internal typealias _VaultActiveSearchViewModelFactory = (
  _ searchCriteriaPublisher: AnyPublisher<String, Never>,
  _ searchResult: SearchResult,
  _ searchCategory: ItemCategory?,
  _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultActiveSearchViewModel

extension InjectedFactory where T == _VaultActiveSearchViewModelFactory {

  func make(
    searchCriteriaPublisher: AnyPublisher<String, Never>,
    searchResult: SearchResult = SearchResult(searchCriteria: "", sections: []),
    searchCategory: ItemCategory?, completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultActiveSearchViewModel {
    return factory(
      searchCriteriaPublisher,
      searchResult,
      searchCategory,
      completion
    )
  }
}

extension VaultActiveSearchViewModel {
  internal typealias Factory = InjectedFactory<_VaultActiveSearchViewModelFactory>
}

public typealias _VaultCollectionEditionServiceFactory = (
  _ collection: VaultCollection
) -> VaultCollectionEditionService

extension InjectedFactory where T == _VaultCollectionEditionServiceFactory {

  public func make(collection: VaultCollection) -> VaultCollectionEditionService {
    return factory(
      collection
    )
  }
}

extension VaultCollectionEditionService {
  public typealias Factory = InjectedFactory<_VaultCollectionEditionServiceFactory>
}

internal typealias _VaultDetailViewModelFactory = (
) -> VaultDetailViewModel

extension InjectedFactory where T == _VaultDetailViewModelFactory {

  func make() -> VaultDetailViewModel {
    return factory()
  }
}

extension VaultDetailViewModel {
  internal typealias Factory = InjectedFactory<_VaultDetailViewModelFactory>
}

internal typealias _VaultFlowViewModelFactory = @MainActor (
  _ itemCategory: ItemCategory?,
  _ onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)?
) -> VaultFlowViewModel

extension InjectedFactory where T == _VaultFlowViewModelFactory {
  @MainActor
  func make(
    itemCategory: ItemCategory? = nil,
    onboardingChecklistViewAction: ((OnboardingChecklistFlowViewModel.Action) -> Void)? = nil
  ) -> VaultFlowViewModel {
    return factory(
      itemCategory,
      onboardingChecklistViewAction
    )
  }
}

extension VaultFlowViewModel {
  internal typealias Factory = InjectedFactory<_VaultFlowViewModelFactory>
}

public typealias _VaultItemIconViewModelFactory = (
  _ item: VaultItem
) -> VaultItemIconViewModel

extension InjectedFactory where T == _VaultItemIconViewModelFactory {

  public func make(item: VaultItem) -> VaultItemIconViewModel {
    return factory(
      item
    )
  }
}

extension VaultItemIconViewModel {
  public typealias Factory = InjectedFactory<_VaultItemIconViewModelFactory>
}

public typealias _VaultItemRowFactory = (
  _ item: VaultItem,
  _ userSpace: UserSpace?
) -> VaultItemRow

extension InjectedFactory where T == _VaultItemRowFactory {

  public func make(item: VaultItem, userSpace: UserSpace?) -> VaultItemRow {
    return factory(
      item,
      userSpace
    )
  }
}

extension VaultItemRow {
  public typealias Factory = InjectedFactory<_VaultItemRowFactory>
}

internal typealias _VaultItemsListViewModelFactory = (
  _ activeFilter: ItemCategory?,
  _ activeFilterPublisher: AnyPublisher<ItemCategory?, Never>,
  _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultItemsListViewModel

extension InjectedFactory where T == _VaultItemsListViewModelFactory {

  func make(
    activeFilter: ItemCategory?, activeFilterPublisher: AnyPublisher<ItemCategory?, Never>,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultItemsListViewModel {
    return factory(
      activeFilter,
      activeFilterPublisher,
      completion
    )
  }
}

extension VaultItemsListViewModel {
  internal typealias Factory = InjectedFactory<_VaultItemsListViewModelFactory>
}

internal typealias _VaultListViewModelFactory = @MainActor (
  _ activeFilter: ItemCategory?,
  _ onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
  _ action: @escaping (VaultFlowViewModel.Action) -> Void,
  _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultListViewModel

extension InjectedFactory where T == _VaultListViewModelFactory {
  @MainActor
  func make(
    activeFilter: ItemCategory?,
    onboardingAction: @escaping (OnboardingChecklistFlowViewModel.Action) -> Void,
    action: @escaping (VaultFlowViewModel.Action) -> Void,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultListViewModel {
    return factory(
      activeFilter,
      onboardingAction,
      action,
      completion
    )
  }
}

extension VaultListViewModel {
  internal typealias Factory = InjectedFactory<_VaultListViewModelFactory>
}

internal typealias _VaultSearchViewModelFactory = @MainActor (
  _ searchCriteria: String,
  _ searchCategory: ItemCategory?,
  _ completion: @escaping (VaultListCompletion) -> Void
) -> VaultSearchViewModel

extension InjectedFactory where T == _VaultSearchViewModelFactory {
  @MainActor
  func make(
    searchCriteria: String = "", searchCategory: ItemCategory?,
    completion: @escaping (VaultListCompletion) -> Void
  ) -> VaultSearchViewModel {
    return factory(
      searchCriteria,
      searchCategory,
      completion
    )
  }
}

extension VaultSearchViewModel {
  internal typealias Factory = InjectedFactory<_VaultSearchViewModelFactory>
}

internal typealias _WebsiteDetailViewModelFactory = (
  _ item: PersonalWebsite,
  _ mode: DetailMode
) -> WebsiteDetailViewModel

extension InjectedFactory where T == _WebsiteDetailViewModelFactory {

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

internal typealias _WebsiteDetailViewModelSecondFactory = (
  _ service: DetailService<PersonalWebsite>
) -> WebsiteDetailViewModel

extension InjectedFactory where T == _WebsiteDetailViewModelSecondFactory {

  func make(service: DetailService<PersonalWebsite>) -> WebsiteDetailViewModel {
    return factory(
      service
    )
  }
}

extension WebsiteDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_WebsiteDetailViewModelSecondFactory>
}
