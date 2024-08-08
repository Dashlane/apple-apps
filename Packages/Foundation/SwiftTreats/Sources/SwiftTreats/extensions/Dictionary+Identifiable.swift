import Foundation

extension Dictionary where Value: Identifiable, Key == Value.ID {
  public init<C: Collection>(values: C) where C.Element == Value {
    self.init(minimumCapacity: values.count)

    for value in values {
      self[value.id] = value
    }
  }
}
