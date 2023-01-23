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
