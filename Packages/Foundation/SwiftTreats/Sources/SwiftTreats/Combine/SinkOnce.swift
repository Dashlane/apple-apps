import Foundation
import Combine

private class EphemeralSubscription {
    var subscription: AnyCancellable?
}

public extension Publisher where Failure == Never {
            func sinkOnce(receiveValue: @escaping (Output) -> Void) {
        let ephemeralSubscription = EphemeralSubscription()

        ephemeralSubscription.subscription = first().sink { value in
            ephemeralSubscription.subscription?.cancel()
            ephemeralSubscription.subscription = nil
            receiveValue(value)
        }
    }
}
