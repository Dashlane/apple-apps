import CoreTypes
import Foundation

@propertyWrapper
public struct Linked<T: PersonalDataCodable & Equatable>: Codable, Equatable {
  public var identifier: Identifier?
  public var wrappedValue: T? {
    didSet {
      identifier = wrappedValue?.id
    }
  }

  public init(_ wrappedValue: T? = nil) {
    self.wrappedValue = wrappedValue
    identifier = wrappedValue?.id
  }

  public init(identifier: Identifier?) {
    self.identifier = identifier
  }

  public var projectedValue: Identifier? {
    identifier
  }
}
