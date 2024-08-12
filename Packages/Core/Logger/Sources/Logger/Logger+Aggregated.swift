import DashTypes
import Foundation

extension Array: Logger where Element == Logger {
  public func fatal(_ message: @escaping () -> String, location: Location) {
    self.forEach { $0.fatal(message, location: location) }
  }

  public func error(_ message: @escaping () -> String, location: Location) {
    self.forEach { $0.error(message, location: location) }
  }

  public func warning(_ message: @escaping () -> String, location: Location) {
    self.forEach { $0.warning(message, location: location) }
  }

  public func info(_ message: @escaping () -> String, location: Location) {
    self.forEach { $0.info(message, location: location) }
  }

  public func debug(_ message: @escaping () -> String, location: Location) {
    self.forEach { $0.debug(message, location: location) }
  }

  public func sublogger(for identifier: LoggerIdentifier) -> Logger {
    self.map { $0.sublogger(for: identifier) }
  }
}
