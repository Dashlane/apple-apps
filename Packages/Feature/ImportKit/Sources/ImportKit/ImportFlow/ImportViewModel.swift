import DashlaneAppKit
import Foundation
import CorePersonalData
import CoreUserTracking
import UniformTypeIdentifiers
import VaultKit

public enum ImportStep {
    case extract
    case save
}

public class ImportItem: ObservableObject, Identifiable, Equatable {

    public var id: String {
        return vaultItem.anonId
    }

    private(set) var vaultItem: VaultItem

    @Published
    var isSelected: Bool

    private let personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder?

    init(vaultItem: VaultItem, isSelected: Bool = true, personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder? = nil) {
        self.vaultItem = vaultItem
        self.isSelected = isSelected
        self.personalDataURLDecoder = personalDataURLDecoder

        decodeDomain()
    }

                private func decodeDomain() {
        guard let personalDataURLDecoder = personalDataURLDecoder,
              var credential = vaultItem as? Credential,
              let url = credential.url?.rawValue
        else {
            return
        }

        credential.url = try? personalDataURLDecoder.decodeURL(url)
        vaultItem = credential
    }

    public static func == (lhs: ImportItem, rhs: ImportItem) -> Bool {
        return lhs.id == rhs.id
    }
}

public protocol ImportViewModel {

    var kind: ImportFlowKind { get }
    var step: ImportStep { get set }
    var items: [ImportItem] { get set }
    var inProgress: Bool { get set }
    var isAnyItemSelected: Bool { get set }

    var importService: ImportServiceProtocol { get }
    var iconService: IconServiceProtocol { get }
    var personalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder? { get }
    var activityReporter: ActivityReporterProtocol? { get }

    func extract() async throws
    func save() async throws

}

extension ImportViewModel {

    func report(_ importDataStatus: Definition.ImportDataStatus) {
        guard let backupFileType = kind.backupFileType else { return }
        activityReporter?.report(UserEvent.ImportData(backupFileType: backupFileType, importDataStatus: importDataStatus, importSource: kind.importSource))
    }

    func reportSave(of vaultItems: [VaultItem]) {
        guard let updateCredentialOrigin = kind.updateCredentialOrigin else { return }
        vaultItems.forEach {
            activityReporter?.report(UserEvent.UpdateVaultItem(
                action: .add,
                itemId: $0.userTrackingLogID,
                itemType: $0.vaultItemType,
                space: .personal,
                updateCredentialOrigin: updateCredentialOrigin)
            )
        }
        report(.success)
    }

}

private extension ImportFlowKind {

    var backupFileType: Definition.BackupFileType? {
        switch self {
        case .chrome:
            return nil
        case .dash:
            return .secureVault
        case .keychain:
            return .csv
        }
    }

    var updateCredentialOrigin: Definition.UpdateCredentialOrigin? {
        switch self {
        case .chrome:
            return nil
        case .dash:
            return .secureVaultImport
        case .keychain:
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
        }
    }
}
