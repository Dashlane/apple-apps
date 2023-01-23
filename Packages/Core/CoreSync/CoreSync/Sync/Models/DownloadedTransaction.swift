import Foundation
import DashTypes
import SwiftTreats

public struct DownloadedTransaction: Codable, Equatable {
    public let action: SyncTransactionActionType
    public let backupDate: Timestamp 
    public let content: String?
    public let identifier: Identifier
    @RawRepresented
    public var type: PersonalDataContentType?

    static func initialTransaction(withSettings settings: String) -> DownloadedTransaction {
        return DownloadedTransaction(action: .edit, backupDate: Timestamp.now, content: settings, identifier: Identifier("SETTINGS_userId"), type: .init(.settings))
    }
}

extension DownloadedTransaction: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Transaction(action: \(action), type: \($type), identifier: \(identifier), backupDate: \(backupDate), contentSize: \(content?.count ?? 0))"
    }
}
