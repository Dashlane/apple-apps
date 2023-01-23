import Foundation

public protocol LoggerIdentifier {
    var stringValue: String {get}
}

public struct LoggerLocation {
    public let file: StaticString
    public let line: Int
    public let function: StaticString
}
public protocol Logger {
    typealias Location = LoggerLocation
    
            func debug(_ message: @escaping () -> String, location: Location)

                func info(_ message: @escaping () -> String, location: Location)

            func warning(_ message: @escaping () -> String, location: Location)
            func warning(_ message: @escaping () -> String, error: Error, location: Location)
    
        func error(_ message: @escaping () -> String, location: Location)
        func error(_ message: @escaping () -> String, error: Error, location: Location)
    
            func fatal(_ message: @escaping () -> String, location: Location)
            func fatal(_ message: @escaping () -> String, error: Error, location: Location)
    
                func sublogger(for identifier: LoggerIdentifier) -> Logger
}

public extension Logger {
            func debug(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        debug(message, location: Location(file: file, line: line, function: function))
    }
            func debug(file: StaticString = #file, line: Int = #line, function: StaticString = #function, _ message: @escaping () -> String) {
        debug(message, location: Location(file: file, line: line, function: function))
    }
}

public extension Logger {
                func info(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        info(message, location: Location(file: file, line: line, function: function))
    }
                func info(file: StaticString = #file, line: Int = #line, function: StaticString = #function, _ message: @escaping () -> String) {
        info(message, location: Location(file: file, line: line, function: function))
    }
}

public extension Logger {
            func warning(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        warning(message, location: Location(file: file, line: line, function: function))
    }
            func warning(file: StaticString = #file, line: Int = #line, function: StaticString = #function, _ message: @escaping () -> String) {
        warning(message, location: Location(file: file, line: line, function: function))
    }
    
        func warning(_ message: @escaping @autoclosure () -> String, error: Error, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        self.warning(message, error: error, location: Location(file: file, line: line, function: function))
    }
    
        func warning(_ message: @escaping () -> String, error: Error, location: Location) {
        self.warning({
            makeDefaultErrorMessage(message: message(), error: error)
        }, location: location)
    }
}

public extension Logger {
        func error(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        error(message, location: Location(file: file, line: line, function: function))
    }
    
        func error(file: StaticString = #file, line: Int = #line, function: StaticString = #function, _ message: @escaping () -> String) {
        error(message, location: Location(file: file, line: line, function: function))
    }
    
        func error(_ message: @escaping @autoclosure () -> String, error: Error, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        self.error(message, error: error, location: Location(file: file, line: line, function: function))
    }
    
        func error(_ message: @escaping () -> String, error: Error, location: Location) {
        self.error({
            makeDefaultErrorMessage(message: message(), error: error)
        }, location: location)
    }
}

public extension Logger {
            func fatal(_ message: @escaping @autoclosure () -> String, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        fatal(message, location: Location(file: file, line: line, function: function))
    }
            func fatal(file: StaticString = #file, line: Int = #line, function: StaticString = #function, _ message: @escaping () -> String) {
        fatal(message, location: Location(file: file, line: line, function: function))
    }
    
        func fatal(_ message: @escaping @autoclosure () -> String, error: Error, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
        self.fatal(message, error: error, location: Location(file: file, line: line, function: function))
    }
    
        func fatal(_ message: @escaping () -> String, error: Error, location: Location) {
        self.fatal({
            makeDefaultErrorMessage(message: message(), error: error)
        }, location: location)
    }
}


private extension Logger {
    func makeDefaultErrorMessage(message: String, error: Error) -> String {
        [message, String(describing: error)].joined(separator: ": ")
    }
}
