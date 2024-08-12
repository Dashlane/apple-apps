import Foundation

public actor AsyncCache<CacheKey: Hashable, Output> {
  private enum Cache {
    case pending(Task<Output, Never>)
    case ready(Output)
  }

  private var storage: [CacheKey: Cache] = [:]

  public init() {

  }

  public func value(
    for key: CacheKey, using taskProvider: @Sendable @escaping () -> Task<Output, Never>
  ) async -> Output {
    let cache = storage[key]
    switch cache {
    case let .ready(result):
      return result
    case let .pending(task):
      return await task.value
    case nil:
      let task = taskProvider()
      self.storage[key] = .pending(task)
      let value = await task.value
      self.storage[key] = .ready(value)
      return value
    }
  }

  public func clearCache() {
    for case let Cache.pending(task)? in storage.values {
      task.cancel()
    }
    storage.removeAll()
  }
}
