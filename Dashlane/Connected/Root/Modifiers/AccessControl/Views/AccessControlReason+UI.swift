import CoreLocalization
import CoreUserTracking
import DashTypes
import Foundation

extension AccessControlReason {
  var logReason: Definition.Reason {
    switch self {
    case .unlockItem:
      return .unlockItem
    case .lockOnExit, .changeContactEmail, .changePincode:
      return .editSettings
    }
  }

  var promptMessage: String {
    switch self {
    case .unlockItem:
      return L10n.Localizable.itemAccessUnlockPrompt
    case .lockOnExit:
      return L10n.Localizable.kwLockOnExit
    case .changeContactEmail:
      return L10n.Localizable.changeContactEmailPrompt
    case .changePincode:
      return CoreLocalization.L10n.Core.unlockDashlane
    }
  }
}
