import CoreLocalization
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import DesignSystem
import Logger
import Foundation

public class CollectionNamingViewModel: ObservableObject, VaultKitServicesInjecting {

    public enum Mode {
        case addition
        case edition(VaultCollection)
    }

        @Published
    var collectionName: String {
        didSet {
            updateErrorIfNeeded()
        }
    }

    @Published
    var showNamingError: Bool = false

    @Published
    var inProgress: Bool = false

    let mode: Mode

    private var collection: VaultCollection

    var availableUserSpaces: [UserSpace] {
        teamSpacesService.availableSpaces.filter { $0 != .both }
    }

    var collectionUserSpace: UserSpace {
        get {
            teamSpacesService.userSpace(for: collection) ?? .personal
        }
        set {
            collection.spaceId = newValue.personalDataId
        }
    }

    var isUserSpaceForced: Bool {
        if case .edition = mode {
            return true
        } else {
            return false
        }
    }

    var canBeCreatedOrSaved: Bool {
        !formattedCollectionName.isEmpty && !showNamingError
    }

    private var formattedCollectionName: String {
        collectionName.trimmingCharacters(in: .whitespacesAndNewlines)
    }

        private let logger: Logger
    private let activityReporter: ActivityReporterProtocol
    private let vaultItemsService: VaultItemsServiceProtocol
    private let teamSpacesService: TeamSpacesServiceProtocol

    public init(
        mode: CollectionNamingViewModel.Mode,
        logger: Logger,
        activityReporter: ActivityReporterProtocol,
        vaultItemsService: VaultItemsServiceProtocol,
        teamSpacesService: TeamSpacesServiceProtocol
    ) {
        switch mode {
        case .addition:
            self.collectionName = ""
                                    let spaceId: String
            if teamSpacesService.selectedSpace != .both {
                spaceId = teamSpacesService.selectedSpace.personalDataId
            } else {
                spaceId = teamSpacesService.availableBusinessTeam?.teamId ?? UserSpace.personal.id
            }
            self.collection = VaultCollection(spaceId: spaceId)
        case .edition(let collection):
            self.collectionName = collection.name
            self.collection = collection
        }
        self.mode = mode
        self.logger = logger
        self.activityReporter = activityReporter
        self.vaultItemsService = vaultItemsService
        self.teamSpacesService = teamSpacesService
    }

    private func updateErrorIfNeeded() {
        let collectionsInCurrentCollectionSpace = vaultItemsService.collections.filter(spaceId: collectionUserSpace.id)
        if collectionsInCurrentCollectionSpace.contains(where: { $0.name == formattedCollectionName }) {
                        if case .edition(let collection) = mode {
                showNamingError = formattedCollectionName != collection.name
            } else {
                showNamingError = true
            }
        } else {
            showNamingError = false
        }
    }
}

#if os(iOS)
extension CollectionNamingViewModel {
    func cancel(completion: @escaping (CollectionNamingView.Completion) -> Void) {
        completion(.cancel)
    }

    func createOrSave(with toast: ToastAction, completion: @escaping (CollectionNamingView.Completion) -> Void) {
        guard canBeCreatedOrSaved else { return }
        inProgress = true

        collection.name = formattedCollectionName

        do {
            _ = try vaultItemsService.save(collection)
            switch mode {
            case .addition:
                toast(L10n.Core.KWVaultItem.Collections.created(formattedCollectionName), image: .ds.feedback.success.outlined)
            case .edition:
                toast(L10n.Core.KWVaultItem.Changes.saved, image: .ds.feedback.success.outlined)
            }
            reportCreationOrSaving()
            completion(.done(collection))
        } catch {
            inProgress = false
            logger[.personalData].error("Error on save", error: error)
        }
    }

    private func reportCreationOrSaving() {
        let action: Definition.CollectionAction
        switch mode {
        case .addition:
            action = .add
        case .edition:
            action = .edit
        }

        activityReporter.report(
            UserEvent.UpdateCollection(
                action: action,
                collectionId: self.collection.id.rawValue,
                isShared: self.collection.isShared,
                itemCount: self.collection.items.count
            )
        )
    }
}
#endif

extension CollectionNamingViewModel {
    public static func mock(mode: Mode) -> CollectionNamingViewModel {
        .init(
            mode: mode,
            logger: LoggerMock(),
            activityReporter: FakeActivityReporter(),
            vaultItemsService: MockVaultKitServicesContainer().vaultItemsService,
            teamSpacesService: MockVaultKitServicesContainer().teamSpacesService
        )
    }
}
