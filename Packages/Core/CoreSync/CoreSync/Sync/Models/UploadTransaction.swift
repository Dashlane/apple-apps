import Foundation
import DashTypes
import SwiftTreats

public enum SyncTransactionActionType: String, Codable, Defaultable {
    public static var defaultValue: SyncTransactionActionType = .unknown

    case remove = "BACKUP_REMOVE"
    case edit = "BACKUP_EDIT"
    case unknown
}

public struct UploadTransaction: Encodable {
    public let action: SyncTransactionActionType
    public let content: String?
    public let identifier: Identifier
    let time: Int 
    @RawRepresented
    public var type: PersonalDataContentType?
    
    public init(action: SyncTransactionActionType,
         content: String?,
         identifier: Identifier,
         type: RawRepresented<PersonalDataContentType>) {
        self.action = action
        self.content = content
        self.identifier = identifier
        self.time = Int(Date().timeIntervalSince1970)
        self._type = type
    }
}


extension UploadTransaction {
    public init(_ transaction: UploadTransactionSession.Transaction) {
        switch transaction.action {
            case let .upload(content: content):
                self.content = content
                self.action = .edit
                
            case .remove:
                self.content = nil
                self.action = .remove
        }
        self._type = .init(transaction.type)
        self.identifier = transaction.id
        self.time = Int(Date().timeIntervalSince1970)
    }
}

extension UploadTransaction: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "UploadTransaction(action: \(action), type: \($type), identifier: \(identifier), contentSize: \(content?.count ?? 0))"
    }
}
