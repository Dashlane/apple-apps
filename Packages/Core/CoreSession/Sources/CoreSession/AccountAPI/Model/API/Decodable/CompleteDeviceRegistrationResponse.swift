import DashTypes
import DashlaneAPI
import Foundation

public typealias CompleteDeviceRegistrationResponse = AppAPIClient.Authentication
  .CompleteDeviceRegistrationWithAuthTicket.Response

extension CompleteDeviceRegistrationResponse {

  public var analyticsIds: AnalyticsIdentifiers {
    return AnalyticsIdentifiers(device: deviceAnalyticsId, user: userAnalyticsId)
  }

}
