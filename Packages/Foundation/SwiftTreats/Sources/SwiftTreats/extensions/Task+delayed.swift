import Foundation

extension Task where Failure == Error {
  @discardableResult
  public static func delayed(
    by duration: Duration,
    priority: TaskPriority? = nil,
    @_implicitSelfCapture operation: @escaping @Sendable () async throws -> Success
  ) -> Task {
    Task(priority: priority) {
      try await Task<Never, Never>.sleep(for: duration)
      return try await operation()
    }
  }
}
