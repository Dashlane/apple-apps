import Combine
import DashlaneAppKit
import CorePersonalData
import CoreUserTracking
import SwiftUI
import UniformTypeIdentifiers
import VaultKit

public class DashImportViewModel: ImportViewModel, ObservableObject {

    public let kind: ImportFlowKind = .dash
    public var step: ImportStep = .extract
    public let iconService: IconServiceProtocol
    public let importService: ImportServiceProtocol
    public let personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder?
    public let activityReporter: ActivityReporterProtocol?

    @Published
    var password: String = "" {
        didSet {
            guard password != oldValue else { return }
            showWrongPasswordError = false
        }
    }

    @Published
    var attempts: Int = 0

    @Published
    public var inProgress: Bool = false

    @Published
    public var isAnyItemSelected: Bool = true

    @Published
    var shouldDisplayError: Bool = false

    @Published
    var showWrongPasswordError: Bool = false

    @Published
    public var items: [ImportItem] = [] {
        didSet {
            observeSelectionChanges()
        }
    }

    private var cancellables: Set<AnyCancellable> = []

    init(
        importService: ImportServiceProtocol,
        iconService: IconServiceProtocol,
        personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder,
        activityReporter: ActivityReporterProtocol
    ) {
        self.importService = importService
        self.iconService = iconService
        self.personalDataURLDecoder = personalDataURLDecoder
        self.activityReporter = activityReporter
    }

    private init(
        importService: ImportServiceProtocol,
        iconService: IconServiceProtocol,
        items: [ImportItem]
    ) {
        self.importService = importService
        self.iconService = iconService
        self.personalDataURLDecoder = nil
        self.items = items
        self.activityReporter = nil
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
    func validate(completion: @escaping (Result<Void, Error>) -> Void) {
        showWrongPasswordError = false
        inProgress = true

        Task {
            do {
                try await importService.unlock(usingPassword: password)
                do {
                    try await self.extract()
                    self.inProgress = false
                    completion(.success)
                } catch {
                    completion(.failure(error))
                }
            } catch {
                self.inProgress = false
                self.showWrongPasswordError = true
                self.attempts += 1
                self.report(.wrongFilePassword)
            }
        }
    }

    @MainActor
    public func extract() async throws {
        step = .extract

        do {
            items = try await importService.extract().map { .init(vaultItem: $0, personalDataURLDecoder: personalDataURLDecoder) }
        } catch {
            report(.wrongFileStructure)
            throw error
        }
    }

    public func save() async throws {
        defer {
            inProgress = false
        }

        step = .save
        inProgress = true

        let vaultItems = items.compactMap { $0.isSelected ? $0.vaultItem : nil }
        do {
            try await importService.save(vaultItems: vaultItems)
            reportSave(of: vaultItems)
        } catch {
            report(.failureDuringImport)
            throw error
        }
    }

}

extension DashImportViewModel {

    public static var mock: DashImportViewModel {
        return DashImportViewModel(
            importService: DashImportService.mock,
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
