import Foundation
import DashTypes
import os

public typealias Logger = DashTypes.Logger
typealias OSLogger = os.Logger

public struct LocalLogger: Logger {
    let backend: OSLogger
    let category: String?

    public init(category: String? = nil) {
        if let category = category {
            backend = OSLogger(subsystem: ["com.dashlane", category].joined(separator: "."), category: category)
        } else {
            backend = OSLogger()
        }
        self.category = category
    }

    private var shouldDisplayDebugAndInfo: Bool {
        guard let category = category else {
            #if DEBUG
            return true
            #else
            return false
            #endif
        }

        return Self.activeLogs.contains(category)
    }

    public func fatal(_ message: @escaping () -> String, location: Logger.Location) {
        backend.critical("‼️ \(location)\n\t\(message())")
    }

    public func error(_ message: @escaping () -> String, location: Logger.Location) {
        backend.error("❗️\(location)\n\t\(message())")
    }

    public func warning(_ message: @escaping () -> String, location: Logger.Location) {
        backend.warning("⚠️ \(location)\n\t\(message())")
    }

    public func info(_ message: @escaping () -> String, location: Logger.Location) {
        guard shouldDisplayDebugAndInfo else {
            return
        }

        backend.info("ℹ️ \(location)\n\t\(message())")
    }

    public func debug(_ message: @escaping () -> String, location: Logger.Location) {
        guard shouldDisplayDebugAndInfo else {
            return
        }

        backend.debug("🔍 \(location)\n\t\(message())")
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
