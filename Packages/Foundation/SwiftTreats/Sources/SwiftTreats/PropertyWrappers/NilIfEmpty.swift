import Foundation

@propertyWrapper
public struct NilIfEmpty<Value: Collection> {
  private var value: Value?

  public var wrappedValue: Value? {
    get {
      value?.isEmpty == true ? nil : value
    }
    set {
      value = newValue
    }
  }

  public init(wrappedValue: Value? = nil) {
    self.wrappedValue = wrappedValue
  }
}
