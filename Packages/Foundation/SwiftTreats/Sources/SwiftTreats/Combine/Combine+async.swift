import Combine
import Foundation

extension Future where Failure == Error {
  public convenience init(operation: @escaping () async throws -> Output) {
    self.init { promise in
      Task {
        do {
          let output = try await operation()
          promise(.success(output))
        } catch {
          promise(.failure(error))
        }
      }
    }
  }
}

extension AsyncSequence {
  public func publisher<ArrayElement>() -> CurrentValueSubject<Element, Error>
  where Element == [ArrayElement] {
    let subject = CurrentValueSubject<Element, Error>([])
    Task {
      do {
        for try await value in self {
          subject.send(value)
        }

        subject.send(completion: .finished)
      } catch {
        subject.send(completion: .failure(error))
      }
    }

    return subject
  }

  public func publisher<OptionalValue>() -> PassthroughSubject<Element, Error>
  where Element == OptionalValue? {
    let subject = PassthroughSubject<Element, Error>()
    Task {
      do {
        for try await value in self {
          subject.send(value)
        }

        subject.send(completion: .finished)
      } catch {
        subject.send(completion: .failure(error))
      }
    }

    return subject
  }
}

extension Publisher {
  public func asyncMap<T>(
    _ transform: @escaping (Output) async -> T
  ) -> Publishers.FlatMap<Future<T, Never>, Self> {
    flatMap { value in
      Future { promise in
        Task {
          let output = await transform(value)
          promise(.success(output))
        }
      }
    }
  }
}
