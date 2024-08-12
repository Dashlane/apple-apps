import Combine
import Foundation

extension Publisher {
  public func shareReplayLatest() -> AnyPublisher<Output, Failure> {
    return
      self
      .map { Optional.some($0) }
      .multicast { CurrentValueSubject<Output?, Failure>(nil) }
      .autoconnect()
      .compactMap { $0 }
      .eraseToAnyPublisher()
  }
}
