import SwiftUI
import CorePersonalData
import Combine
import DashlaneReportKit
import DashTypes
import CoreUserTracking
import Logger
import DashlaneAppKit
import DocumentServices
import CoreSettings
import VaultKit
import CoreSharing
import CorePremium

enum DetailViewAlert: String, Identifiable {
    case errorWhileDeletingFiles
    var id: String { rawValue }
}

final class DetailService<Item: VaultItem & Equatable>: ObservableObject {

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
    var allCollections: [VaultCollection]
    var originalAllCollections: [VaultCollection]

        @Published
    var collections: [VaultCollection]
    var originalCollections: [VaultCollection]

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
            return teamSpacesService.userSpace(for: self.item)
                ?? .personal
        } set {
            self.item.spaceId = newValue.personalDataId
            if !mode.isEditing { 
                self.save()
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

    let copySuccessPublisher = PassthroughSubject<Bool, Never>()
    let toastPublisher = PassthroughSubject<String, Never>()

        let vaultItemsService: VaultItemsServiceProtocol
    let teamSpacesService: TeamSpacesService
    let sharingService: SharedVaultHandling
    let usageLogService: UsageLogServiceProtocol
    let usageLogger: VaultItemLogger
    let activityReporter: ActivityReporterProtocol
    private let iconViewModelProvider: (VaultItem) -> VaultItemIconViewModel
    let deepLinkService: DeepLinkingServiceProtocol
    private var itemChangeSubcription: AnyCancellable?
    private var allCollectionsChangeSubscription: AnyCancellable?
    private var collectionsChangeSubscription: AnyCancellable?
    var copyActionSubcription: AnyCancellable?
    let logger: Logger
    let accessControl: AccessControlProtocol
    private let documentStorageService: DocumentStorageService
    lazy var itemPasteboard = ItemPasteboard(accessControl: accessControl, userSettings: userSettings)
    let userSettings: UserSettings
    let attachmentsListViewModelProvider: (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel
    let attachmentSectionFactory: AttachmentsSectionViewModel.Factory

        init(item: Item,
         mode: DetailMode = .viewing,
         vaultItemsService: VaultItemsServiceProtocol,
         sharingService: SharedVaultHandling,
         teamSpacesService: TeamSpacesService,
         usageLogService: UsageLogServiceProtocol,
         documentStorageService: DocumentStorageService,
         deepLinkService: DeepLinkingServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         iconViewModelProvider: @escaping (VaultItem) -> VaultItemIconViewModel,
         logger: Logger,
         accessControl: AccessControlProtocol,
         userSettings: UserSettings,
         attachmentSectionFactory: AttachmentsSectionViewModel.Factory,
         attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel) {
        self.item = item
        self.documentStorageService = documentStorageService
        self.iconViewModel = iconViewModelProvider(item)
        self.mode = mode
        self.originalItem = item
        let allCollections = vaultItemsService.collections
        self.allCollections = allCollections
        self.originalAllCollections = allCollections
        let collections = allCollections.filter(by: item)
        self.collections = collections
        self.originalCollections = collections
        self.vaultItemsService = vaultItemsService
        self.iconViewModelProvider = iconViewModelProvider
        self.teamSpacesService = teamSpacesService
        self.sharingService = sharingService
        self.usageLogService = usageLogService
        self.deepLinkService = deepLinkService
        self.userSettings = userSettings
        self.logger = logger
        self.accessControl = accessControl
        self.activityReporter = activityReporter
        self.shouldReveal = mode.isAdding
        self.attachmentSectionFactory = attachmentSectionFactory
        self.usageLogger = VaultItemLogger(usageLogService: usageLogService,
                                           vaultItemsService: vaultItemsService,
                                           teamSpacesService: teamSpacesService)
        self.attachmentsListViewModelProvider = attachmentsListViewModelProvider

        if mode.isAdding {
            self.configureDefaultTeamSpace()
        }
        self.setupUpdateOnDatabaseChange()
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
                    self?.allCollections = collections
                    self?.originalAllCollections = collections
                }
            }

        collectionsChangeSubscription = vaultItemsService
            .collectionsPublisher(for: item)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] collections in
                if self?.mode == .viewing {
                    self?.collections = collections
                    self?.originalCollections = collections
                }
            }
    }

        func cancel() {
        self.item = originalItem
        self.allCollections = originalAllCollections
        self.collections = originalCollections
        self.mode = .viewing
    }

        func prepareForSaving() throws {
        updateTeamSpaceIfForced()

                if item.anonId.isEmpty {
            item.anonId = UUID().uuidString
        }
    }

    func delete() async {
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
        self.usageLogger.logUpdate(for: self.item, from: .inApp)
        self.activityReporter.report(UserEvent.UpdateVaultItem(action: .delete,
                                                               itemId: item.userTrackingLogID,
                                                               itemType: item.vaultItemType,
                                                               space: selectedUserSpace.logItemSpace))
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
        if !updateTeamSpaceIfForced() {
            item.spaceId = teamSpacesService.selectedSpace.personalDataId
        }
    }

            @discardableResult
    func updateTeamSpaceIfForced() -> Bool {
        guard let bussinessTeam = teamSpacesService.availableBusinessTeam, bussinessTeam.shouldBeForced(on: item) else {
            return false
        }
        item.spaceId = bussinessTeam.teamId

        return true
    }
}

extension DetailService {
    static func mock<Item: VaultItem & Equatable>(item: Item, mode: DetailMode) -> DetailService<Item> {
        .init(
            item: item,
            mode: mode,
            vaultItemsService: MockServicesContainer().vaultItemsService,
            sharingService: SharedVaultHandlerMock(),
            teamSpacesService: TeamSpacesService.mock(
                selectedSpace: .personal,
                availableSpaces: [
                    .personal,
                    .business(.init(space: TeamSpaceView_Previews.bussinessSpace, anonymousTeamId: ""))
                ]
            ),
            usageLogService: UsageLogService.fakeService,
            documentStorageService: DocumentStorageService.mock,
            deepLinkService: DeepLinkingService.fakeService,
            activityReporter: .fake,
            iconViewModelProvider: { .mock(item: $0) },
            logger: FakeLogger(),
            accessControl: FakeAccessControl(accept: true),
            userSettings: UserSettings.mock,
            attachmentSectionFactory: .init { _, _ in .mock },
            attachmentsListViewModelProvider: { _, _ in .mock }
        )
    }
}
