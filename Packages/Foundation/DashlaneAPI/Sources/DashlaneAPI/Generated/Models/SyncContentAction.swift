import Foundation

public enum SyncContentAction: String, Codable, Equatable, CaseIterable {
    case backupEdit = "BACKUP_EDIT"
    case backupRemove = "BACKUP_REMOVE"
}
