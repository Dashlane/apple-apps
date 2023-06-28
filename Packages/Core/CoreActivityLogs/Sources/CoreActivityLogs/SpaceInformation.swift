import Foundation

public struct SpaceInformation {
    let id: String
    let collectSensitiveDataActivityLogsEnabled: Bool

    public init(id: String, collectSensitiveDataActivityLogsEnabled: Bool) {
        self.id = id
        self.collectSensitiveDataActivityLogsEnabled = collectSensitiveDataActivityLogsEnabled
    }
}
