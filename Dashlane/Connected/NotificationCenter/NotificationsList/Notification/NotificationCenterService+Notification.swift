import Foundation

extension NotificationCenterService {
  public enum Notification {
    public enum State {
      case dismissed
      case seen
      case unseen

      var isDisplayable: Bool {
        return self != .dismissed
      }
    }

    case `static`(Static)
    case dynamic(Dynamic)

    public enum Static {
      case secureLock
      case trialPeriod
      case resetMasterPassword
      case frozenAccount
    }

    public enum Dynamic {
      case securityAlert(alert: UnresolvedAlert)
      case sharing(requestId: String, kind: SharingNotificationInfo.SharingNotificationKind)
    }
  }
}
