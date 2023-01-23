import Foundation
import DashTypes

public struct ConsoleLogger: Logger {
    public init() {
        
    }
    
    public func debug(_ message: @escaping () -> String, location: Location) {
        NSLog("\(location.file):\(location.line) \(message())")
    }
    
    public func info(_ message: @escaping () -> String, location: Location) {
        NSLog("\(location.file):\(location.line) \(message())")
    }
    
    public func warning(_ message: @escaping () -> String, location: Location) {
        NSLog("\(location.file):\(location.line) \(message())")
    }
    
    public func error(_ message: @escaping () -> String, location: Location) {
        NSLog("\(location.file):\(location.line) \(message())")
    }
    
    public func fatal(_ message: @escaping () -> String, location: Location) {
        NSLog("\(location.file):\(location.line) \(message())")
    }
    
    public func sublogger(for identifier: LoggerIdentifier) -> Logger {
        self
    }
}
