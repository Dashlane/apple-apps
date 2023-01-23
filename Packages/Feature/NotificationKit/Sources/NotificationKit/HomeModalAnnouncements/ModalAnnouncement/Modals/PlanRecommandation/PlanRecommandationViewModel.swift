import Foundation
import CoreUserTracking
import CoreLocalization
import CoreSettings

public struct PlanRecommandationViewModel: HomeAnnouncementsServicesInjecting {

    enum PlanRecommandation {
        case premium
    }

    let recommandedPlan: PlanRecommandation = .premium
    private let deepLinkingService: NotificationKitDeepLinkingServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let userSettings: UserSettings

    public init(deepLinkingService: NotificationKitDeepLinkingServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                userSettings: UserSettings) {
        self.deepLinkingService = deepLinkingService
        self.activityReporter = activityReporter
        self.userSettings = userSettings
    }

    func learnMore() {
        deepLinkingService.handle(.goToPremium)
        activityReporter.report(UserEvent.CallToAction(callToActionList: [userTrackingRecommandedCallToAction], chosenAction: userTrackingRecommandedCallToAction, hasChosenNoAction: false))
    }

    func cancelAction() {
        activityReporter.report(UserEvent.CallToAction(callToActionList: [userTrackingRecommandedCallToAction], hasChosenNoAction: true))
    }

    private var userTrackingRecommandedCallToAction: Definition.CallToAction {
        switch recommandedPlan {
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
        .init(deepLinkingService: NotificationKitDeepLinkingServiceMock(),
              activityReporter: .fake,
              userSettings: .mock)
    }
}
