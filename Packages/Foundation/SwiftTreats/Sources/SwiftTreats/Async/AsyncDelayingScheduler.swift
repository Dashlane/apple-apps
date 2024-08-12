import Foundation

public actor AsyncDelayingScheduler {

  public enum Policy {
    case throttle(latest: Bool)
    case debounce
  }

  private let policy: Policy
  private let duration: TimeInterval
  private var task: Task<Void, Error>?
  private var lastOperation: (() async throws -> Void)?

  public init(policy: Policy, duration: TimeInterval) {
    self.policy = policy
    self.duration = duration
  }

  public func callAsFunction(operation: @escaping () async throws -> Void) {
    switch policy {
    case let .throttle(latest):
      if latest {
        throttleKeepLast(operation: operation)
      } else {
        throttleKeepFirst(operation: operation)
      }
    case .debounce:
      debounce(operation: operation)
    }
  }

  public func cancel() {
    task = nil
    lastOperation = nil
  }
}

extension AsyncDelayingScheduler {
  fileprivate func throttleKeepFirst(operation: @escaping () async throws -> Void) {
    guard task == nil else { return }

    task = Task {
      try? await sleep()
      try await operation()
      task = nil
    }
  }

  fileprivate func throttleKeepLast(operation: @escaping () async throws -> Void) {
    lastOperation = operation
    guard task == nil else { return }

    task = Task {
      try? await sleep()
      try await lastOperation.unwrapped()
      task = nil
    }
  }

  fileprivate func debounce(operation: @escaping () async throws -> Void) {
    task?.cancel()

    task = Task {
      try await sleep()
      try await operation()
      task = nil
    }
  }

  fileprivate func sleep() async throws {
    try await Task.sleep(nanoseconds: UInt64(duration * .nanosecondsPerSecond))
  }
}

extension TimeInterval {
  static let nanosecondsPerSecond = TimeInterval(NSEC_PER_SEC)
}
