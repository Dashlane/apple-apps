import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import SwiftTreats

public final class KibanaLogger: @unchecked Sendable, RemoteLogger {
  typealias Report = UnsignedAPIClient.Monitoring.ReportClientException.Body

  public enum Origin: String, Sendable {
    case mainApplication
    case tachyon
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

  let apiClient: UnsignedAPIClient
  private let subSection: String?
  private let outputLevel: Level
  private let origin: Origin
  @Atomic
  private var deviceId: String?
  private let platform: Platform

  public init(
    apiClient: UnsignedAPIClient,
    outputLevel: Level,
    origin: Origin,
    deviceId: String?
  ) {
    self.apiClient = apiClient
    self.subSection = nil
    self.outputLevel = outputLevel
    self.origin = origin
    self.platform = .passwordManager
    self.deviceId = deviceId
  }

  private init(
    base: KibanaLogger,
    subSection: String?,
    origin: Origin,
    deviceId: String?,
    platform: Platform
  ) {
    self.apiClient = base.apiClient
    self.subSection = subSection
    self.outputLevel = base.outputLevel
    self.origin = origin
    self.deviceId = deviceId
    self.platform = platform

  }

  private func send(
    _ message: @escaping () -> LogMessage, error: Error? = nil, level: KibanaLogger.Level,
    location: Logger.Location
  ) {
    guard outputLevel >= level, error?.shouldIgnoreForExceptionLog != true else {
      return
    }
    let message = ["\(message())", error?.logDescription]
      .compactMap { $0 }
      .joined(separator: ": ")

    let report = Report(
      action: origin.rawValue,
      message: message,
      additionalInfo: deviceId,
      exceptionType: subSection ?? "",
      file: URL(fileURLWithPath: "\(location.file)").lastPathComponent + ":\(location.line)",
      functionName: "\(location.function)",
      initialUseCaseModule: origin.rawValue,
      initialUseCaseName: subSection)

    #if !DEBUG
      Task {
        try await apiClient.monitoring.reportClientException(report)
      }
    #endif
  }

  public func configureReportedDeviceId(_ deviceId: String) {
    self.deviceId = deviceId
  }
}

extension KibanaLogger: Logger {
  public func fatal(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    send(message, level: Level.fatal, location: location)
  }

  public func fatal(_ message: @escaping () -> LogMessage, error: Error, location: Logger.Location)
  {
    send(message, error: error, level: Level.fatal, location: location)
  }

  public func error(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    send(message, level: Level.error, location: location)
  }

  public func error(_ message: @escaping () -> LogMessage, error: Error, location: Logger.Location)
  {
    send(message, error: error, level: Level.error, location: location)
  }

  public func warning(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    send(message, level: Level.warning, location: location)
  }

  public func warning(
    _ message: @escaping () -> LogMessage, error: Error, location: Logger.Location
  ) {
    send(message, error: error, level: Level.warning, location: location)
  }

  public func info(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    send(message, level: Level.info, location: location)
  }

  public func debug(_ message: @escaping () -> LogMessage, location: Logger.Location) {
    send(message, level: Level.debug, location: location)
  }

  public func sublogger(for identifier: LoggerIdentifier) -> Logger {
    KibanaLogger(
      base: self,
      subSection: identifier.stringValue,
      origin: origin,
      deviceId: deviceId,
      platform: platform)
  }
}

extension URLError {
  fileprivate var shouldIgnoreForExceptionLog: Bool {
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

extension NSError {
  fileprivate var shouldStripUserInfo: Bool {
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

extension Error {
  fileprivate var shouldIgnoreForExceptionLog: Bool {
    switch self {
    case let urlError as URLError where urlError.shouldIgnoreForExceptionLog:
      return true
    default:
      return false
    }
  }

  fileprivate var logDescription: String? {
    switch self {
    case let nsError as NSError where !nsError.userInfo.isEmpty && nsError.shouldStripUserInfo:
      return String(describing: NSError(domain: nsError.domain, code: nsError.code, userInfo: nil))
    default:
      return String(describing: self)
    }
  }
}
