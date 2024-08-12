import CoreLocalization
import CoreSettings
import CoreUserTracking
import Foundation

public struct PlanRecommandationViewModel: HomeAnnouncementsServicesInjecting {

  enum PlanRecommandation {
    case premium
  }

  let recommendedPlan: PlanRecommandation = .premium
  private let deepLinkingService: NotificationKitDeepLinkingServiceProtocol
  private let activityReporter: ActivityReporterProtocol
  private let userSettings: UserSettings

  public init(
    deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
    activityReporter: ActivityReporterProtocol,
    userSettings: UserSettings
  ) {
    self.deepLinkingService = deepLinkingService
    self.activityReporter = activityReporter
    self.userSettings = userSettings
  }

  func learnMore() {
    deepLinkingService.handle(.goToPremium)
    activityReporter.report(
      UserEvent.CallToAction(
        callToActionList: [userTrackingRecommendedCallToAction],
        chosenAction: userTrackingRecommendedCallToAction, hasChosenNoAction: false))
  }

  func cancelAction() {
    activityReporter.report(
      UserEvent.CallToAction(
        callToActionList: [userTrackingRecommendedCallToAction], hasChosenNoAction: true))
  }

  private var userTrackingRecommendedCallToAction: Definition.CallToAction {
    switch recommendedPlan {
    case .premium:
      return .premiumOffer
    }
  }

  func markPlanRecommandationHasBeenShown() {
    userSettings[.planRecommandationHasBeenShown] = true
  }
}

extension PlanRecommandationViewModel {
  static var mock: PlanRecommandationViewModel {
    .init(
      deepLinkingService: NotificationKitDeepLinkingServiceMock(),
      activityReporter: .mock,
      userSettings: .mock)
  }
}
