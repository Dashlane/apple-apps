import CoreLocalization
import CorePremium
import CoreUserTracking
import DesignSystem
import SwiftTreats
import UIComponents
import UIDelight

public struct TrialFeaturesViewModel: HomeAnnouncementsServicesInjecting {

  let deepLinkingService: NotificationKitDeepLinkingServiceProtocol
  let activityReporter: ActivityReporterProtocol

  public init(
    capabilityService: CapabilityServiceProtocol,
    deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol
  ) {
    self.deepLinkingService = deepLinkingService
    self.activityReporter = activityReporter
  }
}

extension TrialFeaturesViewModel {
  static var mock: TrialFeaturesViewModel {
    .init(
      capabilityService: .mock(),
      deepLinkingService: NotificationKitDeepLinkingServiceMock(),
      activityReporter: .mock)
  }
}
