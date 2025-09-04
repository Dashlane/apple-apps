import CoreTypes
import Foundation
import LogFoundation
@preconcurrency import os

public typealias Logger = LogFoundation.Logger
typealias OSLogger = os.Logger

public struct LocalLogger: Logger {
  let backend: OSLogger
  let category: String?

  public init(category: String? = nil) {
    if let category = category {
      backend = OSLogger(
        subsystem: ["com.dashlane", category].joined(separator: "."), category: category)
    } else {
      backend = OSLogger(subsystem: "com.dashlane", category: "root")
    }
    self.category = category
  }

  public func fatal(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    backend.critical("‼️ \(location, privacy: .public)\n\t\(message(), privacy: .private)")
  }

  public func error(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    backend.error("❗️\(location, privacy: .public)\n\t\(message(), privacy: .private)")
  }

  public func warning(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    backend.warning("⚠️ \(location, privacy: .public)\n\t\(message(), privacy: .private)")
  }

  public func info(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    #if DEBUG
      backend.info("ℹ️ \(location, privacy: .public)\n\t\(message(), privacy: .public)")
    #endif
  }

  public func debug(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    #if DEBUG
      guard !ProcessInfo.isTesting else {
        return
      }
      backend.debug("🔍 \(location, privacy: .public)\n\t\(message(), privacy: .public)")
    #endif
  }

  public func sublogger(for identifier: LoggerIdentifier) -> Logger {
    return LocalLogger(category: identifier.stringValue)
  }
}

extension Logger.Location: CustomStringConvertible {
  public var description: String {
    let file = URL(fileURLWithPath: String(describing: file)).lastPathComponent
    return [file, String(describing: function), String(line)].joined(separator: ":")
  }
}

extension LocalLogger {
  static let debugLogPrefix = "DEBUG_LOG_"

  static let activeLogs: [String] = {
    #if DEBUG
      let debugKeys = ProcessInfo().environment.keys.filter { $0.hasPrefix(debugLogPrefix) }
      return debugKeys.compactMap { $0.split(separator: "_").last?.lowercased() }
    #else
      return []
    #endif
  }()
}
