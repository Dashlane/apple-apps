import Foundation
import CoreSession

public enum PostLogoutAction {
    case startNewSession(Session, reason: SessionServicesUnloadReason)
    case deleteCurrentSessionLocalData
    case deleteLocalData(for: Session)
}

public protocol SessionLifeCycleHandler: AnyObject {
    var sessionState: SessionState { get }

    func automaticLogout()
    func logout(clearAutoLoginData: Bool)
    func logoutAndPerform(action: PostLogoutAction)
}

public enum SessionState {
    case disconnected
    case connected(isLocked: Bool)

    public var isContentVisible: Bool {
        switch self {
            case .disconnected:
                return false
            case let .connected(isLocked: isLocked):
                return !isLocked
        }
    }
}

public class FakeSessionLifeCycleHandler: SessionLifeCycleHandler {

    public init() {}
    public var sessionState: SessionState = .disconnected

    public func automaticLogout() {

    }

    public func logout(clearAutoLoginData: Bool) {

    }

    public func logoutAndPerform(action: PostLogoutAction) {

    }

}
