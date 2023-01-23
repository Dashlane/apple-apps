import Foundation
import DashTypes

public enum DatabaseEvent: Hashable {
        case invalidation
        case incrementalChanges(Set<DatabaseChange>)
}

public struct DatabaseChange: Hashable {
    public enum Kind: Hashable {
        case insertedOrUpdated(contentType: PersonalDataContentType)
        case metadataUpdated
        case deleted
    }
    
    public let kind: Kind
    public let id: Identifier
}


extension DatabaseChange {
    init(insertedOrUpdatedRecord: PersonalDataRecord) {
        self.init(kind: .insertedOrUpdated(contentType: insertedOrUpdatedRecord.metadata.contentType), id: insertedOrUpdatedRecord.metadata.id)
    }
}

