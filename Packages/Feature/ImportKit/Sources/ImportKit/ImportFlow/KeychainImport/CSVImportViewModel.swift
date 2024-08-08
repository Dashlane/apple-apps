import Combine
import CorePersonalData
import CorePremium
import CoreUserTracking
import DashTypes
import UniformTypeIdentifiers
import VaultKit

@MainActor
public class CSVImportViewModel: ImportViewModel, ObservableObject, ImportKitServicesInjecting {

  public let kind: ImportFlowKind = .keychain
  public var step: ImportStep = .extract
  public let iconService: IconServiceProtocol
  public let importService: ImportServiceProtocol
  public let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  public let activityReporter: ActivityReporterProtocol
  public let userSpacesService: UserSpacesService
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
    userSpacesService: UserSpacesService,
    didSave: @escaping () -> Void
  ) {
    self.didSave = didSave
    self.importService = importService
    self.iconService = iconService
    self.personalDataURLDecoder = personalDataURLDecoder
    self.activityReporter = activityReporter
    self.userSpacesService = userSpacesService
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
    self.activityReporter = .mock
    self.userSpacesService = .mock()
    self.didSave = {}
  }

  func updateIsAnyItemSelected(for item: ImportItem? = nil, isSelected: Bool? = nil) {
    if let item = item {
      let itemsSelected = items.filter(\.isSelected)
      isAnyItemSelected =
        !(itemsSelected.count == 1 && itemsSelected.first == item && isSelected == false)
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
    if userSpace == nil && availableSpaces.count > 1 {
      throw ImportViewModelError.needsSpaceSelection
    }

    defer {
      inProgress = false
    }

    step = .save
    inProgress = true

    let vaultItems = items.selectedVaultItems(
      with: userSpace, configuration: userSpacesService.configuration)
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
  func selectedVaultItems(
    with space: UserSpace?, configuration: UserSpacesService.SpacesConfiguration
  ) -> [VaultItem] {
    self
      .compactMap { importItem in
        guard importItem.isSelected, var vaultItem = importItem.vaultItem else {
          return nil
        }

        if let forcedSpace = configuration.forcedSpace(for: vaultItem) {
          vaultItem.spaceId = forcedSpace.personalDataId
        } else {
          vaultItem.spaceId = space?.id
        }
        return vaultItem
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
        .init(vaultItem: DrivingLicence()),
      ]
    )
  }

}
