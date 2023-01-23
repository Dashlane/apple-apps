import Foundation
import DashTypes
import SwiftTreats

struct DataChangeHistory: PersonalDataCodable {
    struct ChangeSet: NestedObject, Codable, Equatable {
        enum CodingKeys: String, CodingKey {
            case id
            case changedKeys = "properties"
            case previousRecordContent = "currentData"
            case modificationDate
            case removed
            case platform
            case deviceName
            case user
        }
        
        static let contentType: XMLDataType = .dataChangeSets
        
        let id: Identifier
        
                let changedKeys: Set<String>
                @Defaulted
        var previousRecordContent: PersonalDataCollection
        let modificationDate: Date?
        
        let removed: Bool
        
        let platform: String
        let deviceName: String
        let user: String
        
        internal init(id: Identifier,
                      changedKeys: Set<String>,
                      previousRecordContent: PersonalDataCollection,
                      modificationDate: Date?,
                      removed: Bool,
                      platform: String,
                      deviceName: String,
                      user: String) {
            self.id = id
            self.changedKeys = changedKeys
            self._previousRecordContent = .init(previousRecordContent)
            self.modificationDate = modificationDate
            self.removed = removed
            self.platform = platform
            self.deviceName = deviceName
            self.user = user
        }
        
    }
    
    static let contentType: PersonalDataContentType = .dataChangeHistory
    
    let id: Identifier
    let objectId: Identifier
    var objectTitle: String?
    let objectType: PersonalDataContentType
    
    let metadata: RecordMetadata
    
    var changeSets: [ChangeSet]
}
