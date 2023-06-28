import Combine
import DashlaneAppKit
import CorePersonalData
import CoreUserTracking
import UniformTypeIdentifiers
import VaultKit
import DashTypes
import CorePremium

@MainActor
public class CSVImportViewModel: ImportViewModel, ObservableObject, ImportKitServicesInjecting {

    public let kind: ImportFlowKind = .keychain
    public var step: ImportStep = .extract
    public let iconService: IconServiceProtocol
    public let importService: ImportServiceProtocol
    public let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    public let activityReporter: ActivityReporterProtocol
    public let teamSpacesService: CorePremium.TeamSpacesServiceProtocol
    public let didSave: () -> Void

    @Published
    public var items: [ImportItem] = [] {
        didSet {
            observeSelectionChanges()
        }
    }

    @Published
    public var inProgress: Bool = false

    @Published
    public var isAnyItemSelected: Bool = true

    private var cancellables: Set<AnyCancellable> = []

    public init(
        importService: ImportServiceProtocol,
        iconService: IconServiceProtocol,
        personalDataURLDecoder: PersonalDataURLDecoderProtocol,
        activityReporter: ActivityReporterProtocol,
        teamSpacesService: CorePremium.TeamSpacesServiceProtocol,
        didSave: @escaping () -> Void
    ) {
        self.didSave = didSave
        self.importService = importService
        self.iconService = iconService
        self.personalDataURLDecoder = personalDataURLDecoder
        self.activityReporter = activityReporter
        self.teamSpacesService = teamSpacesService
    }

    private init(
        importService: ImportServiceProtocol,
        iconService: IconServiceProtocol,
        items: [ImportItem]
    ) {
        self.importService = importService
        self.iconService = iconService
        self.personalDataURLDecoder = PersonalDataURLDecoderMock.mock()
        self.items = items
        self.activityReporter = .fake
        self.teamSpacesService = .mock()
        self.didSave = {}
    }

    func updateIsAnyItemSelected(for item: ImportItem? = nil, isSelected: Bool? = nil) {
                        if let item = item {
            let itemsSelected = items.filter(\.isSelected)
            isAnyItemSelected = !(itemsSelected.count == 1 && itemsSelected.first == item && isSelected == false)
        } else {
            isAnyItemSelected = !items.allSatisfy { !$0.isSelected }
        }
    }

    private func observeSelectionChanges() {
        cancellables.removeAll()
        updateIsAnyItemSelected()

        items.forEach { item in
            item.$isSelected.sink { [weak self, weak item] isSelected in
                self?.updateIsAnyItemSelected(for: item, isSelected: isSelected)
            }.store(in: &cancellables)
        }
    }

    @MainActor
    public func extract() async throws {
        defer {
            Task { @MainActor in
                self.inProgress = false
            }
        }

        step = .extract
        inProgress = true

        do {
            let items: [ImportItem] = try await importService.extract()
                .map { .init(vaultItem: $0) }
            guard !items.isEmpty else {
                                self.didSave()
                return
            }
            Task { @MainActor in
                self.items = items
            }
        } catch {
            report(.wrongFileStructure, importDataStep: .selectFile)
            throw error
        }
    }

    public func save(in userSpace: UserSpace?) async throws {

        if userSpace == nil && !availableSpaces.isEmpty {
                        throw ImportViewModelError.needsB2BSpace
        }

        defer {
            inProgress = false
        }

        step = .save
        inProgress = true

        let vaultItems = items.selectedItemsWithSpace(userSpace, businessTeam: teamSpacesService.businessTeamsInfo.availableBusinessTeam)
        do {
                        try await importService.save(items: .init(items: vaultItems))

            didSave()
            reportSave(of: vaultItems, preFilterItemsCount: items.count)
        } catch {
            report(.failureDuringImport, importDataStep: .previewItemsToImport)
        }
    }

}

extension [ImportItem] {

    func selectedItemsWithSpace(_ space: UserSpace?, businessTeam: BusinessTeam?) -> [VaultItem] {

        self
            .compactMap { $0.isSelected ? $0.vaultItem : nil }
            .compactMap {
                var copy = $0
                if let businessTeam, businessTeam.shouldBeForced(on: $0) {
                                        copy.spaceId = businessTeam.teamId
                } else {
                    copy.spaceId = space?.id
                }
                return copy
            }
    }
}

extension VaultItem {
    func update(spaceId: String?) -> VaultItem {
        var copy = self
        copy.spaceId = spaceId
        return copy
    }
}

extension CSVImportViewModel {

    static var mock: CSVImportViewModel {
        return CSVImportViewModel(
            importService: CSVImportService.mock,
            iconService: IconServiceMock(),
            items: [
                .init(vaultItem: Address()),
                .init(vaultItem: BankAccount()),
                .init(vaultItem: Company()),
                .init(vaultItem: Credential()),
                .init(vaultItem: DrivingLicence())
            ]
        )
    }

}
