import Combine
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import Foundation
import SwiftUI
import VaultKit

@MainActor
class SidebarViewModel: ObservableObject, SessionServicesInjecting {
  @Published
  var tools: [ToolInfo] = []

  @Published
  var badgeValues: [NavigationItem: Int] = [:]

  @Published
  var selection: NavigationItem? = .home

  @Published
  var settingsDisplayed: Bool = false

  @Published
  var showCollectionAddition: Bool = false

  @Published
  var showSharedCollectionDialog: Bool = false

  @Published
  var collections: [VaultCollection]

  @Published
  var itemsCollectionAddition: (items: [VaultItem], collection: VaultCollection)?

  private let vaultCollectionsStore: VaultCollectionsStore
  private let userSpacesService: UserSpacesService
  private let deeplinkingService: DeepLinkingServiceProtocol

  let vaultCollectionEditionServiceFactory: VaultCollectionEditionService.Factory
  let settingsFlowViewModelFactory: SettingsFlowViewModel.Factory
  let collectionNamingViewModelFactory: CollectionNamingViewModel.Factory

  private var cancellables: Set<AnyCancellable> = []

  init(
    toolsService: ToolsService,
    userSpacesService: UserSpacesService,
    vaultCollectionsStore: VaultCollectionsStore,
    deeplinkingService: DeepLinkingServiceProtocol,
    settingsFlowViewModelFactory: SettingsFlowViewModel.Factory,
    collectionNamingViewModelFactory: CollectionNamingViewModel.Factory,
    vaultCollectionEditionServiceFactory: VaultCollectionEditionService.Factory
  ) {
    self.collections = vaultCollectionsStore.collections.filter(
      bySpaceId: userSpacesService.configuration.selectedSpace.personalDataId)
    self.vaultCollectionsStore = vaultCollectionsStore
    self.userSpacesService = userSpacesService
    self.deeplinkingService = deeplinkingService
    self.settingsFlowViewModelFactory = settingsFlowViewModelFactory
    self.collectionNamingViewModelFactory = collectionNamingViewModelFactory
    self.vaultCollectionEditionServiceFactory = vaultCollectionEditionServiceFactory
    toolsService
      .displayableTools()
      .assign(to: &$tools)

    self.registerPublishers()
  }

  func handleLink(_ link: DeepLink) {
    deeplinkingService.handleLink(link)
  }
}

extension SidebarViewModel {
  private func registerPublishers() {
    vaultCollectionsStore
      .$collections
      .filter(by: userSpacesService.$configuration)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] collections in
        self?.handleCollectionsChange(collections)
      }
      .store(in: &cancellables)
  }

  func space(for collection: VaultCollection) -> UserSpace? {
    return userSpacesService.configuration.displayedUserSpace(for: collection)
  }

  private func handleCollectionsChange(_ collections: [VaultCollection]) {
    self.collections = collections

    if case .collection(let collectionNavigation) = selection {
      let collection = collectionNavigation.collection
      if let correspondingCollection = collections.first(where: { $0.id == collection.id }),
        correspondingCollection.name != collection.name
      {
        selection = .collection(.init(collection: correspondingCollection))
      } else if !collections.contains(where: { $0.id == collection.id }) {
        if let nextCollection = collections.first {
          selection = .collection(.init(collection: nextCollection))
        } else {
          selection = .home
        }
      }
    }
  }

  func add(_ items: [VaultItem], to collection: VaultCollection, with toast: ToastAction) {
    Task {
      if #available(iOS 17, macOS 14, *) {
        await VaultItemDragDropTip.dragAndDropEvent.donate()
      }
    }

    let items = items.filter { !collection.contains($0) }
    guard !items.isEmpty else { return }

    if collection.isShared {
      itemsCollectionAddition = (items, collection)
      showSharedCollectionDialog = true
    } else {
      confirmAddition(of: items, to: collection, with: toast)
    }
  }

  func confirmAddition(
    of items: [VaultItem], to collection: VaultCollection, with toast: ToastAction
  ) {
    Task {
      let vaultCollectionEditionService = vaultCollectionEditionServiceFactory.make(
        collection: collection)
      try await vaultCollectionEditionService.add(items)

      let toastText: String
      if items.count > 1 {
        toastText = CoreLocalization.L10n.Core.KWVaultItem.Collections.Toast.ItemAdded
          .plural(items.count, collection.name)
      } else {
        toastText = CoreLocalization.L10n.Core.KWVaultItem.Collections.Toast.ItemAdded
          .singular(1, collection.name)
      }
      toast(toastText, image: .ds.feedback.success.outlined)
    }
  }
}
