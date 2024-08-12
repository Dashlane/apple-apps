import Foundation

public struct UndecodableCaseError<T>: Error {
  public let type: T.Type

  public init(_ type: T.Type) {
    self.type = type
  }
}
