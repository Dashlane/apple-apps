import AuthenticationServices
import AutofillKit
import Combine
import CoreActivityLogs
import CoreFeature
import CorePasswords
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DomainParser
import Foundation
import IconLibrary
import PremiumKit
import SwiftTreats
import VaultKit

@MainActor
class CredentialListViewModel: ObservableObject, SessionServicesInjecting {

  enum Step: Hashable {
    case list
    case addCredential
  }

  @Published var steps: [Step] = [.list]

  @Published
  var sections: [DataSection] = []

  @Published
  var isReady: Bool = false

  @Published
  var isSyncing: Bool = false

  @Published
  var showOnlyMatchingCredentials: Bool = true

  @Published
  var paywallViewModel: PaywallViewModel? = nil

  @Published
  var displayLinkingView: Bool = false

  @Published
  var selection: CredentialSelection? = nil

  var visitedWebsite: String?
  let completion: (CredentialSelection?) -> Void
  private let queue = DispatchQueue(label: "credentialsListView", qos: .utility)

  private var subscriptions = Set<AnyCancellable>()
  private let credentialsListService: CredentialListService
  private let syncService: SyncService
  private let database: ApplicationDatabase
  private let autofillService: AutofillService
  private let logger: Logger
  private let session: Session
  private let request: CredentialsListRequest
  let sessionActivityReporter: ActivityReporterProtocol
  private var searchSubscription: AnyCancellable?
  private let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  private let userSettings: UserSettings
  private let userSpacesService: UserSpacesService
  private let credentialLinkingViewModelFactory: CredentialLinkingViewModel.Factory
  private let phishingWarningViewModelFactory: PhishingWarningViewModel.Factory
  private let domainParser: DomainParserProtocol
  private let activityLogsService: ActivityLogsServiceProtocol
  private let vaultItemsLimitService: VaultItemsLimitServiceProtocol

  private let addCredentialViewModelFactory: AddCredentialViewModel.Factory
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  private let extensionSearchViewModelFactory: ExtensionSearchViewModel.Factory

  var cancellables = Set<AnyCancellable>()

  init(
    visitedWebsite: String?,
    syncService: SyncService,
    database: ApplicationDatabase,
    autofillService: AutofillService,
    logger: Logger,
    session: Session,
    sessionActivityReporter: ActivityReporterProtocol,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol,
    userSettings: UserSettings,
    request: CredentialsListRequest,
    userSpacesService: UserSpacesService,
    credentialLinkingViewModelFactory: CredentialLinkingViewModel.Factory,
    domainParser: DomainParserProtocol,
    capabilityService: CapabilityServiceProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    vaultItemsLimitService: VaultItemsLimitServiceProtocol,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory,
    addCredentialViewModelFactory: AddCredentialViewModel.Factory,
    extensionSearchViewModelFactory: ExtensionSearchViewModel.Factory,
    phishingWarningViewModelFactory: PhishingWarningViewModel.Factory,
    completion: @escaping (CredentialSelection?) -> Void
  ) {
    self.syncService = syncService
    self.database = database
    self.autofillService = autofillService
    self.userSettings = userSettings
    self.personalDataURLDecoder = personalDataURLDecoder
    self.sessionActivityReporter = sessionActivityReporter
    self.logger = logger
    self.session = session
    self.completion = completion
    self.userSpacesService = userSpacesService
    self.credentialLinkingViewModelFactory = credentialLinkingViewModelFactory
    self.addCredentialViewModelFactory = addCredentialViewModelFactory
    self.phishingWarningViewModelFactory = phishingWarningViewModelFactory
    self.domainParser = domainParser
    self.activityLogsService = activityLogsService
    self.vaultItemsLimitService = vaultItemsLimitService
    self.request = request
    credentialsListService = CredentialListService(
      syncStatusPublisher: syncService.$syncStatus.eraseToAnyPublisher(),
      userSpacesService: userSpacesService,
      domainParser: domainParser,
      database: database,
      capabilityService: capabilityService,
      request: request)

    self.extensionSearchViewModelFactory = extensionSearchViewModelFactory
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory
    self.visitedWebsite = visitedWebsite
    setupSections()
  }

  func makeExtensionSearchViewModel() -> ExtensionSearchViewModel {
    extensionSearchViewModelFactory.make(credentialsListService: credentialsListService)
  }

  private func setupSections() {
    let credentialsListService = self.credentialsListService
    credentialsListService
      .$isReady
      .filter { $0 }
      .combineLatest(
        credentialsListService.$allCredentials, credentialsListService.$matchingPasskeys
      )
      .receive(on: queue)
      .map { [credentialsListService] _, credentials, passkeys -> [DataSection] in
        var allSections: [DataSection] = (credentials + passkeys).alphabeticallyGrouped()

        if credentialsListService.allCredentials.count > 6 {
          let matchingCredentials = credentialsListService.matchingCredentials(
            from: credentialsListService.allCredentials)
          let matchingPasskeys = credentialsListService.matchingPasskeys
          if !matchingCredentials.isEmpty || !matchingPasskeys.isEmpty {
            let suggestedSection = DataSection(
              name: L10n.Localizable.suggested,
              type: .suggestedItems,
              items: matchingCredentials + matchingPasskeys)
            allSections = [suggestedSection] + allSections
          }
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
      .$syncStatus
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

    $displayLinkingView
      .receive(on: DispatchQueue.main)
      .removeDuplicates()
      .sink(receiveValue: { [weak self] isDisplayed in
        if isDisplayed {
          self?.sessionActivityReporter.reportPageShown(.autofillNotificationLinkDomain)
        }
      })
      .store(in: &subscriptions)
  }

  func select(_ item: VaultItem, origin: VaultSelectionOrigin) {
    switch item.enumerated {
    case let .credential(credential):
      self.selected(credential, origin: origin)
    case let .passkey(passkey):
      self.selected(passkey, origin: origin)
    default:
      assertionFailure("Should not have any other type")
      return
    }

    searchSubscription?.cancel()

    let event = UserEvent.SelectVaultItem(
      highlight: origin.definitionHighlight, itemId: item.userTrackingLogID,
      itemType: item.vaultItemType)
    sessionActivityReporter.report(event)
  }

  private func selected(_ credential: Credential, origin: VaultSelectionOrigin) {
    selection = CredentialSelection(
      credential: .credential(credential),
      visitedWebsite: self.visitedWebsite)

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

  private func selected(_ passkey: Passkey, origin: VaultSelectionOrigin) {
    selection = CredentialSelection(
      credential: .passkey(passkey),
      visitedWebsite: self.visitedWebsite)
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

  func onAppear() {
    sessionActivityReporter.reportPageShown(.autofillExplorePasswords)
  }

  func makeAddCredentialViewModel() -> AddCredentialViewModel {
    addCredentialViewModelFactory.make(
      pasteboardService: PasteboardService(userSettings: userSettings),
      visitedWebsite: visitedWebsite,
      didFinish: { [weak self] credential in
        guard let self = self else { return }
        let selection = CredentialSelection(
          credential: .credential(credential),
          visitedWebsite: self.visitedWebsite)
        self.completion(selection)
      })
  }

  func canAddNewCredential() -> Bool {
    vaultItemsLimitService.canAddNewItem(for: .credentials)
  }
}

extension CredentialListViewModel {
  func makeCredentialLinkingViewModel() -> CredentialLinkingViewModel? {
    guard let selection = selection,
      let visitedWebsite = selection.visitedWebsite,
      case let .credential(credential) = selection.credential
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
      case let .credential(credential) = selection.credential
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
