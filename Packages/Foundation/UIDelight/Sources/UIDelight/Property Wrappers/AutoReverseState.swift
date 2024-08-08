import Foundation
import SwiftUI

@propertyWrapper
public struct AutoReverseState<Value: Equatable>: DynamicProperty {
  @State
  var value: Value

  let defaultValue: Value
  let autoReverseInterval: TimeInterval

  public var wrappedValue: Value {
    get {
      return value

    }
    nonmutating set {
      self.value = newValue
      if self.value != defaultValue {
        DispatchQueue.main.asyncAfter(deadline: .now() + self.autoReverseInterval) {
          guard self.value == newValue else {
            return
          }
          self.value = self.defaultValue
        }
      }
    }
  }

  public init(defaultValue: Value, autoReverseInterval: TimeInterval) {
    self.defaultValue = defaultValue
    self.autoReverseInterval = autoReverseInterval
    self._value = State(initialValue: defaultValue)
  }

  public mutating func update() {
    self._value.update()
  }
}

extension AutoReverseState {
  public init<OptionalValue: Equatable>(autoReverseInterval: TimeInterval)
  where Value == OptionalValue? {
    self.init(defaultValue: nil, autoReverseInterval: autoReverseInterval)
  }
}
