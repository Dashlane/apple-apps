import Foundation
import DashTypes
import DashlaneAPI

public typealias CompleteDeviceRegistrationResponse = AppAPIClient.Authentication.CompleteDeviceRegistrationWithAuthTicket.Response

public extension CompleteDeviceRegistrationResponse {

    var analyticsIds: AnalyticsIdentifiers {
        return AnalyticsIdentifiers(device: deviceAnalyticsId, user: userAnalyticsId)
    }

}
