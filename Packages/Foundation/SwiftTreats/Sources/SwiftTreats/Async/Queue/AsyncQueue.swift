import Foundation

public protocol AsyncQueue {
  func callAsFunction<Output>(_ operation: @Sendable @escaping () async throws -> Output)
    async throws -> Output
}
