import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import UniformTypeIdentifiers
import VaultKit
import CorePremium

public enum ImportStep {
    case extract
    case save
}

public class ImportItem: ObservableObject, Identifiable, Equatable {

    public var id: String {
        return vaultItem.id.rawValue
    }

    private(set) var vaultItem: VaultItem

    @Published
    var isSelected: Bool

    init(vaultItem: VaultItem, isSelected: Bool = true) {
        self.vaultItem = vaultItem
        self.isSelected = isSelected
    }

    public static func == (lhs: ImportItem, rhs: ImportItem) -> Bool {
        return lhs.id == rhs.id
    }
}

enum ImportViewModelError: Error {
    case needsB2BSpace
}

@MainActor public protocol ImportViewModel {

    var kind: ImportFlowKind { get }
    var step: ImportStep { get set }
        var items: [ImportItem] { get set }
    var inProgress: Bool { get set }
    var isAnyItemSelected: Bool { get set }

    var importService: ImportServiceProtocol { get }
    var iconService: IconServiceProtocol { get }
    var personalDataURLDecoder: PersonalDataURLDecoderProtocol { get }
    var activityReporter: ActivityReporterProtocol { get }
    var teamSpacesService: CorePremium.TeamSpacesServiceProtocol { get }

    func extract() async throws

    func save(in userSpace: UserSpace?) async throws

}

extension ImportViewModel {
    var availableSpaces: [UserSpace] {
        return teamSpacesService.availableSpaces.filter {
            $0 != .both
        }
    }
}

extension ImportViewModel {

    func report(_ importDataStatus: Definition.ImportDataStatus,
                importDataStep: Definition.ImportDataStep) {
        let kind = kind
        activityReporter.report(UserEvent.ImportData(backupFileType: kind.backupFileType,
                                                     importDataStatus: importDataStatus,
                                                     importDataStep: importDataStep,
                                                     importSource: kind.importSource,
                                                     isDirectImport: false))
    }

    func reportSave(of vaultItems: [VaultItem], preFilterItemsCount: Int) {
        guard let updateCredentialOrigin = kind.updateCredentialOrigin else { return }
        vaultItems.forEach {

            activityReporter.report(AnonymousEvent.UpdateCredential(action: .add,
                                            domain: $0.hashedDomainForLogs(),
                                            space: $0.userTrackingSpace))

            activityReporter.report(UserEvent.UpdateVaultItem(
                action: .add,
                itemId: $0.userTrackingLogID,
                itemType: $0.vaultItemType,
                space: .personal,
                updateCredentialOrigin: updateCredentialOrigin)
            )
        }
        let kind = kind
        activityReporter.report(UserEvent.ImportData(backupFileType: kind.backupFileType,
                                                     importDataStatus: .success,
                                                     importDataStep: .success,
                                                     importSource: kind.importSource,
                                                     importedItemsCount: vaultItems.count,
                                                     isDirectImport: false,
                                                     itemsToImportCount: preFilterItemsCount))
    }

}

extension ImportFlowKind {

    var backupFileType: Definition.BackupFileType {
        switch self {
        case .dash:
            return .secureVault
        case .keychain, .lastpass:
            return .csv
        default:
            return .unknown
        }
    }

    var updateCredentialOrigin: Definition.UpdateCredentialOrigin? {
        switch self {
        case .chrome:
            return nil
        case .dash:
            return .secureVaultImport
        case .keychain, .lastpass:
            return .csvImport
        }
    }

    var importSource: Definition.ImportSource {
        switch self {
        case .chrome:
            return .sourceChrome
        case .dash:
            return .sourceDash
        case .keychain:
            return .sourceKeychain
        case .lastpass:
            return .sourceLastpass
        }
    }
}
