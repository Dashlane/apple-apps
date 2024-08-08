import DashTypes
import DashlaneAPI
import Foundation

public typealias ActivityLog = UserDeviceAPIClient.Teams.StoreActivityLogs.Body.ActivityLogsElement

extension ActivityLog {
  init(logType: LogType, properties: Properties) {
    self.init(
      schemaVersion: .one00,
      uuid: UUID().uuidString,
      logType: logType,
      dateTime: Int(Timestamp(date: .now).millisecondsSince1970),
      properties: properties)
  }
}

extension Date {
  fileprivate var millisecondsSince1970: Int64 {
    Int64((self.timeIntervalSince1970 * 1000.0).rounded())
  }
}
