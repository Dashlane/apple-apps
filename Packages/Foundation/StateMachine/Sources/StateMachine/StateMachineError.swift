import Foundation

public struct StateMachineError: Hashable, Sendable {

  private enum ErrorType: Error {
    case unknown
  }

  public let underlyingError: Error

  public static func == (lhs: StateMachineError, rhs: StateMachineError) -> Bool {
    return lhs.underlyingError.localizedDescription == rhs.underlyingError.localizedDescription
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(underlyingError.localizedDescription)
  }

  public init(underlyingError: Error) {
    self.underlyingError = underlyingError
  }

  public static var unknown: StateMachineError {
    StateMachineError(underlyingError: ErrorType.unknown)
  }
}
