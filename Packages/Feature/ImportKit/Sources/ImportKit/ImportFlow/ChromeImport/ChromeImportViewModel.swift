import CorePersonalData
import CorePremium
import CoreUserTracking
import Foundation
import UniformTypeIdentifiers
import VaultKit

public class ChromeImportViewModel: ImportViewModel, ObservableObject, ImportKitServicesInjecting {

  public let kind: ImportFlowKind = .chrome
  public var step: ImportStep = .extract

  let contentTypes: [UTType] = []
  public var items: [ImportItem] = []
  public var inProgress: Bool = false
  public var isAnyItemSelected: Bool = false

  public let importService: ImportServiceProtocol
  public let iconService: IconServiceProtocol
  public let personalDataURLDecoder: PersonalDataURLDecoderProtocol
  public let activityReporter: ActivityReporterProtocol
  public let userSpacesService: UserSpacesService

  @MainActor
  init(
    activityReporter: ActivityReporterProtocol,
    userSpacesService: UserSpacesService,
    personalDataURLDecoder: PersonalDataURLDecoderProtocol
  ) {
    self.importService = ChromeImportService()
    self.iconService = IconServiceMock()
    self.activityReporter = activityReporter
    self.userSpacesService = userSpacesService
    self.personalDataURLDecoder = personalDataURLDecoder
  }

  public func extract() async throws {
    _ = try await importService.extract()
  }

  public func save(in userSpace: CorePremium.UserSpace?) async throws {
    let vaultItems = items.selectedVaultItems(
      with: userSpace, configuration: userSpacesService.configuration)
    try await importService.save(items: .init(items: vaultItems))
  }
}

class ChromeImportService: ImportServiceProtocol {

  let applicationDatabase: ApplicationDatabase = ApplicationDBStack.mock()

  func extract() async throws -> [ImportItem] {
    assertionFailure("Inadmissible action for this kind of import flow")
    return []
  }

  func save(_ vaultItems: [VaultItem], _ collections: [PrivateCollection]) async throws {
    assertionFailure("Inadmissible action for this kind of import flow")
  }

}
