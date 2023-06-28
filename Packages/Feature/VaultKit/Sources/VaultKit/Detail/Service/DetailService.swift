#if os(iOS)
import Combine
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

        @Published
    var item: Item {
        didSet {
            self.iconViewModel = iconViewModelProvider(item)
        }
    }

    @Published
    var iconViewModel: VaultItemIconViewModel

    var originalItem: Item

        @Published
    var allVaultCollections: [VaultCollection]
    var originalAllVaultCollections: [VaultCollection]

        @Published
    var itemCollections: [VaultCollection]
    var originalItemCollections: [VaultCollection]

                @Published
    var unusedCollections: [VaultCollection]

    @Published
    var mode: DetailMode {
        didSet {
            reportDetailViewAppearance()
        }
    }

    @Published
    var shouldReveal: Bool

    var canSave: Bool {
        return mode == .updating || mode.isAdding && item.isValid
    }

    var availableUserSpaces: [UserSpace] {
        return teamSpacesService.availableSpaces.filter { $0 != .both}
    }

    var selectedUserSpace: UserSpace {
        get {
            teamSpacesService.userSpace(for: item) ?? .personal
        }
        set {
            item.spaceId = newValue.personalDataId
            updateCollectionsAfterSpaceChange()

            if !mode.isEditing { 
                save()
            }
        }
    }

    var isUserSpaceForced: Bool {
        guard let businessTeam = teamSpacesService.businessTeam(for: item) else {
            return false
        }

        return businessTeam.shouldBeForced(on: item)
    }

    var advertiseUserActivity: Bool {
        return mode == .viewing && userSettings[.advancedSystemIntegration] == true
    }

    @Published
    var hasSecureAccess: Bool = false

    @Published
    var isLoading: Bool = false

    @Published
    var alert: DetailViewAlert?

        let eventPublisher = PassthroughSubject<DetailServiceEvent, Never>()

    private var itemChangeSubcription: AnyCancellable?
    private var allCollectionsChangeSubscription: AnyCancellable?
    private var collectionsChangeSubscription: AnyCancellable?
    var copyActionSubcription: AnyCancellable?

            public let vaultItemsService: VaultItemsServiceProtocol
    public let teamSpacesService: TeamSpacesServiceProtocol
    public let sharingService: SharedVaultHandling
    public let activityReporter: ActivityReporterProtocol
    public let deepLinkService: DeepLinkingServiceProtocol
    public let logger: Logger
    public let accessControl: AccessControlProtocol
    private let documentStorageService: DocumentStorageService
    let itemPasteboard: ItemPasteboard
    public let userSettings: UserSettings

        private let iconViewModelProvider: (VaultItem) -> VaultItemIconViewModel
    let attachmentSectionFactory: AttachmentsSectionViewModel.Factory

        public init(
        item: Item,
        mode: DetailMode = .viewing,
        vaultItemsService: VaultItemsServiceProtocol,
        sharingService: SharedVaultHandling,
        teamSpacesService: TeamSpacesServiceProtocol,
        documentStorageService: DocumentStorageService,
        deepLinkService: DeepLinkingServiceProtocol,
        activityReporter: ActivityReporterProtocol,
        iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
        attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
        logger: Logger,
        accessControl: AccessControlProtocol,
        userSettings: UserSettings,
        pasteboardService: PasteboardServiceProtocol
    ) {
        self.item = item
        self.documentStorageService = documentStorageService
        self.iconViewModel = iconViewModelProvider(item)
        self.mode = mode
        self.originalItem = item
        let allVaultCollections = vaultItemsService.collections.sortedByName()
        self.allVaultCollections = allVaultCollections
        self.originalAllVaultCollections = allVaultCollections
        let itemCollections = allVaultCollections.filter(by: item).filter(spaceId: item.spaceId)
        self.itemCollections = itemCollections
        self.originalItemCollections = itemCollections
        self.unusedCollections = []
        self.vaultItemsService = vaultItemsService
        self.iconViewModelProvider = iconViewModelProvider
        self.attachmentSectionFactory = attachmentSectionFactory
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.deepLinkService = deepLinkService
        self.userSettings = userSettings
        self.logger = logger
        self.accessControl = accessControl
        self.activityReporter = activityReporter
        self.shouldReveal = mode.isAdding
        self.itemPasteboard = ItemPasteboard(accessControl: accessControl, pasteboardService: pasteboardService)
        if mode.isAdding {
            self.configureDefaultTeamSpace()
        }
        self.setupUpdateOnDatabaseChange()
        self.updateUnusedCollections()
    }

        private func setupUpdateOnDatabaseChange() {
        itemChangeSubcription = vaultItemsService
            .itemPublisher(for: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] item in
                if self?.mode == .viewing {
                    self?.item = item
                    self?.originalItem = item
                }
            }

        allCollectionsChangeSubscription = vaultItemsService
            .collectionsPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] collections in
                if self?.mode == .viewing {
                    self?.updateAllCollections(with: collections)
                }
            }

        collectionsChangeSubscription = vaultItemsService
            .collectionsPublisher(for: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] collections in
                if self?.mode == .viewing {
                    self?.updateCollections(with: collections)
                }
            }
    }

        public func cancel() {
        if item != originalItem || allVaultCollections != originalAllVaultCollections {
            eventPublisher.send(.cancel)
        } else {
            confirmCancel()
        }
    }

    public func confirmCancel() {
        defer {
            mode = .viewing
            updateUnusedCollections()
        }

        item = originalItem
        allVaultCollections = originalAllVaultCollections
        itemCollections = originalItemCollections
    }

        public func prepareForSaving() throws {
        updateItemTeamSpaceIfForced()
        updateCollectionsTeamSpaceIfForced()

                if item.anonId.isEmpty {
            item.anonId = UUID().uuidString
        }
    }

    public func delete() async {
        self.isLoading = true
        do {
            try await self.documentStorageService
                .documentDeleteService
                .deleteAllAttachments(of: self.item)
            await MainActor.run {
                self.isLoading = false
                self.alert = nil
                self.vaultItemsService.delete(self.item)
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
        return try await sharingService.deleteBehaviour(for: item)
    }

    func sharingPermission() -> SharingPermission? {
        return sharingService.permission(for: item)
    }

    func hasLimitedRights() -> Bool {
        return sharingPermission() == .limited
    }
}

private extension DetailService {
    func configureDefaultTeamSpace() {
        if !updateItemTeamSpaceIfForced() {
            item.spaceId = teamSpacesService.selectedSpace.personalDataId
            updateCollectionsAfterSpaceChange()
        }
    }

            @discardableResult
    func updateItemTeamSpaceIfForced() -> Bool {
        guard let businessTeam = teamSpacesService.availableBusinessTeam, businessTeam.shouldBeForced(on: item) else {
            return false
        }
        item.spaceId = businessTeam.teamId

        return true
    }

                func updateCollectionsTeamSpaceIfForced() {
        guard let businessTeam = teamSpacesService.availableBusinessTeam, businessTeam.shouldBeForced(on: item) else {
            return
        }

        for index in 0..<allVaultCollections.count {
            guard allVaultCollections[index].contains(item) else { continue }
            if allVaultCollections[index].items.count == 1 {
                allVaultCollections[index].spaceId = businessTeam.teamId
            } else {
                allVaultCollections[index].remove(item)
            }
        }
    }
}
#endif
