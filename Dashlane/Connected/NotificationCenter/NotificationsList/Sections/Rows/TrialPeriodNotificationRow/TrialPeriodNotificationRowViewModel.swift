import Foundation
import CoreFeature
import DashTypes
import CoreUserTracking
import CorePremium
import NotificationKit

class TrialPeriodNotificationRowViewModel: ObservableObject, SessionServicesInjecting {
    let notification: DashlaneNotification
    let capabilityService: CapabilityServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let deepLinkingService: NotificationKitDeepLinkingServiceProtocol

    @Published
    var showTrialFeatureView: Bool = false

    init(notification: DashlaneNotification,
         capabilityService: CapabilityServiceProtocol,
         deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
         activityReporter: ActivityReporterProtocol) {
        self.notification = notification
        self.deepLinkingService = deepLinkingService
        self.capabilityService = capabilityService
        self.activityReporter = activityReporter
    }
}

extension TrialPeriodNotificationRowViewModel {
    static var mock: TrialPeriodNotificationRowViewModel {
        .init(notification: TrialPeriodNotification(state: .seen,
                                                    creationDate: Date(),
                                                    notificationActionHandler: NotificationSettings.mock),
              capabilityService: .mock(),
              deepLinkingService: NotificationKitDeepLinkingServiceMock(),
              activityReporter: .fake)
    }
}
