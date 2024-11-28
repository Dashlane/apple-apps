import Combine
import CoreSession
import DashTypes
import Foundation

public enum ApplicationLocker {
  case automaticLogout(SessionInactivityAutomaticLogout)
  case screenLock(ScreenLocker)
}

extension ApplicationLocker {
  var screenLocker: ScreenLocker? {
    switch self {
    case let .screenLock(locker):
      return locker
    default:
      return nil
    }
  }
}

extension ApplicationLocker {
  var unlockedPublisher: any Publisher<Void, Never> {
    switch self {
    case let .screenLock(locker):
      return locker.$lock.filter { $0 == nil }.mapToVoid()
    case let .automaticLogout(activity):
      return activity.unlockedSessionPublisher
    }
  }

  var screenLockedPublisher: AnyPublisher<Void, Never> {
    switch self {
    case let .screenLock(locker):
      return locker.$lock.filter { $0 != nil }.mapToVoid()
    case .automaticLogout:
      return Empty().eraseToAnyPublisher()
    }
  }

  func didLoadSession() {
    switch self {
    case .screenLock:
      return
    case let .automaticLogout(activity):
      activity.didLoadSession()
    }
  }
}
