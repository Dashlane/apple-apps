import Combine
import CoreActivityLogs
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSettings
import CoreSharing
import CoreUserTracking
import DashTypes
import DocumentServices
import Logger
import SwiftUI
import UIComponents

public enum DetailViewAlert: String, Identifiable {
  case errorWhileDeletingFiles
  public var id: String { rawValue }
}

public enum DetailServiceEvent {
  case copy(_ success: Bool)
  case save
  case cancel
  case domainsUpdate
}

public final class DetailService<Item: VaultItem & Equatable>: ObservableObject {

  public var item: Item {
    vaultItemEditionService.item
  }

  var itemCollections: [VaultCollection] {
    vaultCollectionEditionService.itemCollections
  }

  @Published var iconViewModel: VaultItemIconViewModel

  @Published var mode: DetailMode {
    didSet {
      reportDetailViewAppearance()
    }
  }

  var canSave: Bool {
    mode.isEditing && item.isValid
  }

  var availableUserSpaces: [UserSpace] {
    return userSpacesService.configuration.availableSpaces.filter { $0 != .both }
  }

  var selectedUserSpace: UserSpace {
    get {
      userSpacesService.configuration.editingUserSpace(for: item)
    }
    set {
      vaultItemEditionService.item.spaceId = newValue.personalDataId
      vaultCollectionEditionService.updateCollectionsAfterSpaceChange()

      if !mode.isEditing {
        Task {
          await save()
        }
      }
    }
  }

  var isUserSpaceForced: Bool {
    return !userSpacesService.configuration.canSelectSpace(for: item)
  }

  var advertiseUserActivity: Bool {
    return mode == .viewing && userSettings[.advancedSystemIntegration] == true
  }

  @Published var shouldReveal: Bool = false
  @Published var isLoading: Bool = false
  @Published var isSaving: Bool = false {
    didSet {
      vaultCollectionEditionService.isSaving = isSaving
    }
  }
  @Published public var isFrozen: Bool = false

  @Published var alert: DetailViewAlert?

  let eventPublisher = PassthroughSubject<DetailServiceEvent, Never>()
  var copyActionSubcription: AnyCancellable?
  private var cancellables: Set<AnyCancellable> = []

  let vaultItemEditionService: VaultItemEditionService<Item>
  let vaultCollectionEditionService: VaultCollectionAndItemEditionService
  let vaultStateService: VaultStateServiceProtocol
  public let vaultItemDatabase: VaultItemDatabaseProtocol
  public let vaultItemsStore: VaultItemsStore
  public let userSpacesService: UserSpacesService
  public let sharingService: SharedVaultHandling
  public let activityReporter: ActivityReporterProtocol
  public let deepLinkService: DeepLinkingServiceProtocol
  public let logger: Logger
  private let documentStorageService: DocumentStorageService
  let pasteboardService: PasteboardServiceProtocol
  public let userSettings: UserSettings
  public let canLock: Bool

  private let iconViewModelProvider: (VaultItem) -> VaultItemIconViewModel
  let attachmentSectionFactory: AttachmentsSectionViewModel.Factory

  public init(
    item: Item,
    canLock: Bool,
    mode: DetailMode = .viewing,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultStateService: VaultStateServiceProtocol,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    documentStorageService: DocumentStorageService,
    deepLinkService: DeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
    attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
    logger: Logger,
    userSettings: UserSettings,
    pasteboardService: PasteboardServiceProtocol
  ) {
    self.documentStorageService = documentStorageService
    self.iconViewModel = iconViewModelProvider(item)
    self.canLock = canLock
    self.mode = mode
    self.vaultItemsStore = vaultItemsStore
    self.vaultItemDatabase = vaultItemDatabase
    self.vaultStateService = vaultStateService
    self.iconViewModelProvider = iconViewModelProvider
    self.attachmentSectionFactory = attachmentSectionFactory
    self.userSpacesService = userSpacesService
    self.sharingService = sharingService
    self.deepLinkService = deepLinkService
    self.userSettings = userSettings
    self.logger = logger
    self.activityReporter = activityReporter
    self.shouldReveal = mode.isAdding
    self.pasteboardService = pasteboardService
    self.vaultItemEditionService = .init(
      item: item,
      mode: .constant(mode),
      vaultItemDatabase: vaultItemDatabase,
      sharingService: sharingService,
      userSpacesService: userSpacesService,
      documentStorageService: documentStorageService,
      activityReporter: activityReporter
    )
    self.vaultCollectionEditionService = .init(
      item: item,
      mode: .constant(mode),
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService
    )

    plugModeBindingOnEditionServices()
    registerPublishers()

    if mode.isAdding {
      configureDefaultSpace()
    }
  }

  private func plugModeBindingOnEditionServices() {
    vaultItemEditionService.update(using: Binding(get: { self.mode }, set: { self.mode = $0 }))
    vaultCollectionEditionService.update(
      using: Binding(get: { self.mode }, set: { self.mode = $0 }),
      itemPublisher: vaultItemEditionService.$item.eraseToAnyPublisher()
    )
  }

  private func registerPublishers() {
    vaultItemEditionService
      .$item
      .receive(on: DispatchQueue.main)
      .sink { [weak self] item in
        guard let self else { return }
        self.iconViewModel = self.iconViewModelProvider(item)
      }
      .store(in: &cancellables)

    vaultStateService
      .vaultStatePublisher()
      .map { $0 == .frozen }
      .receive(on: DispatchQueue.main)
      .assign(to: &$isFrozen)
  }

  public func cancel() {
    if vaultItemEditionService.itemDidChange || vaultCollectionEditionService.collectionsDidChange()
    {
      eventPublisher.send(.cancel)
    } else {
      confirmCancel()
    }
  }

  public func confirmCancel() {
    defer {
      mode = .viewing
      vaultCollectionEditionService.updateUnusedCollections()
    }

    vaultItemEditionService.cancel()
    vaultCollectionEditionService.cancel()
  }

  public func prepareForSaving() throws {
    try vaultItemEditionService.prepareForSaving()
    vaultCollectionEditionService.updateCollectionsSpaceIfForced()
  }

  public func delete() async {
    isLoading = true
    do {
      try await vaultItemEditionService.delete()
      await MainActor.run {
        self.isLoading = false
        self.alert = nil
        self.logDelete()
      }
    } catch {
      await MainActor.run {
        self.isLoading = false
        self.alert = .errorWhileDeletingFiles
      }
    }
  }

  func logDelete() {
    let collections = itemCollections
    let item = item
    let space = selectedUserSpace
    activityReporter.report(
      UserEvent.UpdateVaultItem(
        action: .delete,
        collectionCount: collections.count,
        itemId: item.userTrackingLogID,
        itemType: item.vaultItemType,
        space: space.logItemSpace
      )
    )
  }

  func itemDeleteBehavior() async throws -> ItemDeleteBehaviour {
    try await vaultItemEditionService.itemDeleteBehavior()
  }

  func sharingPermission() -> SharingPermission? {
    vaultItemEditionService.sharingPermission()
  }

  func hasLimitedRights() -> Bool {
    vaultItemEditionService.hasLimitedRights()
  }
}

extension DetailService {
  fileprivate func configureDefaultSpace() {
    vaultItemEditionService.configureDefaultSpace()
    vaultCollectionEditionService.updateCollectionsAfterSpaceChange()
  }
}
