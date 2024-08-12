import Foundation

struct TimedOutError: Error {

}

public func withTimeout<Result>(
  _ interval: TimeInterval,
  operation: @escaping @Sendable () async throws -> Result
) async throws -> Result {
  return try await withThrowingTaskGroup(of: Result.self) { group in
    group.addTask {
      return try await operation()
    }

    group.addTask {
      if interval > 0 {
        try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
      }
      try Task.checkCancellation()
      throw TimedOutError()
    }

    let result = try await group.next()!
    group.cancelAll()

    return result
  }
}
