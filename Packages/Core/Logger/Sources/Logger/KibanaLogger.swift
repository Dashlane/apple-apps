import Foundation
import DashTypes
import SwiftTreats

public class KibanaLogger {
    public enum Origin: String {
        case mainApplication
        case tachyon
        case safari
        case authenticator
    }

    private enum Key: String {
        case code
        case level
        case action 
        case type
        case message
        case version
        case osName = "od"
        case osVersion
        case stack
        case exceptionType = "exceptiontype"
        case functionName
        case line
        case file
        case legacy
        case additionalInfo
    }

    public enum Level: Int, Comparable {
        public static func < (lhs: KibanaLogger.Level, rhs: KibanaLogger.Level) -> Bool {
            lhs.rawValue < rhs.rawValue
        }

        case fatal
        case error
        case warning
        case info
        case debug

        fileprivate var criticality: ExceptionCriticality {
            self < .warning ? .error : .warning
        }

        var description: String {
            switch self {
            case .fatal:
                return "fatal"
            case .warning:
                return "Warning"
            case .error:
                return "error"
            case .info:
                return "info"
            case .debug:
                return "debug"
            }
        }
    }

        public enum ExceptionCriticality: Int, Encodable {
        case unknown = 0
        case warning = 1
        case error = 2
    }

    struct ExceptionLogResponse: ResponseParserProtocol {
        public typealias ParsedResponse = Void
        public init() {

        }
        public func parse(data: Data) throws { }
    }

    let webService: LegacyWebService
    private let subSection: String?
    private let outputLevel: Level
    private let origin: Origin
    private var deviceId: String?
    private let platform: Platform

    public init(webService: LegacyWebService,
                outputLevel: Level,
                origin: Origin) {
        self.webService = webService
        self.subSection = nil
        self.outputLevel = outputLevel
        self.origin = origin
        self.platform = origin == .authenticator ? .authenticator : .passwordManager
    }

    private init(base: KibanaLogger,
                 subSection: String?,
                 origin: Origin,
                 deviceId: String?,
                 platform: Platform) {
        self.webService = base.webService
        self.subSection = subSection
        self.outputLevel = base.outputLevel
        self.origin = origin
        self.deviceId = deviceId
        self.platform = platform
    }

    private func send(_ message: @escaping () -> String, error: Error? = nil, level: Level, location: Location) {
        guard outputLevel >= level, error?.shouldIgnoreForExceptionLog != true else {
            return
        }
        let message = [message(), error?.logDescription]
            .compactMap { $0 }
            .joined(separator: ": ")

        let appVersion = Bundle.main.appVersion() ?? "unknown"
        let osVersion =  System.version
        let osName: String = System.systemName
        let filename = URL(fileURLWithPath: "\(location.file)").lastPathComponent
        let params: [String: Encodable] = [
            Key.type.rawValue: platform.rawValue,
            Key.version.rawValue: appVersion,
            Key.osName.rawValue: osName,
            Key.osVersion.rawValue: osVersion,
            Key.exceptionType.rawValue: subSection ?? "",
            Key.code.rawValue: level.criticality.rawValue,
            Key.level.rawValue: level.rawValue,
            Key.action.rawValue: origin.rawValue, 
            Key.message.rawValue: message,
            Key.line.rawValue: location.line,
            Key.functionName.rawValue: "\(location.function)",
            Key.file.rawValue: filename,
            Key.additionalInfo.rawValue: deviceId ?? ""
        ]

        #if !DEBUG
        webService.sendRequest(to: "_",
                               using: .post,
                               params: params,
                               contentFormat: .queryString,
                               needsAuthentication: false,
                               responseParser: ExceptionLogResponse(),
                               timeout: nil) { _ in
        }
        #endif
    }

    public func configureReportedDeviceId(_ deviceId: String) {
        self.deviceId = deviceId
    }
}

extension KibanaLogger: Logger {
    public func fatal(_ message: @escaping () -> String, location: Location) {
        send(message, level: .fatal, location: location)
    }

    public func fatal(_ message: @escaping () -> String, error: Error, location: Location) {
        send(message, error: error, level: .fatal, location: location)
    }

    public func error(_ message: @escaping () -> String, location: Location) {
        send(message, level: .error, location: location)
    }

    public func error(_ message: @escaping () -> String, error: Error, location: Location) {
        send(message, error: error, level: .error, location: location)
    }

    public func warning(_ message: @escaping () -> String, location: Location) {
        send(message, level: .warning, location: location)
    }

    public func warning(_ message: @escaping () -> String, error: Error, location: Location) {
        send(message, error: error, level: .warning, location: location)
    }

    public func info(_ message: @escaping () -> String, location: Location) {
        send(message, level: .info, location: location)
    }

    public func debug(_ message: @escaping () -> String, location: Location) {
        send(message, level: .debug, location: location)
    }

    public func sublogger(for identifier: LoggerIdentifier) -> Logger {
        KibanaLogger(base: self,
                     subSection: identifier.stringValue,
                     origin: origin,
                     deviceId: deviceId,
                     platform: platform)
    }
}

public extension KibanaLogger {
            struct ExceptionLogRequest: Encodable {
        let action: String
        let type: String = "safari_extension" 
        let code: ExceptionCriticality

        let message: String?
        let stack: String?
        let exceptiontype: String?
        let line: Int?
        let file: String?
        let legacy: Bool?

        public init(action: String, code: KibanaLogger.ExceptionCriticality, message: String?, stack: String?, exceptiontype: String?, line: Int?, file: String?, legacy: Bool?) {
            self.action = action
            self.code = code
            self.message = message
            self.stack = stack
            self.exceptiontype = exceptiontype
            self.line = line
            self.file = file
            self.legacy = legacy
        }
    }

    func post(_ exception: ExceptionLogRequest) {
        self.debug("creating software log: \(exception)")

        webService.sendRequest(to: "_",
                               using: .post,
                               params: exception.encodedBody,
                               contentFormat: .queryString,
                               needsAuthentication: false,
                               responseParser: ExceptionLogResponse(),
                               timeout: nil) { result in
            self.debug("creating software log result: \(result)")
        }
    }
}

public extension KibanaLogger.ExceptionLogRequest {
    var encodedBody: [String: Encodable] {
        var result = [
            "action": action,
            "type": type,
            "code": "\(code)"
        ]

        if let message = message {
            result["message"] = message
        }
        if let stack = stack {
            result["stack"] = stack
        }
        if let exceptiontype = exceptiontype {
            result["exceptiontype"] = exceptiontype
        }
        if let line = line {
            result["line"] = "\(line)"
        }
        if let file = file {
            result["file"] = file
        }
        if let legacy = legacy {
            result["legacy"] = "\(legacy)"
        }

        return result
    }
}

private extension URLError {
                var shouldIgnoreForExceptionLog: Bool {
        switch self.code {
            case .badServerResponse,
                 .cancelled,
                 .networkConnectionLost,
                 .notConnectedToInternet,
                 .redirectToNonExistentLocation,
                 .timedOut,
                 .unknown:
                return true
            default:
                return false

        }
    }
}

private extension NSError {
        var shouldStripUserInfo: Bool {
        switch domain {
            case URLError.errorDomain,
                 CocoaError.errorDomain,
                 POSIXError.errorDomain:
                return true
            default:
                return false

        }
    }
}

private extension Error {
        var shouldIgnoreForExceptionLog: Bool {
        switch self {
            case let urlError as URLError where urlError.shouldIgnoreForExceptionLog:
                return true
            default:
                return false
        }
    }

    var logDescription: String? {
        switch self {
                        case let nsError as NSError where !nsError.userInfo.isEmpty && nsError.shouldStripUserInfo:
                return String(describing: NSError(domain: nsError.domain, code: nsError.code, userInfo: nil))
            default:
                return String(describing: self)
        }
    }
}
