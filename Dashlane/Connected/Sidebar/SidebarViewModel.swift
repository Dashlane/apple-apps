import Combine
import CorePersonalData
import CorePremium
import Foundation
import SwiftUI
import VaultKit

class SidebarViewModel: ObservableObject, SessionServicesInjecting {
        @Published
    var tools: [ToolInfo] = []

    @Published
    var collections: [VaultCollection]

    @Published
    var badgeValues: [NavigationItem: String] = [:]

    @Published
    var selection: NavigationItem?

    @Published
    var settingsDisplayed: Bool = false

        private let vaultItemsService: VaultItemsServiceProtocol
    private let teamSpacesService: VaultKit.TeamSpacesServiceProtocol
    let deeplinkingService: DeepLinkingServiceProtocol

        let settingsFlowViewModelFactory: SettingsFlowViewModel.Factory
    let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory

        private var cancellables: Set<AnyCancellable> = []

    init(
        toolsService: ToolsService,
        teamSpacesService: VaultKit.TeamSpacesServiceProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        deeplinkingService: DeepLinkingServiceProtocol,
        settingsFlowViewModelFactory: SettingsFlowViewModel.Factory,
        collectionNamingViewModelFactory: CollectionNamingViewModel.Factory
    ) {
        self.collections = vaultItemsService.collections.filter(spaceId: teamSpacesService.selectedSpace.personalDataId)
        self.vaultItemsService = vaultItemsService
        self.teamSpacesService = teamSpacesService
        self.deeplinkingService = deeplinkingService
        self.settingsFlowViewModelFactory = settingsFlowViewModelFactory
        self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
        toolsService
            .displayableTools()
            .assign(to: &$tools)

        self.registerPublishers()
    }

    private func registerPublishers() {
        vaultItemsService
            .collectionsPublisher()
            .filter(by: teamSpacesService.selectedSpacePublisher)
            .sink { [weak self] collections in
                self?.handleCollectionsChange(collections)
            }
            .store(in: &cancellables)
    }

    func space(for collection: VaultCollection) -> UserSpace? {
        guard teamSpacesService.availableSpaces.count > 1 else { return nil }
        return teamSpacesService.displayedUserSpace(for: collection) ?? teamSpacesService.selectedSpace
    }

    private func handleCollectionsChange(_ collections: [VaultCollection]) {
        self.collections = collections

        if case .collection(let collectionNavigation) = selection {
            let collection = collectionNavigation.collection
            if let correspondingCollection = collections.first(where: { $0.id == collection.id }),
               correspondingCollection.name != collection.name {
                                selection = .collection(.init(collection: correspondingCollection))
            } else if !collections.contains(where: { $0.id == collection.id }) {
                                if let nextCollection = collections.sortedByName().first {
                    selection = .collection(.init(collection: nextCollection))
                } else {
                    selection = .home
                }
            }
        }
    }
}
