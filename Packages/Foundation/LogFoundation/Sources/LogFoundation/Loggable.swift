import Foundation

public protocol Loggable {
  func log() -> LogMessage
}

extension Loggable where Self: RawRepresentable {
  public func log() -> LogMessage {
    "\(Self.self)(\(self.rawValue, privacy: .public))"
  }
}
