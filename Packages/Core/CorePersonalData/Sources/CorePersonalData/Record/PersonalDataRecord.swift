import Foundation
import GRDB
import DashTypes

public struct PersonalDataRecord: Identifiable, Hashable {
    public var id: Identifier {
        return metadata.id
    }
    
    public var metadata: RecordMetadata
        public var content: PersonalDataCollection
    
    public init(metadata: RecordMetadata, content: PersonalDataCollection) {
        self.metadata = metadata
        self.content = content
    }
}

public struct RecordMetadata: Identifiable, Codable, Hashable {
    public enum CodingKeys: String, CodingKey, CaseIterable {
        case id
        case contentType
        case lastSyncTimestamp
        case syncRequestId
        case syncStatus
        case isShared
        case sharingPermission
        case pendingSharingUploadId
        case parentId
        case lastLocalUseDate
        case lastLocalSearchDate
    }
    
    public enum SyncStatus: String, Codable, Hashable {
        case pendingUpload = "BACKUP_EDIT"
        case pendingRemove = "BACKUP_REMOVE"
    }
    
    public var id: Identifier
    public let contentType: PersonalDataContentType
    
    public var lastSyncTimestamp: DashTypes.Timestamp? 
    public internal(set) var syncStatus: SyncStatus? {
        didSet {
            if oldValue != syncStatus, syncStatus != nil {
                syncRequestId = UUID().uuidString
            }
        }
    }
    public private(set) var syncRequestId: String? 

    public var isShared: Bool
    public var sharingPermission: SharingPermission?
    public var pendingSharingUploadId: String? 
    public var parentId: Identifier? 
    public var lastLocalUseDate: Date?
    public var lastLocalSearchDate: Date?

    public init(id: Identifier = .temporary,
                contentType: PersonalDataContentType,
                lastSyncTimestamp: DashTypes.Timestamp? = nil,
                syncStatus: SyncStatus? = nil,
                syncRequestId: String? = nil,
                isShared: Bool = false,
                sharingPermission: SharingPermission? = nil,
                pendingSharingUploadId: String? = nil,
                parentId: Identifier? = nil,
                lastLocalUseDate: Date? = nil,
                lastLocalSearchDate: Date? = nil) {
        self.id = id
        self.contentType = contentType
        self.lastSyncTimestamp = lastSyncTimestamp
        self.syncStatus = syncStatus
        self.syncRequestId = syncRequestId
        self.isShared = isShared
        self.sharingPermission = sharingPermission
        self.pendingSharingUploadId = pendingSharingUploadId
        self.parentId = parentId
        self.lastLocalUseDate = lastLocalUseDate
        self.lastLocalSearchDate = lastLocalSearchDate
        if syncStatus != nil && syncRequestId == nil {
            self.syncRequestId = UUID().uuidString
        }
    }
    
    public mutating func markAsPendingUpload() {
        syncStatus = .pendingUpload
    }
    
    public mutating func markAsPendingRemove() {
        syncStatus = .pendingRemove
    }
    
    public mutating func clearSyncStatus() {
        syncStatus = nil
    }
}

public extension PersonalDataCodable {
    var isShared: Bool {
        return metadata.isShared
    }
}
