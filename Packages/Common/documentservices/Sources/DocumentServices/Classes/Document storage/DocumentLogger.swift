import Foundation
import CorePersonalData

public protocol DocumentStorageLogger {
    func logAttachment(for secureFileInfo: SecureFileInformation, action: DocumentActionType)
}

public enum DocumentActionType {
    case add, edit, delete
}

struct FakeDocumentLogger: DocumentStorageLogger {
    public init() {}
    public func logAttachment(for secureFileInfo: SecureFileInformation, action: DocumentActionType) {}
}
