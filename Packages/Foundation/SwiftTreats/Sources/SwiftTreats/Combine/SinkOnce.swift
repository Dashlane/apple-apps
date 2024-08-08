import Combine
import Foundation

private class EphemeralSubscription {
  var subscription: AnyCancellable?
}

extension Publisher where Failure == Never {
  public func sinkOnce(receiveValue: @escaping (Output) -> Void) {
    let ephemeralSubscription = EphemeralSubscription()

    ephemeralSubscription.subscription = first().sink { value in
      ephemeralSubscription.subscription?.cancel()
      ephemeralSubscription.subscription = nil
      receiveValue(value)
    }
  }
}
