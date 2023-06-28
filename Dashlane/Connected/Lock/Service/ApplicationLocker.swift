import Foundation
import DashTypes
import Combine
import CoreSession

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
    var unlocked: any Publisher<Void, Never> {
        switch self {
        case let .screenLock(locker):
            return locker.$lock.mapToVoid()
        case let .automaticLogout(activity):
            return activity.unlockedSessionPublisher
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
