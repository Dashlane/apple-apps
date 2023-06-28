import Foundation
import Combine
import CorePersonalData
import CoreData
import SwiftUI
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

class VaultSearchViewModel: SearchViewModel, ObservableObject, SessionServicesInjecting {
                @Published
    var sections: [DataSection] = []

        @Published
    var recentSearchSections: [DataSection] = []

                    let searchCategory: ItemCategory?

                    @Published
    var activeFilter: VaultItemsSection

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

    let userSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory
    let completion: (VaultListCompletion) -> Void

    private static let suggestedItemsMaxCount = 6

    private var cancellables = Set<AnyCancellable>()

    private let vaultItemRowModelFactory: VaultItemRowModel.Factory

    private let vaultItemsService: VaultItemsServiceProtocol
    private let capabilityService: CapabilityServiceProtocol
    private let activityReporter: ActivityReporterProtocol
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
        userSwitcherViewModelFactory: UserSpaceSwitcherViewModel.Factory,
        vaultItemRowModelFactory: VaultItemRowModel.Factory,
        activeFilter: VaultItemsSection,
        completion: @escaping (VaultListCompletion) -> Void
    ) {
        self.featureService = featureService
        self.activityReporter = activityReporter
        self.capabilityService = capabilityService
        self.vaultItemsService = vaultItemsService
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.userSwitcherViewModelFactory = userSwitcherViewModelFactory
        self.vaultItemRowModelFactory = vaultItemRowModelFactory
        self.activeFilter = activeFilter
        self.completion = completion
        self.secureNoteState = SecureNoteState(
            isSecureNoteDisabled: featureService.isEnabled(.disableSecureNotes),
            isSecureNoteLimited: capabilityService.state(of: .secureNotes) == .needsUpgrade
        )
        searchCategory = activeFilter.category
        super.init(areCollectionsEnabled: featureService.isEnabled(.collectionsLabelling))
        setup()
    }

        func setup() {
        setupSectionPublisher()

        let itemsPublisher = vaultItemsService
            .itemsPublisher(for: searchCategory)
            .receive(on: queue)

        let collectionsPublisher = vaultItemsService
            .collectionsPublisher()
            .receive(on: queue)

        setupSearchPublisher(
            itemsPublisher: itemsPublisher.eraseToAnyPublisher(),
            collectionsPublisher: collectionsPublisher.eraseToAnyPublisher()
        )

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

        setupSecureNoteStatePublisher()
    }

    private func setupSectionPublisher() {
        let filteredItems = self.$activeFilter
            .receive(on: queue)
            .map { [vaultItemsService, teamSpacesService] filter in
                vaultItemsService.itemsPublisherForSection(filter,
                                                           teamSpacesService: teamSpacesService)
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
                        type: .suggestedItems,
                        items: Array(suggestedItems)
                    )
                    allSections = [suggestedSection] + allSections
                }
                return allSections
            }
            .filterEmpty()
            .receive(on: DispatchQueue.main)
            .assign(to: &$sections)
    }

    private func setupSecureNoteStatePublisher() {
        capabilityService
            .statePublisher(of: .secureNotes)
            .eraseToAnyPublisher()
            .map { [weak self] state -> SecureNoteState in
                SecureNoteState(
                    isSecureNoteDisabled: self?.isSecureNoteDisabled ?? false,
                    isSecureNoteLimited: state == .needsUpgrade
                )
            }
            .eraseToAnyPublisher()
            .assign(to: &$secureNoteState)
    }

        func count(for vaultSelectionOrigin: VaultSelectionOrigin) -> Int {
        let isFromSuggested = vaultSelectionOrigin == .suggestedItems
        return sections.filter {
            $0.isSuggestedItems == isFromSuggested
        }
        .flatMap(\.items).count
    }

        func select(_ selection: VaultSearchSelection, isEditing: Bool = false) {
        if selection.origin == .searchResult {
            vaultItemsService.updateLastUseDate(of: [selection.item], origin: [.search])
            let collections = vaultItemsService.collections.filterAndSortItemsUsingCriteria(searchCriteria)

            let searchEvent = UserEvent.SearchVaultItem(
                charactersTypedCount: searchCriteria.count,
                collectionCount: collections.count,
                hasInteracted: true,
                totalCount: selection.count
            )
            activityReporter.report(searchEvent)
        }

        completion(.enterDetail(
            selection.item,
            selectVaultItem(selection),
            isEditing: isEditing)
        )
    }

    private func selectVaultItem(_ selection: VaultSearchSelection) -> UserEvent.SelectVaultItem {
        UserEvent.SelectVaultItem(
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
    func onAddItemDropdown() {
        activityReporter.reportPageShown(.homeAddItemDropdown)
    }
}

extension VaultSearchViewModel {
    func makeRowViewModel(
        _ item: VaultItem,
        isSuggestedItem: Bool,
        isInCollecton: Bool = false,
        origin: VaultItemRowModel.Origin
    ) -> VaultItemRowModel {
        vaultItemRowModelFactory.make(
            configuration: .init(item: item, isSuggested: isSuggestedItem),
            additionalConfiguration: .init(origin: .search, highlightedString: isInCollecton ? nil : searchCriteria)
        )
    }
}

extension VaultSearchViewModel {
    static var mock: VaultSearchViewModel {
        .init(
            vaultItemsService: MockServicesContainer().vaultItemsService,
            capabilityService: .mock(),
            sharingService: SharedVaultHandlerMock(),
            featureService: .mock(),
            activityReporter: .fake,
            teamSpacesService: .mock(),
            userSwitcherViewModelFactory: .init({ .mock }),
            vaultItemRowModelFactory: .init { .mock(configuration: $0, additionalConfiguration: $1) },
            activeFilter: .all,
            completion: { _ in }
        )
    }
}
