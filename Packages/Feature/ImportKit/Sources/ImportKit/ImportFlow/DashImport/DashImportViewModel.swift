import Combine
import CorePersonalData
import CorePremium
import CoreUserTracking
import SwiftUI
import UniformTypeIdentifiers
import VaultKit

public class DashImportViewModel: ImportViewModel, ObservableObject, ImportKitServicesInjecting {

  enum ValidationError: Error {
    case wrongPassword
    case extractionFailed
  }

  public let kind: ImportFlowKind = .dash
  public var step: ImportStep = .extract
  public let iconService: IconServiceProtocol
  public let importService: ImportServiceProtocol
  public let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  public let activityReporter: ActivityReporterProtocol
  public let userSpacesService: UserSpacesService

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

  @MainActor
  public init(
    importService: ImportServiceProtocol,
    iconService: IconServiceProtocol,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol,
    activityReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService
  ) {
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
      }
      .store(in: &cancellables)
    }
  }

  @MainActor
  func validate() async throws {
    showWrongPasswordError = false
    inProgress = true

    do {
      try await importService.unlock(usingPassword: password)
      do {
        try await extract()
        inProgress = false
      } catch {
        throw error
      }
    } catch {
      inProgress = false
      showWrongPasswordError = true
      attempts += 1
      report(.wrongFilePassword, importDataStep: .selectDashlaneSpace)
      throw ValidationError.wrongPassword
    }
  }

  @MainActor
  public func extract() async throws {
    step = .extract

    do {
      items = try await importService.extract()
    } catch {
      report(.wrongFileStructure, importDataStep: .selectFile)
      throw ValidationError.extractionFailed
    }
  }

  public func save(in userSpace: UserSpace?) async throws {
    defer {
      inProgress = false
    }

    if userSpace == nil && availableSpaces.count > 1 {
      throw ImportViewModelError.needsSpaceSelection
    }

    step = .save
    inProgress = true

    let vaultItems = items.selectedVaultItems(
      with: userSpace, configuration: userSpacesService.configuration)
    let collections = items.compactMap(\.collection)
    do {
      try await importService.save(vaultItems, collections)
      reportSave(of: vaultItems, preFilterItemsCount: items.count)
    } catch {
      report(.failureDuringImport, importDataStep: .previewItemsToImport)
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
        .init(vaultItem: DrivingLicence()),
      ]
    )
  }

}
