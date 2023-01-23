import Foundation
import Combine

public extension Publisher where Failure == Never {
        func mapToVoid() -> AnyPublisher<Void, Never> {
        map { _ in Void() }.eraseToAnyPublisher()
    }
}
