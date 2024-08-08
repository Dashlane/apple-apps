import Combine
import Foundation

extension Publisher {
  public func combineLatest<Others: Collection>(with others: Others)
    -> AnyPublisher<[Output], Failure>
  where
    Others.Element: Publisher, Others.Element.Output == Output, Others.Element.Failure == Failure
  {
    let seed = map { [$0] }.eraseToAnyPublisher()

    return others.reduce(seed) { combined, next in
      combined
        .combineLatest(next)
        .map { $0 + [$1] }
        .eraseToAnyPublisher()
    }
  }

  public func combineLatest<Other: Publisher>(with others: Other...)
    -> AnyPublisher<[Output], Failure>
  where Other.Output == Output, Other.Failure == Failure {
    combineLatest(with: others)
  }
}

extension Collection where Element: Publisher {
  public func combineLatest() -> AnyPublisher<[Element.Output], Element.Failure> {
    switch count {
    case 0:
      return Empty().eraseToAnyPublisher()
    case 1:
      return self[startIndex]
        .combineLatest(with: [Element]())
    default:
      let first = self[startIndex]
      let others = self[index(after: startIndex)...]

      return
        first
        .combineLatest(with: others)
    }
  }
}
