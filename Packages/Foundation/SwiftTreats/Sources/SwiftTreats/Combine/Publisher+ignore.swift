import Foundation
import Combine

public extension Publisher {
        func ignoreError() -> AnyPublisher<Output, Never> {
        self.map { Optional($0) }
            .replaceError(with: nil)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}
