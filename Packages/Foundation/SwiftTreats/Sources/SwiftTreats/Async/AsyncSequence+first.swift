import Foundation

extension AsyncSequence {
    public func first() async throws -> Self.Element? {
        for try await element in self {
            return element
        }

        return nil
    }
}
