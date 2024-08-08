import Foundation

@propertyWrapper
public final class Atomic<T>: @unchecked Sendable {
  let queue: DispatchQueue
  var value: T

  public init(wrappedValue: T, file: StaticString = #file, line: Int = #line) {
    value = wrappedValue
    queue = DispatchQueue(label: "com.dashlane.atomic.\(file).\(line)")
  }

  public var wrappedValue: T {
    get {
      queue.sync {
        value
      }
    }
    set {
      queue.sync {
        self.value = newValue
      }
    }
  }
}
