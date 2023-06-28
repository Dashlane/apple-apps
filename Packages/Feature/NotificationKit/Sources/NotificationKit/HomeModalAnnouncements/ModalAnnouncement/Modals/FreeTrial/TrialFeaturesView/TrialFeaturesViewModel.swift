import UIDelight
import SwiftTreats
import CoreUserTracking
import UIComponents
import DesignSystem
import CoreLocalization
import CorePremium

public struct TrialFeaturesViewModel: HomeAnnouncementsServicesInjecting {

    let capabilityService: CapabilityServiceProtocol
    let deepLinkingService: NotificationKitDeepLinkingServiceProtocol
    let activityReporter: ActivityReporterProtocol

    public init(capabilityService: CapabilityServiceProtocol,
                deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
                activityReporter: ActivityReporterProtocol) {
        self.capabilityService = capabilityService
        self.deepLinkingService = deepLinkingService
        self.activityReporter = activityReporter
    }
}

extension TrialFeaturesViewModel {
    static var mock: TrialFeaturesViewModel {
        .init(capabilityService: .mock(),
              deepLinkingService: NotificationKitDeepLinkingServiceMock(),
              activityReporter: .fake)
    }
}
