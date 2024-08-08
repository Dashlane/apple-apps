import Foundation

class SemaphorePublisher<T> {
  private let semaphore: DispatchSemaphore
  private var value: T?

  init() {
    semaphore = DispatchSemaphore(value: 0)
  }

  func acquire() -> T {
    semaphore.wait()
    return value!
  }

  func publish(_ value: T) {
    self.value = value
    semaphore.signal()
  }

}
