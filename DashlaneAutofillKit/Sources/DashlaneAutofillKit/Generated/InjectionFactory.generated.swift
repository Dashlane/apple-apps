#if canImport(AuthenticationServices)
  import AuthenticationServices
#endif
#if canImport(AutofillKit)
  import AutofillKit
#endif
#if canImport(Combine)
  import Combine
#endif
#if canImport(CoreFeature)
  import CoreFeature
#endif
#if canImport(CoreLocalization)
  import CoreLocalization
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
#if canImport(CoreTeamAuditLogs)
  import CoreTeamAuditLogs
#endif
#if canImport(CoreUserTracking)
  import UserTrackingFoundation
#endif
#if canImport(CoreTypes)
  import CoreTypes
#endif
#if canImport(DesignSystem)
  import DesignSystem
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
#if canImport(LocalAuthentication)
  import LocalAuthentication
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
#if canImport(VaultKit)
  import VaultKit
#endif

internal protocol AppServicesInjecting {}

internal protocol SessionServicesInjecting {}

extension SessionServicesContainer {
  @MainActor
  internal func makeAccessControlRequestViewModifierModel() -> AccessControlRequestViewModifierModel
  {
    return AccessControlRequestViewModifierModel(
      accessControlService: accessControlService,
      userSettings: userSettings
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAccessControlViewModel(
    mode: AccessControlViewModel.AccessMode, reason: AccessControlReason,
    completion: @escaping AccessControlCompletion
  ) -> AccessControlViewModel {
    return AccessControlViewModel(
      mode: mode,
      reason: reason,
      userSettings: userSettings,
      completion: completion
    )
  }
  @MainActor
  internal func makeAccessControlViewModel(request: AccessControlService.UserVerificationRequest)
    -> AccessControlViewModel
  {
    return AccessControlViewModel(
      request: request,
      userSettings: userSettings
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeAddCredentialViewModel(
    visitedWebsite: String?, didFinish: @escaping (Credential) -> Void
  ) -> AddCredentialViewModel {
    return AddCredentialViewModel(
      database: database,
      logger: appServices.rootLogger,
      session: session,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      pasteboardService: pasteboardService,
      passwordEvaluator: appServices.passwordEvaluator,
      activityReporter: activityReporter,
      vaultStateService: vaultStateService,
      deeplinkingService: appServices.deeplinkingService,
      domainLibrary: domainIconLibrary,
      visitedWebsite: visitedWebsite,
      userSettings: userSettings,
      teamAuditLogsService: teamAuditLogsService,
      sessionActivityReporter: activityReporter,
      autofillService: autofillService,
      didFinish: didFinish
    )
  }

}

extension SessionServicesContainer {

  internal func makeAutofillConnectedEnvironmentModel() -> AutofillConnectedEnvironmentModel {
    return AutofillConnectedEnvironmentModel(
      featureService: featureService,
      capabilitiesService: premiumStatusServicesSuit.capabilityService,
      activityReportProtocol: activityReporter,
      syncedSettings: syncedSettings
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuAddressDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Address,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuAddressDetailViewModel {
    return ContextMenuAddressDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuAddressDetailViewModel(
    service: DetailServiceContextMenuAutofill<Address>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuAddressDetailViewModel {
    return ContextMenuAddressDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuBankAccountDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: BankAccount,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuBankAccountDetailViewModel {
    return ContextMenuBankAccountDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      regionInformationService: appServices.regionInformationService,
      completion: completion
    )
  }

  internal func makeContextMenuBankAccountDetailViewModel(
    service: DetailServiceContextMenuAutofill<BankAccount>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuBankAccountDetailViewModel {
    return ContextMenuBankAccountDetailViewModel(
      service: service,
      regionInformationService: appServices.regionInformationService,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuCompanyDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Company,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCompanyDetailViewModel {
    return ContextMenuCompanyDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuCompanyDetailViewModel(
    service: DetailServiceContextMenuAutofill<Company>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCompanyDetailViewModel {
    return ContextMenuCompanyDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuCredentialDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Credential,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCredentialDetailViewModel {
    return ContextMenuCredentialDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuCredentialDetailViewModel(
    service: DetailServiceContextMenuAutofill<Credential>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCredentialDetailViewModel {
    return ContextMenuCredentialDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuCreditCardDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: CreditCard,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCreditCardDetailViewModel {
    return ContextMenuCreditCardDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuCreditCardDetailViewModel(
    service: DetailServiceContextMenuAutofill<CreditCard>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCreditCardDetailViewModel {
    return ContextMenuCreditCardDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuDetailViewModel {
    return ContextMenuDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      completion: completion,
      credentialFactory: InjectedFactory(makeContextMenuCredentialDetailViewModel),
      creditCardFactory: InjectedFactory(makeContextMenuCreditCardDetailViewModel),
      bankAccountFactory: InjectedFactory(makeContextMenuBankAccountDetailViewModel),
      identityFactory: InjectedFactory(makeContextMenuNameDetailViewModel),
      emailFactory: InjectedFactory(makeContextMenuEmailDetailViewModel),
      phoneFactory: InjectedFactory(makeContextMenuPhoneDetailViewModel),
      addressFactory: InjectedFactory(makeContextMenuAddressDetailViewModel),
      companyFactory: InjectedFactory(makeContextMenuCompanyDetailViewModel),
      websiteFactory: InjectedFactory(makeContextMenuWebsiteDetailViewModel),
      idCardFactory: InjectedFactory(makeContextMenuIDCardDetailViewModel),
      socialSecurityFactory: InjectedFactory(makeContextMenuSocialSecurityDetailViewModel),
      drivingLicenseFactory: InjectedFactory(makeContextMenuDrivingLicenseDetailViewModel),
      passportFactory: InjectedFactory(makeContextMenuPassportDetailViewModel),
      fiscalInformationFactory: InjectedFactory(makeContextMenuFiscalInformationDetailViewModel),
      secretFactory: InjectedFactory(makeContextMenuSecretDetailViewModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuDrivingLicenseDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: DrivingLicence,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuDrivingLicenseDetailViewModel {
    return ContextMenuDrivingLicenseDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuDrivingLicenseDetailViewModel(
    service: DetailServiceContextMenuAutofill<DrivingLicence>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuDrivingLicenseDetailViewModel {
    return ContextMenuDrivingLicenseDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuEmailDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: CorePersonalData.Email,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuEmailDetailViewModel {
    return ContextMenuEmailDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuEmailDetailViewModel(
    service: DetailServiceContextMenuAutofill<CorePersonalData.Email>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuEmailDetailViewModel {
    return ContextMenuEmailDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuFiscalInformationDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: FiscalInformation,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuFiscalInformationDetailViewModel {
    return ContextMenuFiscalInformationDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuFiscalInformationDetailViewModel(
    service: DetailServiceContextMenuAutofill<FiscalInformation>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuFiscalInformationDetailViewModel {
    return ContextMenuFiscalInformationDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuIDCardDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: IDCard,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuIDCardDetailViewModel {
    return ContextMenuIDCardDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuIDCardDetailViewModel(
    service: DetailServiceContextMenuAutofill<IDCard>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuIDCardDetailViewModel {
    return ContextMenuIDCardDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeContextMenuListViewModel(
    searchCriteria: String = "", activeFilter: ItemCategory?,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    completion: @escaping (ContextMenuListViewModel.Completion) -> Void
  ) -> ContextMenuListViewModel {
    return ContextMenuListViewModel(
      searchCriteria: searchCriteria,
      activeFilter: activeFilter,
      logger: appServices.rootLogger,
      database: database,
      featureService: featureService,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      teamAuditLogsService: teamAuditLogsService,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      vaultItemDatabase: vaultItemDatabase,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuNameDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Identity,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuNameDetailViewModel {
    return ContextMenuNameDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuNameDetailViewModel(
    service: DetailServiceContextMenuAutofill<Identity>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuNameDetailViewModel {
    return ContextMenuNameDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuPassportDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Passport,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPassportDetailViewModel {
    return ContextMenuPassportDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuPassportDetailViewModel(
    service: DetailServiceContextMenuAutofill<Passport>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPassportDetailViewModel {
    return ContextMenuPassportDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuPhoneDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Phone,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPhoneDetailViewModel {
    return ContextMenuPhoneDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuPhoneDetailViewModel(
    service: DetailServiceContextMenuAutofill<Phone>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPhoneDetailViewModel {
    return ContextMenuPhoneDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuSecretDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Secret,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSecretDetailViewModel {
    return ContextMenuSecretDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuSecretDetailViewModel(
    service: DetailServiceContextMenuAutofill<Secret>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSecretDetailViewModel {
    return ContextMenuSecretDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuSocialSecurityDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: SocialSecurityInformation,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSocialSecurityDetailViewModel {
    return ContextMenuSocialSecurityDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuSocialSecurityDetailViewModel(
    service: DetailServiceContextMenuAutofill<SocialSecurityInformation>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSocialSecurityDetailViewModel {
    return ContextMenuSocialSecurityDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeContextMenuVaultItemsProviderFlowModel(autofillProvider: AutofillProvider)
    -> ContextMenuVaultItemsProviderFlowModel
  {
    return ContextMenuVaultItemsProviderFlowModel(
      autofillProvider: autofillProvider,
      logger: appServices.rootLogger,
      database: database,
      featureService: featureService,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      teamAuditLogsService: teamAuditLogsService,
      vaultStateService: vaultStateService,
      accessControl: accessControlService,
      activityReporter: activityReporter,
      contextMenuListViewModelFactory: InjectedFactory(makeContextMenuListViewModel),
      detailViewModelFactory: InjectedFactory(makeContextMenuDetailViewModel),
      environmentModelFactory: InjectedFactory(makeAutofillConnectedEnvironmentModel),
      nitroEncryptionAPIClient: encryptedAPIClient,
      accessControlModelFactory: InjectedFactory(makeAccessControlRequestViewModifierModel)
    )
  }

}

extension SessionServicesContainer {

  internal func makeContextMenuWebsiteDetailViewModel(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: PersonalWebsite,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuWebsiteDetailViewModel {
    return ContextMenuWebsiteDetailViewModel(
      vaultItemDatabase: vaultItemDatabase,
      item: item,
      pasteboardService: pasteboardService,
      completion: completion
    )
  }

  internal func makeContextMenuWebsiteDetailViewModel(
    service: DetailServiceContextMenuAutofill<PersonalWebsite>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuWebsiteDetailViewModel {
    return ContextMenuWebsiteDetailViewModel(
      service: service,
      completion: completion
    )
  }

}

extension SessionServicesContainer {

  internal func makeCredentialLinkingViewModel(
    credential: Credential, visitedWebsite: String, completion: @escaping () -> Void
  ) -> CredentialLinkingViewModel {
    return CredentialLinkingViewModel(
      credential: credential,
      visitedWebsite: visitedWebsite,
      database: database,
      autofillService: autofillService,
      domainLibrary: domainIconLibrary,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      sessionActivityReporter: activityReporter,
      teamAuditLogsService: teamAuditLogsService,
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeCredentialListViewModel(
    visitedWebsite: String?, request: CredentialsListRequest,
    completion: @escaping (CredentialSelection?) -> Void
  ) -> CredentialListViewModel {
    return CredentialListViewModel(
      visitedWebsite: visitedWebsite,
      request: request,
      syncService: syncService,
      database: database,
      logger: appServices.rootLogger,
      session: session,
      sessionActivityReporter: activityReporter,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      domainParser: appServices.domainParser,
      teamAuditLogsService: teamAuditLogsService,
      vaultItemsLimitService: vaultItemsLimitService,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      extensionSearchViewModelFactory: InjectedFactory(makeExtensionSearchViewModel),
      phishingWarningViewModelFactory: InjectedFactory(makePhishingWarningViewModel),
      credentialLinkingViewModelFactory: InjectedFactory(makeCredentialLinkingViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeCredentialProviderFlowModel(
    autofillProvider: AutofillProvider, request: CredentialsListRequest
  ) -> CredentialProviderFlowModel {
    return CredentialProviderFlowModel(
      autofillProvider: autofillProvider,
      request: request,
      sessionActivityReporter: activityReporter,
      vaultStateService: vaultStateService,
      domainParser: appServices.domainParser,
      userSettings: userSettings,
      deeplinkingService: appServices.deeplinkingService,
      credentialListViewModelFactory: InjectedFactory(makeCredentialListViewModel),
      addCredentialViewModelFactory: InjectedFactory(makeAddCredentialViewModel),
      environmentModelFactory: InjectedFactory(makeAutofillConnectedEnvironmentModel)
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeExtensionSearchViewModel(
    credentialListItemsProvider: CredentialListItemsProvider
  ) -> ExtensionSearchViewModel {
    return ExtensionSearchViewModel(
      credentialListItemsProvider: credentialListItemsProvider,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      sessionActivityReporter: activityReporter
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makePhishingWarningViewModel(
    credential: Credential, visitedWebsite: String,
    completion: @escaping (PhishingWarningViewModel.Action) -> Void
  ) -> PhishingWarningViewModel {
    return PhishingWarningViewModel(
      credential: credential,
      visitedWebsite: visitedWebsite,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      sessionActivityReporter: activityReporter,
      teamAuditLogsService: teamAuditLogsService,
      autofillService: autofillService,
      database: database,
      completion: completion
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

public typealias _AccessControlRequestViewModifierModelFactory = @MainActor (
) -> AccessControlRequestViewModifierModel

extension InjectedFactory where T == _AccessControlRequestViewModifierModelFactory {
  @MainActor
  public func make() -> AccessControlRequestViewModifierModel {
    return factory()
  }
}

extension AccessControlRequestViewModifierModel {
  public typealias Factory = InjectedFactory<_AccessControlRequestViewModifierModelFactory>
}

public typealias _AccessControlViewModelFactory = @MainActor (
  _ mode: AccessControlViewModel.AccessMode,
  _ reason: AccessControlReason,
  _ completion: @escaping AccessControlCompletion
) -> AccessControlViewModel

extension InjectedFactory where T == _AccessControlViewModelFactory {
  @MainActor
  public func make(
    mode: AccessControlViewModel.AccessMode, reason: AccessControlReason,
    completion: @escaping AccessControlCompletion
  ) -> AccessControlViewModel {
    return factory(
      mode,
      reason,
      completion
    )
  }
}

extension AccessControlViewModel {
  public typealias Factory = InjectedFactory<_AccessControlViewModelFactory>
}

public typealias _AccessControlViewModelSecondFactory = @MainActor (
  _ request: AccessControlService.UserVerificationRequest
) -> AccessControlViewModel

extension InjectedFactory where T == _AccessControlViewModelSecondFactory {
  @MainActor
  public func make(request: AccessControlService.UserVerificationRequest) -> AccessControlViewModel
  {
    return factory(
      request
    )
  }
}

extension AccessControlViewModel {
  public typealias SecondFactory = InjectedFactory<_AccessControlViewModelSecondFactory>
}

public typealias _AddCredentialViewModelFactory = @MainActor (
  _ visitedWebsite: String?,
  _ didFinish: @escaping (Credential) -> Void
) -> AddCredentialViewModel

extension InjectedFactory where T == _AddCredentialViewModelFactory {
  @MainActor
  public func make(visitedWebsite: String?, didFinish: @escaping (Credential) -> Void)
    -> AddCredentialViewModel
  {
    return factory(
      visitedWebsite,
      didFinish
    )
  }
}

extension AddCredentialViewModel {
  public typealias Factory = InjectedFactory<_AddCredentialViewModelFactory>
}

internal typealias _AutofillConnectedEnvironmentModelFactory = (
) -> AutofillConnectedEnvironmentModel

extension InjectedFactory where T == _AutofillConnectedEnvironmentModelFactory {

  func make() -> AutofillConnectedEnvironmentModel {
    return factory()
  }
}

extension AutofillConnectedEnvironmentModel {
  internal typealias Factory = InjectedFactory<_AutofillConnectedEnvironmentModelFactory>
}

internal typealias _ContextMenuAddressDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Address,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuAddressDetailViewModel

extension InjectedFactory where T == _ContextMenuAddressDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Address,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuAddressDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuAddressDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuAddressDetailViewModelFactory>
}

internal typealias _ContextMenuAddressDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Address>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuAddressDetailViewModel

extension InjectedFactory where T == _ContextMenuAddressDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Address>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuAddressDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuAddressDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuAddressDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuBankAccountDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: BankAccount,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuBankAccountDetailViewModel

extension InjectedFactory where T == _ContextMenuBankAccountDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: BankAccount,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuBankAccountDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuBankAccountDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuBankAccountDetailViewModelFactory>
}

internal typealias _ContextMenuBankAccountDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<BankAccount>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuBankAccountDetailViewModel

extension InjectedFactory where T == _ContextMenuBankAccountDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<BankAccount>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuBankAccountDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuBankAccountDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuBankAccountDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuCompanyDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Company,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuCompanyDetailViewModel

extension InjectedFactory where T == _ContextMenuCompanyDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Company,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCompanyDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuCompanyDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuCompanyDetailViewModelFactory>
}

internal typealias _ContextMenuCompanyDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Company>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuCompanyDetailViewModel

extension InjectedFactory where T == _ContextMenuCompanyDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Company>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCompanyDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuCompanyDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuCompanyDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuCredentialDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Credential,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuCredentialDetailViewModel

extension InjectedFactory where T == _ContextMenuCredentialDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Credential,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCredentialDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuCredentialDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuCredentialDetailViewModelFactory>
}

internal typealias _ContextMenuCredentialDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Credential>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuCredentialDetailViewModel

extension InjectedFactory where T == _ContextMenuCredentialDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Credential>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCredentialDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuCredentialDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuCredentialDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuCreditCardDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: CreditCard,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuCreditCardDetailViewModel

extension InjectedFactory where T == _ContextMenuCreditCardDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: CreditCard,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCreditCardDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuCreditCardDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuCreditCardDetailViewModelFactory>
}

internal typealias _ContextMenuCreditCardDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<CreditCard>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuCreditCardDetailViewModel

extension InjectedFactory where T == _ContextMenuCreditCardDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<CreditCard>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuCreditCardDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuCreditCardDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuCreditCardDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuDetailViewModel

extension InjectedFactory where T == _ContextMenuDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuDetailViewModel {
    return factory(
      vaultItemDatabase,
      completion
    )
  }
}

extension ContextMenuDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuDetailViewModelFactory>
}

internal typealias _ContextMenuDrivingLicenseDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: DrivingLicence,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuDrivingLicenseDetailViewModel

extension InjectedFactory where T == _ContextMenuDrivingLicenseDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: DrivingLicence,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuDrivingLicenseDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuDrivingLicenseDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuDrivingLicenseDetailViewModelFactory>
}

internal typealias _ContextMenuDrivingLicenseDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<DrivingLicence>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuDrivingLicenseDetailViewModel

extension InjectedFactory where T == _ContextMenuDrivingLicenseDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<DrivingLicence>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuDrivingLicenseDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuDrivingLicenseDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuDrivingLicenseDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuEmailDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: CorePersonalData.Email,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuEmailDetailViewModel

extension InjectedFactory where T == _ContextMenuEmailDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: CorePersonalData.Email,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuEmailDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuEmailDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuEmailDetailViewModelFactory>
}

internal typealias _ContextMenuEmailDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<CorePersonalData.Email>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuEmailDetailViewModel

extension InjectedFactory where T == _ContextMenuEmailDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<CorePersonalData.Email>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuEmailDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuEmailDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_ContextMenuEmailDetailViewModelSecondFactory>
}

internal typealias _ContextMenuFiscalInformationDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: FiscalInformation,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuFiscalInformationDetailViewModel

extension InjectedFactory where T == _ContextMenuFiscalInformationDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: FiscalInformation,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuFiscalInformationDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuFiscalInformationDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuFiscalInformationDetailViewModelFactory>
}

internal typealias _ContextMenuFiscalInformationDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<FiscalInformation>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuFiscalInformationDetailViewModel

extension InjectedFactory where T == _ContextMenuFiscalInformationDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<FiscalInformation>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuFiscalInformationDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuFiscalInformationDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuFiscalInformationDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuIDCardDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: IDCard,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuIDCardDetailViewModel

extension InjectedFactory where T == _ContextMenuIDCardDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: IDCard,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuIDCardDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuIDCardDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuIDCardDetailViewModelFactory>
}

internal typealias _ContextMenuIDCardDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<IDCard>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuIDCardDetailViewModel

extension InjectedFactory where T == _ContextMenuIDCardDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<IDCard>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuIDCardDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuIDCardDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_ContextMenuIDCardDetailViewModelSecondFactory>
}

internal typealias _ContextMenuListViewModelFactory = @MainActor (
  _ searchCriteria: String,
  _ activeFilter: ItemCategory?,
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ completion: @escaping (ContextMenuListViewModel.Completion) -> Void
) -> ContextMenuListViewModel

extension InjectedFactory where T == _ContextMenuListViewModelFactory {
  @MainActor
  func make(
    searchCriteria: String = "", activeFilter: ItemCategory?,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    completion: @escaping (ContextMenuListViewModel.Completion) -> Void
  ) -> ContextMenuListViewModel {
    return factory(
      searchCriteria,
      activeFilter,
      vaultItemDatabase,
      completion
    )
  }
}

extension ContextMenuListViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuListViewModelFactory>
}

internal typealias _ContextMenuNameDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Identity,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuNameDetailViewModel

extension InjectedFactory where T == _ContextMenuNameDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Identity,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuNameDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuNameDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuNameDetailViewModelFactory>
}

internal typealias _ContextMenuNameDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Identity>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuNameDetailViewModel

extension InjectedFactory where T == _ContextMenuNameDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Identity>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuNameDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuNameDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_ContextMenuNameDetailViewModelSecondFactory>
}

internal typealias _ContextMenuPassportDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Passport,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuPassportDetailViewModel

extension InjectedFactory where T == _ContextMenuPassportDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Passport,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPassportDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuPassportDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuPassportDetailViewModelFactory>
}

internal typealias _ContextMenuPassportDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Passport>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuPassportDetailViewModel

extension InjectedFactory where T == _ContextMenuPassportDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Passport>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPassportDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuPassportDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuPassportDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuPhoneDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Phone,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuPhoneDetailViewModel

extension InjectedFactory where T == _ContextMenuPhoneDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Phone,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPhoneDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuPhoneDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuPhoneDetailViewModelFactory>
}

internal typealias _ContextMenuPhoneDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Phone>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuPhoneDetailViewModel

extension InjectedFactory where T == _ContextMenuPhoneDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Phone>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuPhoneDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuPhoneDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_ContextMenuPhoneDetailViewModelSecondFactory>
}

internal typealias _ContextMenuSecretDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: Secret,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuSecretDetailViewModel

extension InjectedFactory where T == _ContextMenuSecretDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: Secret,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSecretDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuSecretDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuSecretDetailViewModelFactory>
}

internal typealias _ContextMenuSecretDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<Secret>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuSecretDetailViewModel

extension InjectedFactory where T == _ContextMenuSecretDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<Secret>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSecretDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuSecretDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<_ContextMenuSecretDetailViewModelSecondFactory>
}

internal typealias _ContextMenuSocialSecurityDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: SocialSecurityInformation,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuSocialSecurityDetailViewModel

extension InjectedFactory where T == _ContextMenuSocialSecurityDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: SocialSecurityInformation,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSocialSecurityDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuSocialSecurityDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuSocialSecurityDetailViewModelFactory>
}

internal typealias _ContextMenuSocialSecurityDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<SocialSecurityInformation>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuSocialSecurityDetailViewModel

extension InjectedFactory where T == _ContextMenuSocialSecurityDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<SocialSecurityInformation>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuSocialSecurityDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuSocialSecurityDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuSocialSecurityDetailViewModelSecondFactory
  >
}

internal typealias _ContextMenuVaultItemsProviderFlowModelFactory = @MainActor (
  _ autofillProvider: AutofillProvider
) -> ContextMenuVaultItemsProviderFlowModel

extension InjectedFactory where T == _ContextMenuVaultItemsProviderFlowModelFactory {
  @MainActor
  func make(autofillProvider: AutofillProvider) -> ContextMenuVaultItemsProviderFlowModel {
    return factory(
      autofillProvider
    )
  }
}

extension ContextMenuVaultItemsProviderFlowModel {
  internal typealias Factory = InjectedFactory<_ContextMenuVaultItemsProviderFlowModelFactory>
}

internal typealias _ContextMenuWebsiteDetailViewModelFactory = (
  _ vaultItemDatabase: VaultItemDatabaseProtocol,
  _ item: PersonalWebsite,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuWebsiteDetailViewModel

extension InjectedFactory where T == _ContextMenuWebsiteDetailViewModelFactory {

  func make(
    vaultItemDatabase: VaultItemDatabaseProtocol, item: PersonalWebsite,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuWebsiteDetailViewModel {
    return factory(
      vaultItemDatabase,
      item,
      completion
    )
  }
}

extension ContextMenuWebsiteDetailViewModel {
  internal typealias Factory = InjectedFactory<_ContextMenuWebsiteDetailViewModelFactory>
}

internal typealias _ContextMenuWebsiteDetailViewModelSecondFactory = (
  _ service: DetailServiceContextMenuAutofill<PersonalWebsite>,
  _ completion: @escaping (VaultItem, String) -> Void
) -> ContextMenuWebsiteDetailViewModel

extension InjectedFactory where T == _ContextMenuWebsiteDetailViewModelSecondFactory {

  func make(
    service: DetailServiceContextMenuAutofill<PersonalWebsite>,
    completion: @escaping (VaultItem, String) -> Void
  ) -> ContextMenuWebsiteDetailViewModel {
    return factory(
      service,
      completion
    )
  }
}

extension ContextMenuWebsiteDetailViewModel {
  internal typealias SecondFactory = InjectedFactory<
    _ContextMenuWebsiteDetailViewModelSecondFactory
  >
}

internal typealias _CredentialLinkingViewModelFactory = (
  _ credential: Credential,
  _ visitedWebsite: String,
  _ completion: @escaping () -> Void
) -> CredentialLinkingViewModel

extension InjectedFactory where T == _CredentialLinkingViewModelFactory {

  func make(credential: Credential, visitedWebsite: String, completion: @escaping () -> Void)
    -> CredentialLinkingViewModel
  {
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
  _ visitedWebsite: String?,
  _ request: CredentialsListRequest,
  _ completion: @escaping (CredentialSelection?) -> Void
) -> CredentialListViewModel

extension InjectedFactory where T == _CredentialListViewModelFactory {
  @MainActor
  func make(
    visitedWebsite: String?, request: CredentialsListRequest,
    completion: @escaping (CredentialSelection?) -> Void
  ) -> CredentialListViewModel {
    return factory(
      visitedWebsite,
      request,
      completion
    )
  }
}

extension CredentialListViewModel {
  internal typealias Factory = InjectedFactory<_CredentialListViewModelFactory>
}

internal typealias _CredentialProviderFlowModelFactory = @MainActor (
  _ autofillProvider: AutofillProvider,
  _ request: CredentialsListRequest
) -> CredentialProviderFlowModel

extension InjectedFactory where T == _CredentialProviderFlowModelFactory {
  @MainActor
  func make(autofillProvider: AutofillProvider, request: CredentialsListRequest)
    -> CredentialProviderFlowModel
  {
    return factory(
      autofillProvider,
      request
    )
  }
}

extension CredentialProviderFlowModel {
  internal typealias Factory = InjectedFactory<_CredentialProviderFlowModelFactory>
}

internal typealias _ExtensionSearchViewModelFactory = @MainActor (
  _ credentialListItemsProvider: CredentialListItemsProvider
) -> ExtensionSearchViewModel

extension InjectedFactory where T == _ExtensionSearchViewModelFactory {
  @MainActor
  func make(credentialListItemsProvider: CredentialListItemsProvider) -> ExtensionSearchViewModel {
    return factory(
      credentialListItemsProvider
    )
  }
}

extension ExtensionSearchViewModel {
  internal typealias Factory = InjectedFactory<_ExtensionSearchViewModelFactory>
}

public typealias _PhishingWarningViewModelFactory = @MainActor (
  _ credential: Credential,
  _ visitedWebsite: String,
  _ completion: @escaping (PhishingWarningViewModel.Action) -> Void
) -> PhishingWarningViewModel

extension InjectedFactory where T == _PhishingWarningViewModelFactory {
  @MainActor
  public func make(
    credential: Credential, visitedWebsite: String,
    completion: @escaping (PhishingWarningViewModel.Action) -> Void
  ) -> PhishingWarningViewModel {
    return factory(
      credential,
      visitedWebsite,
      completion
    )
  }
}

extension PhishingWarningViewModel {
  public typealias Factory = InjectedFactory<_PhishingWarningViewModelFactory>
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
