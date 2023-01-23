import Foundation

public actor AsyncSerialQueue: AsyncQueue {
    typealias Operation = @Sendable () async throws -> Void
    private var pendingOperations: [Operation] = []
    
    public init() {
  
    }

    public nonisolated func callAsFunction<Output>(_ operation: @escaping @Sendable () async throws -> Output) async throws -> Output {
        try await withUnsafeThrowingContinuation { continuation in
            Task {
                await add {
                    do {
                        let output = try await operation()
                        continuation.resume(returning: output)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
         }
    }
    
    private func add(_ operation: @escaping Operation)  {
        pendingOperations.append(operation)
                if pendingOperations.count == 1 {
            consumeNextOperation()
        }
    }

    private func consumeNextOperation() {
        guard let operation = pendingOperations.first else {
            return
        }

        Task.detached {
            try? await operation()
            await self.clearCurrentAndConsumeNextOperation()
        }
    }
    
    private func clearCurrentAndConsumeNextOperation() {
        pendingOperations.remove(at: 0)
        consumeNextOperation()
    }
}
