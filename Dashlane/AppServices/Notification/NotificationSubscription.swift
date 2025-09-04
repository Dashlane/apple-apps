import Combine
import CoreTypes
import Foundation

struct NotificationSubscription<Notification: NotificationInfoContainer, Output>: Hashable {
  static func == (
    lhs: NotificationSubscription<Notification, Output>,
    rhs: NotificationSubscription<Notification, Output>
  ) -> Bool {
    return lhs.id == rhs.id
  }

  private let id = UUID()
  let predicate: NotificationPredicate<Notification>
  let publisher = PassthroughSubject<Output, Never>()

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension Collection {
  func first<N: NotificationInfoContainer, Output>(for notification: N) -> Element?
  where Element == NotificationSubscription<N, Output> {
    return self.first {
      notification.isConform(to: $0.predicate)
    }
  }
}

enum NotificationPredicate<Notification: NotificationInfoContainer> {
  case code(_ code: NotificationCode)
  case name(_ name: NotificationName)
  case custom(_ custom: ((Notification) -> Bool))
}

extension NotificationInfoContainer {
  func isConform(to predicate: NotificationPredicate<Self>) -> Bool {
    switch predicate {
    case let .code(code):
      return self.hasCode(code)
    case let .name(name):
      return self.hasName(name)
    case let .custom(predicate):
      return predicate(self)
    }
  }
}
