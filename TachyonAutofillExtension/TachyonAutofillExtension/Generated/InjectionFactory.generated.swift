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
#if canImport(CoreLocalization)
  import CoreLocalization
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
#if canImport(DashlaneAPI)
  import DashlaneAPI
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
#if canImport(Logger)
  import Logger
#endif
#if canImport(LoginKit)
  import LoginKit
#endif
#if canImport(MacrosKit)
  import MacrosKit
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
#if canImport(UIDelight)
  import UIDelight
#endif
#if canImport(VaultKit)
  import VaultKit
#endif

internal protocol AppServicesInjecting {}

extension AppServicesContainer {

  internal func makeLoginKitServicesContainer() -> LoginKitServicesContainer {
    return LoginKitServicesContainer(
      loginMetricsReporter: loginMetricsReporter,
      activityReporter: activityReporter,
      sessionCleaner: sessionCleaner,
      settingsManager: settingsManager,
      keychainService: keychainService,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      sessionContainer: sessionsContainer,
      rootLogger: rootLogger,
      nitroClient: nitroClient,
      passwordEvaluator: passwordEvaluator
    )
  }

}

internal protocol SessionServicesInjecting {}

extension SessionServicesContainer {
  @MainActor
  internal func makeAddCredentialViewModel(
    pasteboardService: PasteboardService, visitedWebsite: String?,
    didFinish: @escaping (Credential) -> Void
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
      activityLogsService: activityLogsService,
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
      activityLogsService: activityLogsService,
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
      syncService: syncService,
      database: database,
      autofillService: autofillService,
      logger: appServices.rootLogger,
      session: session,
      sessionActivityReporter: activityReporter,
      personalDataURLDecoder: appServices.personalDataURLDecoder,
      userSettings: userSettings,
      request: request,
      userSpacesService: premiumStatusServicesSuit.userSpacesService,
      credentialLinkingViewModelFactory: InjectedFactory(makeCredentialLinkingViewModel),
      domainParser: appServices.domainParser,
      capabilityService: premiumStatusServicesSuit.capabilityService,
      activityLogsService: activityLogsService,
      vaultItemsLimitService: vaultItemsLimitService,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      addCredentialViewModelFactory: InjectedFactory(makeAddCredentialViewModel),
      extensionSearchViewModelFactory: InjectedFactory(makeExtensionSearchViewModel),
      phishingWarningViewModelFactory: InjectedFactory(makePhishingWarningViewModel),
      completion: completion
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeExtensionSearchViewModel(credentialsListService: CredentialListService)
    -> ExtensionSearchViewModel
  {
    return ExtensionSearchViewModel(
      credentialsListService: credentialsListService,
      domainIconLibrary: domainIconLibrary,
      vaultItemIconViewModelFactory: InjectedFactory(makeVaultItemIconViewModel),
      sessionActivityReporter: activityReporter
    )
  }

}

extension SessionServicesContainer {
  @MainActor
  internal func makeHomeFlowViewModel(
    request: CredentialsListRequest, completion: @escaping (CredentialSelection?) -> Void
  ) -> HomeFlowViewModel {
    return HomeFlowViewModel(
      credentialListViewModelFactory: InjectedFactory(makeCredentialListViewModel),
      sessionActivityReporter: activityReporter,
      vaultStateService: vaultStateService,
      domainParser: appServices.domainParser,
      request: request,
      environmentModelFactory: InjectedFactory(makeAutofillConnectedEnvironmentModel),
      completion: completion
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
      activityLogsService: activityLogsService,
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

public typealias _AddCredentialViewModelFactory = @MainActor (
  _ pasteboardService: PasteboardService,
  _ visitedWebsite: String?,
  _ didFinish: @escaping (Credential) -> Void
) -> AddCredentialViewModel

extension InjectedFactory where T == _AddCredentialViewModelFactory {
  @MainActor
  public func make(
    pasteboardService: PasteboardService, visitedWebsite: String?,
    didFinish: @escaping (Credential) -> Void
  ) -> AddCredentialViewModel {
    return factory(
      pasteboardService,
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

internal typealias _ExtensionSearchViewModelFactory = @MainActor (
  _ credentialsListService: CredentialListService
) -> ExtensionSearchViewModel

extension InjectedFactory where T == _ExtensionSearchViewModelFactory {
  @MainActor
  func make(credentialsListService: CredentialListService) -> ExtensionSearchViewModel {
    return factory(
      credentialsListService
    )
  }
}

extension ExtensionSearchViewModel {
  internal typealias Factory = InjectedFactory<_ExtensionSearchViewModelFactory>
}

internal typealias _HomeFlowViewModelFactory = @MainActor (
  _ request: CredentialsListRequest,
  _ completion: @escaping (CredentialSelection?) -> Void
) -> HomeFlowViewModel

extension InjectedFactory where T == _HomeFlowViewModelFactory {
  @MainActor
  func make(request: CredentialsListRequest, completion: @escaping (CredentialSelection?) -> Void)
    -> HomeFlowViewModel
  {
    return factory(
      request,
      completion
    )
  }
}

extension HomeFlowViewModel {
  internal typealias Factory = InjectedFactory<_HomeFlowViewModelFactory>
}

public typealias _LoginKitServicesContainerFactory = (
) -> LoginKitServicesContainer

extension InjectedFactory where T == _LoginKitServicesContainerFactory {

  public func make() -> LoginKitServicesContainer {
    return factory()
  }
}

extension LoginKitServicesContainer {
  public typealias Factory = InjectedFactory<_LoginKitServicesContainerFactory>
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
