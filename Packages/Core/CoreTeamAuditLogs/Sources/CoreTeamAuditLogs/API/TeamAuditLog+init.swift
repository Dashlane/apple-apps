import CoreTypes
import DashlaneAPI
import Foundation

extension TeamAuditLog {
  public init(logType: LogType, properties: Properties) {
    self.init(
      schemaVersion: .one00,
      uuid: UUID().uuidString,
      logType: logType,
      dateTime: Int(Timestamp(date: .now).millisecondsSince1970),
      properties: properties)
  }
}
