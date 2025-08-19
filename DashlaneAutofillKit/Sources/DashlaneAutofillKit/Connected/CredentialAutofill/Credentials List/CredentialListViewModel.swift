import AuthenticationServices
import AutofillKit
import Combine
import CoreFeature
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DomainParser
import Foundation
import IconLibrary
import LogFoundation
import PremiumKit
import SwiftTreats
import UserTrackingFoundation
import VaultKit

@MainActor
class CredentialListViewModel: ObservableObject, SessionServicesInjecting {
  enum AddState {
    case available
    case limitReached
    case unavailable
  }

  @Published
  var sections: [DataSection] = []

  @Published
  var isReady: Bool = false

  @Published
  var isSyncing: Bool = false

  @Published
  var showOnlyMatchingCredentials: Bool = true

  @Published
  var paywallViewModel: PaywallViewModel?

  @Published
  var displayLinkingView: Bool = false

  @Published
  var selection: CredentialSelection?

  var addState: AddState {
    switch request.type {
    case .passwords, .passkeysAndPasswords:
      return vaultItemsLimitService.canAddNewItem(for: .credentials) ? .available : .limitReached
    case .otps:
      return .unavailable
    }
  }

  var visitedWebsite: String?
  let request: CredentialsListRequest
  let completion: (CredentialSelection?) -> Void
  private let queue = DispatchQueue(label: "credentialsListView", qos: .utility)

  private var subscriptions = Set<AnyCancellable>()
  private let credentialListItemsProvider: CredentialListItemsProvider
  private let syncService: SyncServiceProtocol
  private let database: ApplicationDatabase
  private let logger: Logger
  private let session: Session
  private let sessionActivityReporter: ActivityReporterProtocol
  private let userSpacesService: UserSpacesService
  private let credentialLinkingViewModelFactory: CredentialLinkingViewModel.Factory
  private let phishingWarningViewModelFactory: PhishingWarningViewModel.Factory
  private let domainParser: DomainParserProtocol
  private let teamAuditLogsService: TeamAuditLogsServiceProtocol
  private let vaultItemsLimitService: VaultItemsLimitServiceProtocol

  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  private let extensionSearchViewModelFactory: ExtensionSearchViewModel.Factory

  var cancellables = Set<AnyCancellable>()

  init(
    visitedWebsite: String?,
    request: CredentialsListRequest,
    syncService: SyncServiceProtocol,
    database: ApplicationDatabase,
    logger: Logger,
    session: Session,
    sessionActivityReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    domainParser: DomainParserProtocol,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    vaultItemsLimitService: VaultItemsLimitServiceProtocol,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    extensionSearchViewModelFactory: ExtensionSearchViewModel.Factory,
    phishingWarningViewModelFactory: PhishingWarningViewModel.Factory,
    credentialLinkingViewModelFactory: CredentialLinkingViewModel.Factory,
    completion: @escaping (CredentialSelection?) -> Void
  ) {
    self.syncService = syncService
    self.database = database
    self.sessionActivityReporter = sessionActivityReporter
    self.logger = logger
    self.session = session
    self.completion = completion
    self.userSpacesService = userSpacesService
    self.domainParser = domainParser
    self.teamAuditLogsService = teamAuditLogsService
    self.vaultItemsLimitService = vaultItemsLimitService
    self.request = request

    self.credentialLinkingViewModelFactory = credentialLinkingViewModelFactory
    self.phishingWarningViewModelFactory = phishingWarningViewModelFactory

    credentialListItemsProvider = CredentialListItemsProvider(
      syncStatusPublisher: syncService.syncStatusPublisher,
      userSpacesService: userSpacesService,
      domainParser: domainParser,
      database: database,
      request: request)

    self.extensionSearchViewModelFactory = extensionSearchViewModelFactory
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.visitedWebsite = visitedWebsite
    setupSections()
  }

  private func setupSections() {
    let credentialListItemsProvider = self.credentialListItemsProvider
    credentialListItemsProvider
      .$items
      .compactMap { $0 }
      .receive(on: queue)
      .map { items -> [DataSection] in
        var allSections: [DataSection] = items.all.alphabeticallyGrouped()

        if !items.suggested.isEmpty {
          let suggestedSection = DataSection(
            name: L10n.Localizable.suggested,
            type: .suggestedItems,
            items: items.suggested)
          allSections = [suggestedSection] + allSections
        }

        return allSections
      }
      .receive(on: DispatchQueue.main)
      .sink { [weak self] sections in
        guard let self else {
          return
        }

        self.sections = sections
        self.isReady = true

      }.store(in: &cancellables)

    self.syncService
      .syncStatusPublisher
      .receive(on: DispatchQueue.main)
      .map { syncStatus -> Bool in
        switch syncStatus {
        case .syncing:
          return true
        default:
          return false
        }
      }
      .assign(to: &$isSyncing)
  }

  func select(_ item: VaultItem, origin: VaultSelectionOrigin) {
    switch item.enumerated {
    case let .credential(credential):
      self.select(credential, origin: origin)
    case let .passkey(passkey):
      self.select(passkey, origin: origin)
    default:
      assertionFailure("Should not have any other type")
      return
    }

    let event = UserEvent.SelectVaultItem(
      highlight: origin.definitionHighlight, itemId: item.userTrackingLogID,
      itemType: item.vaultItemType)
    sessionActivityReporter.report(event)
  }

  private func select(_ credential: Credential, origin: VaultSelectionOrigin) {
    if case .otps = request.type {
      selection = CredentialSelection(
        credential: .otp(credential), visitedWebsite: self.visitedWebsite)
      self.completion(selection)

    } else {
      selection = CredentialSelection(
        credential: .password(credential), visitedWebsite: self.visitedWebsite)

      guard let visitedWebsite = visitedWebsite else {
        self.completion(selection)
        return
      }

      let allCredentialDomains = credential.allDomains()
        .compactMap { host in domainParser.parse(host: host)?.domain }

      guard allCredentialDomains.contains(visitedWebsite) else {
        if credential.metadata.sharingPermission != .limited {
          displayLinkingView = true
        } else {
          self.completion(selection)
        }
        return
      }
      self.completion(selection)
    }

  }

  private func select(_ passkey: Passkey, origin: VaultSelectionOrigin) {
    selection = CredentialSelection(
      credential: .passkey(passkey), visitedWebsite: self.visitedWebsite)
    self.completion(selection)
  }

  func cancel() {
    let event = UserEvent.AutofillDismiss(dismissType: .closeCross)
    sessionActivityReporter.report(event)
    let website = visitedWebsite ?? ""
    sessionActivityReporter.report(
      AnonymousEvent.AutofillDismiss(
        dismissType: .closeCross,
        domain: website.hashedDomainForLogs(),
        isNativeApp: true))
    completion(nil)
  }
}

extension CredentialListViewModel {
  func makeExtensionSearchViewModel() -> ExtensionSearchViewModel {
    extensionSearchViewModelFactory.make(credentialListItemsProvider: credentialListItemsProvider)
  }

  func makeCredentialLinkingViewModel() -> CredentialLinkingViewModel? {
    guard let selection = selection,
      let visitedWebsite = selection.visitedWebsite,
      case let .password(credential) = selection.credential
    else {
      return nil
    }

    return credentialLinkingViewModelFactory.make(
      credential: credential,
      visitedWebsite: visitedWebsite,
      completion: { [weak self] in
        self?.displayLinkingView = false
        self?.completion(selection)
      })
  }

  func makePhishingWarningViewModel() -> PhishingWarningViewModel? {
    guard let selection = selection,
      let visitedWebsite = selection.visitedWebsite,
      case let .password(credential) = selection.credential
    else {
      return nil
    }

    return phishingWarningViewModelFactory.make(
      credential: credential, visitedWebsite: visitedWebsite
    ) { [weak self] (action: PhishingWarningViewModel.Action) in
      guard let self else { return }
      switch action {
      case .trustAndAutoFill:
        self.displayLinkingView = false
        self.completion(selection)
      case .doNotAutoFill:
        self.displayLinkingView = false
        self.completion(nil)
      }
    }
  }
}

extension CredentialListViewModel {
  static func mock(request: CredentialsListRequest) -> CredentialListViewModel {
    CredentialListViewModel(
      visitedWebsite: "www.amazon.com",
      request: request,
      syncService: .mock(),
      database: .mock(items: [
        PersonalDataMock.Credentials.amazon,
        PersonalDataMock.Credentials.github,
        Passkey.github,
      ]),
      logger: .mock,
      session: .mock,
      sessionActivityReporter: .mock,
      userSpacesService: .mock(),
      domainParser: FakeDomainParser(),
      teamAuditLogsService: .mock(),
      vaultItemsLimitService: .mock,
      vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
      extensionSearchViewModelFactory: .init { provider in
        ExtensionSearchViewModel(
          credentialListItemsProvider: provider,
          vaultItemIconViewModelFactory: .init { item in .mock(item: item) },
          sessionActivityReporter: .mock)
      },
      phishingWarningViewModelFactory: .init { _, _, _ in .mock() },
      credentialLinkingViewModelFactory: .init { _, _, _ in fatalError() }
    ) { _ in

    }
  }
}
