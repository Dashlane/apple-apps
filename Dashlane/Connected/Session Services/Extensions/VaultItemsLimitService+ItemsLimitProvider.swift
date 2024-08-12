import Combine
import Foundation
import NotificationKit
import VaultKit

extension VaultItemsLimitService: ItemsLimitNotificationProvider {
  public func passwordLimitPublisher() -> AnyPublisher<ItemsLimit?, Never> {
    self.credentialsLimitPublisher
      .map { limit -> ItemsLimit? in
        switch limit {
        case .limited:
          return .limited
        case let .reachingLimit(count, limit):
          return .nearlyLimited(remaining: limit - count)
        case .unlimited:
          return nil
        }
      }.eraseToAnyPublisher()
  }
}
