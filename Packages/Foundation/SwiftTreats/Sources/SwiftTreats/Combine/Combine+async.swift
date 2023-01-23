import Foundation
import Combine

public extension Future where Failure == Error {
        convenience init(operation: @escaping () async throws -> Output) {
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

public extension AsyncSequence {
        func publisher() -> PassthroughSubject<Element, Error> {
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

public extension Publisher {
                func asyncMap<T>(
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
