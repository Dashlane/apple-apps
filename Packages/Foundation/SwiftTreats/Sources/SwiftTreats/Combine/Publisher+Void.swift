import Combine
import Foundation

extension Publisher where Failure == Never {
  public func mapToVoid() -> AnyPublisher<Void, Never> {
    map { _ in Void() }.eraseToAnyPublisher()
  }
}
