import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import UniformTypeIdentifiers
import VaultKit
import CorePremium

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
    public let teamSpacesService: CorePremium.TeamSpacesServiceProtocol

    @MainActor
    init(activityReporter: ActivityReporterProtocol,
         teamSpacesService: CorePremium.TeamSpacesServiceProtocol,
         personalDataURLDecoder: PersonalDataURLDecoderProtocol) {
        self.importService = ChromeImportService()
        self.iconService = IconServiceMock()
        self.activityReporter = activityReporter
        self.teamSpacesService = teamSpacesService
        self.personalDataURLDecoder = personalDataURLDecoder
    }

    public func extract() async throws {
        _ = try await importService.extract()
    }

    public func save(in userSpace: CorePremium.UserSpace?) async throws {
        let vaultItems = items.selectedItemsWithSpace(userSpace, businessTeam: teamSpacesService.businessTeamsInfo.availableBusinessTeam)
        try await importService.save(items: .init(items: vaultItems))
    }
}

class ChromeImportService: ImportServiceProtocol {

    let applicationDatabase: ApplicationDatabase = ApplicationDBStack.mock()

    func extract() async throws -> [VaultItem] {
        assertionFailure("Inadmissible action for this kind of import flow")
        return []
    }

    func save(_ vaultItems: [VaultItem]) async throws {
        assertionFailure("Inadmissible action for this kind of import flow")
    }

}
