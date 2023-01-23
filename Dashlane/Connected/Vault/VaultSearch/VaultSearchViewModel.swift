import Foundation
import Combine
import CorePersonalData
import CoreData
import SwiftUI
import DashlaneReportKit
import CoreFeature
import DashlaneAppKit
import CoreUserTracking
import VaultKit
import DashTypes
import CoreSharing
import CorePremium
import CoreSettings

struct VaultSearchSelection {
    let item: VaultItem
    let origin: VaultSelectionOrigin
    let count: Int
}

class VaultSearchViewModel: ObservableObject, SessionServicesInjecting {
                @Published
    var sections: [DataSection] = []

        @Published
    var searchCriteria: String = ""

                @Published
    var searchResult: SearchResult = SearchResult(searchCriteria: "", sections: [])

    @Published
    var recentSearchSections: [DataSection] = []

                    let searchCategory: ItemCategory?

                    @Published
    var activeFilter: VaultListFilter

    @Published
    var isSearchActive: Bool = false {
        didSet {
            if isSearchActive {
                activityReporter.reportPageShown(.search)
            }
        }
    }

    @Published
    var secureNoteState: SecureNoteState

    var isSecureNoteDisabled: Bool {
        featureService.isEnabled(.disableSecureNotes)
    }

    var searchUsageLogPublisher: AnyPublisher<UsageLogCode32Search, Never> {
        return $searchResult
            .debounce(for: .seconds(10), scheduler: RunLoop.main)
            .dropFirst()
            .map { $0.searchUsageLog() }
            .eraseToAnyPublisher()
    }

    let userSwitcherViewModel: UserSpaceSwitcherViewModel
    let completion: (VaultListCompletion) -> Void

    private static let suggestedItemsMaxCount = 6

    private var cancellables = Set<AnyCancellable>()

    private let vaultItemRowModelFactory: VaultItemRowModel.Factory

    private let queue = DispatchQueue(label: "globalSearch", qos: .userInitiated)

    private let vaultItemsService: VaultItemsServiceProtocol
    private let capabilityService: CapabilityServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let usageLogService: UsageLogServiceProtocol
    private let featureService: FeatureServiceProtocol
    private let teamSpacesService: TeamSpacesService
    private let sharingService: SharedVaultHandling

    init(
        vaultItemsService: VaultItemsServiceProtocol,
        capabilityService: CapabilityServiceProtocol,
        sharingService: SharedVaultHandling,
        featureService: FeatureServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        teamSpacesService: TeamSpacesService,
        userSwitcherViewModel: @escaping () -> UserSpaceSwitcherViewModel,
        usageLogService: UsageLogServiceProtocol,
        vaultItemRowModelFactory: VaultItemRowModel.Factory,
        activeFilter: VaultListFilter,
        completion: @escaping (VaultListCompletion) -> Void
    ) {
        self.featureService = featureService
        self.activityReporter = activityReporter
        self.capabilityService = capabilityService
        self.vaultItemsService = vaultItemsService
        self.usageLogService = usageLogService
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.userSwitcherViewModel = userSwitcherViewModel()
        self.vaultItemRowModelFactory = vaultItemRowModelFactory
        self.activeFilter = activeFilter
        self.completion = completion
        self.secureNoteState = SecureNoteState(
            isSecureNoteDisabled: featureService.isEnabled(.disableSecureNotes),
            isSecureNoteLimited: capabilityService.state(of: .secureNotes) == .needsUpgrade
        )
        searchCategory = activeFilter.category
        setup()
    }

        func setup() {
        setupSectionPublisher()

        let searchPublisher =  $searchCriteria
            .removeDuplicates()
            .debounceExceptFirst(for: .milliseconds(200), scheduler: queue, prepend: "")

        let itemsPublisher = vaultItemsService
            .itemsPublisher(for: searchCategory)
            .receive(on: queue)

        itemsPublisher.combineLatest(searchPublisher) { items, criteria in
            guard !criteria.isEmpty else {
                return SearchResult(searchCriteria: criteria, sections: [])
            }

            let filteredItems = items.filterAndSortItemsUsingCriteria(criteria)
            let section = DataSection(name: "", items: filteredItems)
            return SearchResult(searchCriteria: criteria, sections: [section])
        }
        .receive(on: DispatchQueue.main)
        .assign(to: \.searchResult, on: self)
        .store(in: &cancellables)

        itemsPublisher
            .map { items -> [DataSection] in
                let recentSearchedItems = items
                    .filter { $0.metadata.lastLocalSearchDate != nil }
                    .sorted { left, right in
                        guard let leftDate = left.metadata.lastLocalSearchDate,
                              let rightDate = right.metadata.lastLocalSearchDate else { return false }
                        return leftDate > rightDate
                    }
                return [DataSection(name: L10n.Localizable.recentSearchTitle, items: recentSearchedItems)]
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.recentSearchSections, on: self)
            .store(in: &cancellables)

        secureNoteStatePublisher()
            .assign(to: \.secureNoteState, on: self)
            .store(in: &cancellables)
    }

    private func setupSectionPublisher() {
        let filteredItems = self.$activeFilter
            .receive(on: queue)
            .map { [vaultItemsService, teamSpacesService] in
                vaultItemsService.itemsPublisherForSection($0.section, teamSpacesService: teamSpacesService)
            }
            .switchToLatest()
            .shareReplayLatest()

        filteredItems
            .map { sections in
                var allSections = sections
                let allItems = sections.flatMap(\.items)
                if allItems.count > Self.suggestedItemsMaxCount {
                    let suggestedItems = allItems
                        .suggestedItems()
                        .prefix(Self.suggestedItemsMaxCount)

                    let suggestedSection = DataSection(
                        name: L10n.Localizable.suggested,
                        isSuggestedItems: true,
                        items: Array(suggestedItems)
                    )
                    allSections = [suggestedSection] + allSections
                }
                return allSections
            }
            .filterEmpty()
            .receive(on: DispatchQueue.main)
            .assign(to: \.sections, on: self)
            .store(in: &cancellables)
    }

    private func itemsSection(
        for category: ItemCategory,
        usingCriteria searchCriteria: String
    ) -> AnyPublisher<DataSection, Never> {
        vaultItemsService
            .itemsPublisher(for: category)
            .map { items in items.filterAndSortItemsUsingCriteria(searchCriteria) }
            .compactMap { DataSection(name: category.title, items: $0) }
            .eraseToAnyPublisher()
    }

    private func secureNoteStatePublisher() -> AnyPublisher<SecureNoteState, Never> {
        capabilityService
            .statePublisher(of: .secureNotes)
            .map { [weak self] state -> SecureNoteState in
                SecureNoteState(
                    isSecureNoteDisabled: self?.isSecureNoteDisabled ?? false,
                    isSecureNoteLimited: state == .needsUpgrade
                )
            }
            .eraseToAnyPublisher()
    }

        func count(for vaultSelectionOrigin: VaultSelectionOrigin) -> Int {
        let isFromSuggested = vaultSelectionOrigin == .suggestedItems
        return sections.filter {
            $0.isSuggestedItems == isFromSuggested
        }
        .flatMap(\.items).count
    }

        func select(_ selection: VaultSearchSelection) {
        if selection.origin == .searchResult {
            vaultItemsService.updateLastUseDate(of: [selection.item], origin: [.search])

            let searchEvent = UserEvent.SearchVaultItem(
                charactersTypedCount: searchCriteria.count,
                hasInteracted: true,
                totalCount: selection.count
            )
            activityReporter.report(searchEvent)
        }

        completion(.enterDetail(
            selection.item,
            selectVaultItem(selection))
        )
    }

    private func selectVaultItem(_ selection: VaultSearchSelection) -> UserEvent.SelectVaultItem {
        let log = UsageLogCode75GeneralActions(
            type: selection.item.usageLogType75,
            action: "open",
            subaction: VaultItemRowModel.Origin.vault.subAction
        )
        usageLogService.post(log)
        return UserEvent.SelectVaultItem(
            highlight: selection.origin.definitionHighlight,
            itemId: selection.item.userTrackingLogID,
            itemType: selection.item.vaultItemType,
            totalCount: selection.count
        )
    }

        func itemDeleteBehaviour(for item: VaultItem) async throws -> ItemDeleteBehaviour {
        return try await sharingService.deleteBehaviour(for: item)
    }

    func delete(item: VaultItem) {
        vaultItemsService.delete(item)
    }

        func add(type: VaultItem.Type) {
        completion(.addItem(.itemType(type)))
    }
}

extension VaultSearchViewModel {
    func sendSearchUsageLogFromSelection(index: Int) {
        usageLogService.post(searchResult.searchUsageLog(click: true, index: index))
    }

    func onAddItemDropdown() {
        activityReporter.reportPageShown(.homeAddItemDropdown)
    }
}

extension VaultSearchViewModel {
    func makeRowViewModel(
        _ item: VaultItem,
        isSuggestedItem: Bool,
        origin: VaultItemRowModel.Origin
    ) -> VaultItemRowModel {
        vaultItemRowModelFactory.make(
            configuration: .init(item: item, isSuggested: isSuggestedItem),
            additionalConfiguration: .init(origin: .search, highlightedString: searchCriteria)
        )
    }
}

private extension VaultListFilter {
    var section: VaultItemsSection {
        switch self {
        case .all:
            return .all
        case .credentials:
            return .credentials(sort: Just(VaultItemSorting.sortedByName).eraseToAnyPublisher())
        case .secureNotes:
            return .secureNotes(sort: Just(VaultItemSorting.sortedByName).eraseToAnyPublisher())
        case .payments:
            return .payments
        case .personalInfo:
            return .personalInfo
        case .ids:
            return .ids
        }
    }
}

extension VaultSearchViewModel {
    static var mock: VaultSearchViewModel {
        .init(
            vaultItemsService: MockServicesContainer().vaultItemsService,
            capabilityService: CapabilityService.mock,
            sharingService: SharedVaultHandlerMock(),
            featureService: .mock(),
            activityReporter: .fake,
            teamSpacesService: .mock(),
            userSwitcherViewModel: {UserSpaceSwitcherViewModel.mock},
            usageLogService: UsageLogService.fakeService,
            vaultItemRowModelFactory: .init { .mock(configuration: $0, additionialConfiguration: $1) },
            activeFilter: .all,
            completion: { _ in }
        )
    }
}
