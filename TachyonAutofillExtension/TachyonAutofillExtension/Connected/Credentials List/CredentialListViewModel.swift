import Foundation
import CorePersonalData
import Combine
import DashTypes
import CoreFeature
import SwiftTreats
import CoreUserTracking
import DashlaneAppKit
import IconLibrary
import CoreSettings
import CorePasswords
import AuthenticationServices
import CorePremium
import DomainParser
import VaultKit
import PremiumKit

@MainActor
class CredentialListViewModel: ObservableObject {
    typealias Completion = (CredentialSelection?) -> Void

    enum Step {
        case list
        case addCredential(AddCredentialViewModel)
        case paywall(PaywallViewModel)
    }

    @Published
    var steps: [Step] = [.list]

    @Published
    var sections: [DataSection] = [] {
        didSet {
            isReady = true
        }
    }
    var searchViewModel: ExtensionSearchViewModel
    var domainIconLibrary: DomainIconLibrary

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
    let completion: Completion
    private let queue = DispatchQueue(label: "credentialsListView", qos: .utility)
    private var subscriptions = Set<AnyCancellable>()
    private let credentialsListService: CredentialListService
    private let syncService: SyncService
    private let tachyonLogger: TachyonLogger?
    private let database: ApplicationDatabase
    private let autofillService: AutofillService
    private let logger: Logger
    private let usageLogService: UsageLogServiceProtocol
    private let sessionActivityReporter: ActivityReporterProtocol
    private var searchSubscription: AnyCancellable?
    private let personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder
    private let passwordEvaluator: PasswordEvaluator
    private let userSettings: UserSettings
    private let associatedDomainsService: LinkedDomainProvider
    private let featureService: FeatureServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let domainParser: DomainParser
    private let openUrl: @MainActor (URL) -> Bool

    @Published
    private var sorting: VaultItemSorting = .sortedByName
        
    init(syncService: SyncService,
         database: ApplicationDatabase,
         autofillService: AutofillService,
         domainIconLibrary: DomainIconLibrary,
         tachyonLogger: TachyonLogger?,
         logger: Logger,
         usageLogService: UsageLogServiceProtocol,
         sessionActivityReporter: ActivityReporterProtocol,
         personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder,
         passwordEvaluator: PasswordEvaluator,
         userSettings: UserSettings,
         serviceIdentifiers: [ASCredentialServiceIdentifier],
         teamSpacesService: TeamSpacesService,
         domainParser: DomainParser,
         premiumStatus: PremiumStatus?,
         associatedDomainsService: LinkedDomainProvider,
         featureService: FeatureServiceProtocol,
         openUrl: @escaping @MainActor (URL) -> Bool,
         completion: @escaping Completion) {
        self.syncService = syncService
        self.database = database
        self.openUrl = openUrl
        self.autofillService = autofillService
        self.userSettings = userSettings
        self.personalDataURLDecoder = personalDataURLDecoder
        self.passwordEvaluator = passwordEvaluator
        self.usageLogService = usageLogService
        self.sessionActivityReporter = sessionActivityReporter
        self.tachyonLogger = tachyonLogger
        self.logger = logger
        self.domainIconLibrary = domainIconLibrary
        self.associatedDomainsService = associatedDomainsService
        self.completion = completion
        self.featureService = featureService
        self.teamSpacesService = teamSpacesService
        self.domainParser = domainParser

        credentialsListService = CredentialListService(syncStatusPublisher: syncService.$syncStatus.eraseToAnyPublisher(),
                                                  teamSpaceService: teamSpacesService,
                                                  domainParser: domainParser,
                                                  database: database,
                                                  premiumStatus: premiumStatus,
                                                  serviceIdentifiers: serviceIdentifiers)
        self.searchViewModel = ExtensionSearchViewModel(credentialsListService: credentialsListService,
                                                        usageLogService: usageLogService,
                                                        domainIconLibrary: domainIconLibrary)

        if let host = serviceIdentifiers.last?.host {
            let domain = domainParser.parse(host: host)?.domain
            self.visitedWebsite = domain
        }

        setupSections()
    }

    private func setupSections() {
        let credentialsListService = self.credentialsListService
        credentialsListService
            .$isReady
            .combineLatest(credentialsListService.$allCredentials) { isReady, credentials -> [Credential]? in
                guard isReady else {
                    return nil
                }
                return credentials
            }.compactMap { $0 }
            .receive(on: queue)
            .sort(using: $sorting)
            .map { sections -> [DataSection] in
                var allSections = sections
                                if self.credentialsListService.allCredentials.count > 6 {
                    let matchingCredentials = self.credentialsListService.matchingCredentials(from: self.credentialsListService.allCredentials)
                    if !matchingCredentials.isEmpty {
                        let suggestedSection = DataSection(name: L10n.Localizable.suggested,
                                                           isSuggestedItems: true,
                                                           items: matchingCredentials)
                        allSections = [suggestedSection] + allSections
                    }
                }
                return allSections
            }
            .receive(on: RunLoop.main)
            .assign(to: \.sections, on: self)
            .store(in: &subscriptions)

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
            .assign(to: \.isSyncing, on: self)
            .store(in: &subscriptions)
        
        $displayLinkingView
            .sink(receiveValue: { [weak self] isDisplayed in
                if isDisplayed {
                    self?.sessionActivityReporter.reportPageShown(.autofillNotificationLinkDomain)
                } else if let selection = self?.selection {
                    self?.completion(selection)
                }
            })
            .store(in: &subscriptions)

        searchViewModel
            .$isActive
            .sink(receiveValue: { [weak self] isActive in
                if isActive {
                    self?.sessionActivityReporter.reportPageShown(.autofillExplorePasswordsSearch)
                }
            })
            .store(in: &subscriptions)
    }

    func select(_ item: VaultItem, origin: VaultSelectionOrigin) {
        guard case .credential(let credential) = item.enumerated else { return }
        selection = CredentialSelection(credential: credential,
                                       selectionOrigin: .credentialsList,
                                        visitedWebsite: self.visitedWebsite)

        searchSubscription?.cancel()

        if origin == .searchResult {
            searchViewModel.sendSearchUsageLogFromSelection()
        }
                
        let event = UserEvent.SelectVaultItem(highlight: origin.definitionHighlight, itemId: item.userTrackingLogID, itemType: item.vaultItemType)
        sessionActivityReporter.report(event)

        guard let visitedWebsite = visitedWebsite else {
            self.completion(selection)
            return
        }

                let allCredentialDomains = credential.allDomains(using: associatedDomainsService)
                                    .compactMap { host in domainParser.parse(host: host)?.domain }

        guard allCredentialDomains.contains(visitedWebsite) else {
            if featureService.isEnabled(.linkedWebsitesOnTachyon), credential.metadata.sharingPermission != .limited {
                displayLinkingView = true
            } else {
                self.completion(selection)
            }
            return
        }

        self.completion(selection)
    }
    
    func cancel() {
        tachyonLogger?.log(CredentialListEvent.cancel)
        let event = UserEvent.AutofillDismiss(dismissType: .closeCross)
        sessionActivityReporter.report(event)
        let anonymousEvent = AnonymousEvent.AutofillDismiss(dismissType: .closeCross, domain: (visitedWebsite ?? "").hashedDomainForLogs, isNativeApp: true)
        sessionActivityReporter.report(anonymousEvent)

        completion(nil)
    }
    
    func onAppear() {
        credentialsListService.$isReady
            .filter { $0 == true}
            .sinkOnce { [weak self] _ in
                guard let self = self else {
                    return
                }
                let matchingCredentials = self.credentialsListService.matchingCredentials(from: self.credentialsListService.allCredentials)
                let showMatchingCredentials = !matchingCredentials.isEmpty && matchingCredentials != self.credentialsListService.allCredentials
                self.tachyonLogger?.log(CredentialListEvent.displayed(showAllOptionAvailable: showMatchingCredentials))
            }
        
        sessionActivityReporter.reportPageShown(.autofillExplorePasswords)
    }
    
    func didTapShowAll() {
        tachyonLogger?.log(CredentialListEvent.showAllCredentials)
    }
    
    private func updateManualAssociatedDomains(for selection: CredentialSelection, completion: @escaping (Result<Void, Error>) -> Void) {        
        guard let visitedWebsite = selection.visitedWebsite,
              let domain = selection.credential.url?.domain?.name,
              domain != visitedWebsite else {
            completion(.success)
            return
        }

                if !selection.credential.manualAssociatedDomains.contains(visitedWebsite) {
            completion(.success)
            return
        }

        var credential = selection.credential
        credential.manualAssociatedDomains.insert(visitedWebsite)
        _ = try? database.save(credential)
        autofillService.saveNewCredentials([credential], completion: completion)
    }
    
    func onSearchAppear() {
        searchSubscription = self.searchViewModel
            .searchUsageLogPublisher
            .sink { [weak self] log in
                self?.usageLogService.post(log)
            }
    }

    func addAction() {
        self.steps.append(.addCredential(makeAddCredentialViewModel()))
        sessionActivityReporter.report(UserEvent.AutofillClick(autofillButton: .createPasswordLabel))
        sessionActivityReporter.reportPageShown(.autofillExplorePasswordsCreate)
    }

    private func makeAddCredentialViewModel() -> AddCredentialViewModel{
        return AddCredentialViewModel(database: database,
                                      logger: logger,
                                      personalDataURLDecoder: personalDataURLDecoder,
                                      passwordEvaluator: passwordEvaluator,
                                      usageLogService: usageLogService,
                                      activityReporter: sessionActivityReporter,
                                      domainLibrary: domainIconLibrary,
                                      visitedWebsite: visitedWebsite,
                                      userSettings: userSettings) { [weak self] credential in
            guard let self = self else { return }
            let selection = CredentialSelection(credential: credential,
                                                selectionOrigin: .newCredential,
                                                visitedWebsite: self.visitedWebsite)
            self.completion(selection)
        }
    }

    func handlePaywallViewAction(_ action: PaywallView.Action) {
        switch action {
        case .cancel:
            completion(nil)
        case .displayList, .planDetails:
            _ = openUrl(URL(string: "dashlane:///getpremium")!)
        }
    }
}

extension CredentialListViewModel {
    func makeCredentialLinkingViewModel() -> CredentialLinkingViewModel? {
        guard let selection = selection, let visitedWebsite = selection.visitedWebsite else {
                        return nil
        }
        return CredentialLinkingViewModel(credential: selection.credential,
                                          visitedWebsite: visitedWebsite,
                                          database: database,
                                          autofillService: autofillService,
                                          domainLibrary: domainIconLibrary,
                                          teamSpacesService: teamSpacesService,
                                          sessionActivityReporter: sessionActivityReporter,
                                          completion: {
            self.displayLinkingView = false
        })
    }
}

private extension ASCredentialServiceIdentifier {

    var host: String? {
        switch self.type {
        case .URL:
            return URL(string: self.identifier)?.host
        case .domain:
            return self.identifier
        @unknown default:
            assertionFailure("A new Identifier type has been introduced, please implement this")
            return nil
        }
    }
}
