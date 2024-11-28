import Combine
import Foundation
import OrderedCollections
import UIKit

@MainActor
public final class InMemoryCache: Sendable {
  enum CacheEntry {
    case inProgress(Task<IconCache, Error>)
    case ready(IconCache)
  }

  let limit: Int
  private var cache: OrderedDictionary<String, CacheEntry> = [:]
  private var memoryWarningSubscription: AnyCancellable?

  init(limit: Int) {
    self.limit = limit

    memoryWarningSubscription = NotificationCenter.default
      .publisher(for: UIApplication.didReceiveMemoryWarningNotification)
      .sink { [weak self] _ in
        self?.performClear()
      }
  }

  subscript(_ key: String) -> CacheEntry? {
    get {
      cache[key]
    }
    set {
      if let newValue {
        if cache.count > limit {
          cache.remove(at: 0)
        }

        cache[key] = newValue
      } else {
        cache.removeValue(forKey: key)
      }
    }
  }

  func clear() {
    cache.removeAll()
  }

  func performClear() {
    clear()
  }
}
