import Foundation
import DashTypes

struct BackupEntry: Codable {
    let identifier: Identifier
    let backupDate: Timestamp
}
