import Foundation
import DashTypes

public enum SyncError: Error {
    case downloadLatest(error: Error)
    case uploadData(error: Error, timestamp: Timestamp)
    case inProgress
    case unknown(originalError: Error?)
    case dataProcessingErrors(_ errors: [Error])
}
