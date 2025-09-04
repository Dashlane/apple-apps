import Foundation

public enum AccessControlReason: Sendable {
  case unlockItems(count: Int)
  case lockOnExit
  case changeContactEmail
  case changePincode
  case authenticationSetup
  case addNewDevice
  case export
  case changeLoginEmail

  public static var unlockItem: AccessControlReason { .unlockItems(count: 1) }
}
