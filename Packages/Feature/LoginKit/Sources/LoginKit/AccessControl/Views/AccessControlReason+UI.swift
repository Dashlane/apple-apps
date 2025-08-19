import CoreLocalization
import CoreTypes
import Foundation
import UserTrackingFoundation

extension AccessControlReason {
  var logReason: Definition.Reason {
    switch self {
    case .unlockItems:
      return .unlockItem
    case .lockOnExit, .changeContactEmail, .changePincode, .authenticationSetup, .changeLoginEmail:
      return .editSettings
    case .addNewDevice:
      return .login
    case .export:
      return .unlockItem
    }
  }

  var promptMessage: String {
    switch self {
    case .unlockItems(count: 1):
      return CoreL10n.itemAccessUnlockPrompt
    case .lockOnExit:
      return CoreL10n.kwLockOnExit
    case .changeContactEmail:
      return CoreL10n.changeContactEmailPrompt
    case .changePincode, .authenticationSetup, .addNewDevice, .export, .unlockItems,
      .changeLoginEmail:
      return CoreL10n.unlockDashlane
    }
  }
}
