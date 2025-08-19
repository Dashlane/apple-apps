import Foundation

public protocol LoggerIdentifier {
  var stringValue: String { get }
}

public struct LoggerLocation {
  public let file: StaticString
  public let line: Int
  public let function: StaticString
}
public protocol Logger: Sendable {
  typealias Location = LoggerLocation

  func debug(_ message: @escaping () -> LogMessage, location: Location)

  func info(_ message: @escaping () -> LogMessage, location: Location)

  func warning(_ message: @escaping () -> LogMessage, location: Location)
  func warning(_ message: @escaping () -> LogMessage, error: Error, location: Location)

  func error(_ message: @escaping () -> LogMessage, location: Location)
  func error(_ message: @escaping () -> LogMessage, error: Error, location: Location)

  func fatal(_ message: @escaping () -> LogMessage, location: Location)
  func fatal(_ message: @escaping () -> LogMessage, error: Error, location: Location)

  func sublogger(for identifier: LoggerIdentifier) -> Logger
}

extension Logger {
  public func debug(
    _ message: @escaping @autoclosure () -> LogMessage, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    debug(message, location: Location(file: file, line: line, function: function))
  }
  public func debug(
    file: StaticString = #file, line: Int = #line, function: StaticString = #function,
    _ message: @escaping () -> LogMessage
  ) {
    debug(message, location: Location(file: file, line: line, function: function))
  }
}

extension Logger {
  public func info(
    _ message: @escaping @autoclosure () -> LogMessage, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    info(message, location: Location(file: file, line: line, function: function))
  }
  public func info(
    file: StaticString = #file, line: Int = #line, function: StaticString = #function,
    _ message: @escaping () -> LogMessage
  ) {
    info(message, location: Location(file: file, line: line, function: function))
  }
}

extension Logger {
  public func warning(
    _ message: @escaping @autoclosure () -> LogMessage, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    warning(message, location: Location(file: file, line: line, function: function))
  }
  public func warning(
    file: StaticString = #file, line: Int = #line, function: StaticString = #function,
    _ message: @escaping () -> LogMessage
  ) {
    warning(message, location: Location(file: file, line: line, function: function))
  }

  public func warning(
    _ message: @escaping @autoclosure () -> LogMessage, error: Error, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    self.warning(
      message, error: error, location: Location(file: file, line: line, function: function))
  }

  public func warning(_ message: @escaping () -> LogMessage, error: Error, location: Location) {
    self.warning(
      {
        makeDefaultErrorMessage(message: message(), error: error)
      }, location: location)
  }
}

extension Logger {
  public func error(
    _ message: @escaping @autoclosure () -> LogMessage, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    error(message, location: Location(file: file, line: line, function: function))
  }

  public func error(
    file: StaticString = #file, line: Int = #line, function: StaticString = #function,
    _ message: @escaping () -> LogMessage
  ) {
    error(message, location: Location(file: file, line: line, function: function))
  }

  public func error(
    _ message: @escaping @autoclosure () -> LogMessage, error: Error, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    self.error(
      message, error: error, location: Location(file: file, line: line, function: function))
  }

  public func error(_ message: @escaping () -> LogMessage, error: Error, location: Location) {
    self.error(
      {
        makeDefaultErrorMessage(message: message(), error: error)
      }, location: location)
  }
}

extension Logger {
  public func fatal(
    _ message: @escaping @autoclosure () -> LogMessage, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    fatal(message, location: Location(file: file, line: line, function: function))
  }
  public func fatal(
    file: StaticString = #file, line: Int = #line, function: StaticString = #function,
    _ message: @escaping () -> LogMessage
  ) {
    fatal(message, location: Location(file: file, line: line, function: function))
  }

  public func fatal(
    _ message: @escaping @autoclosure () -> LogMessage, error: Error, file: StaticString = #file,
    line: Int = #line, function: StaticString = #function
  ) {
    self.fatal(
      message, error: error, location: Location(file: file, line: line, function: function))
  }

  public func fatal(_ message: @escaping () -> LogMessage, error: Error, location: Location) {
    self.fatal(
      {
        makeDefaultErrorMessage(message: message(), error: error)
      }, location: location)
  }
}

extension Logger {
  fileprivate func makeDefaultErrorMessage(message: LogMessage, error: Error) -> LogMessage {
    "\(["\(message)", "\(error)"].joined(separator: ": "), privacy: .public)"
  }
}
