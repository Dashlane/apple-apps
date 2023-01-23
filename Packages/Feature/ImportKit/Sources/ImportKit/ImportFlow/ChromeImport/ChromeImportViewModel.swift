import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import UniformTypeIdentifiers
import VaultKit

public class ChromeImportViewModel: ImportViewModel, ObservableObject {

    public let kind: ImportFlowKind = .chrome
    public var step: ImportStep = .extract

    let contentTypes: [UTType] = []
    public var items: [ImportItem] = []
    public var inProgress: Bool = false
    public var isAnyItemSelected: Bool = false

    public let importService: ImportServiceProtocol
    public let iconService: IconServiceProtocol
    public let personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder? = nil
    public let activityReporter: ActivityReporterProtocol?

    init(activityReporter: ActivityReporterProtocol) {
        self.importService = ChromeImportService()
        self.iconService = IconServiceMock()
        self.activityReporter = activityReporter
    }

    public func extract() async throws {
        _ = try await importService.extract()
    }

    public func save() async throws {
        try await importService.save(vaultItems: items.filter { $0.isSelected }.map { $0.vaultItem })
    }

}

class ChromeImportService: ImportServiceProtocol {

    let applicationDatabase: ApplicationDatabase = ApplicationDBStack.mock()

    func extract() async throws -> [VaultItem] {
        assertionFailure("Inadmissible action for this kind of import flow")
        return []
    }

    func save(vaultItems: [VaultItem]) async throws {
        assertionFailure("Inadmissible action for this kind of import flow")
    }

}
