import Foundation
import DashlaneAPI
import DashTypes

public typealias ActivityLog = UserDeviceAPIClient.Teams.StoreActivityLogs.ActivityLogs

extension ActivityLog {
    init(logType: LogType, properties: Properties) {
                self.init(dateTime: Int(Timestamp(date: .now).millisecondsSince1970),
                  logType: logType,
                  properties: properties,
                  schemaVersion: SchemaVersion.allCases.last!,
                  uuid: UUID().uuidString)
    }
}

private extension Date {
    var millisecondsSince1970: Int64 {
        Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}
