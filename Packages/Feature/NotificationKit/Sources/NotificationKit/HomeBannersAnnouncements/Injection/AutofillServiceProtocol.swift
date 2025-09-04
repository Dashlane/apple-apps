import Combine
import CoreTypes
import Foundation

public protocol NotificationKitAutofillServiceProtocol {
  var notificationKitActivationStatus: Published<AutofillActivationStatus>.Publisher { get }
}

public class FakeNotificationKitAutofillService: NotificationKitAutofillServiceProtocol {
  @Published
  public var status: AutofillActivationStatus = .unknown

  public var notificationKitActivationStatus: Published<AutofillActivationStatus>.Publisher {
    $status
  }
}
