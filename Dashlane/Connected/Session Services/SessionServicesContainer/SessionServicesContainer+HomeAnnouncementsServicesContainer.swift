import Foundation
import NotificationKit
import DashTypes
import CoreUserTracking
import CorePremium
import CoreSettings
import CoreFeature

extension SessionServicesContainer: HomeAnnouncementsServicesContainer {
    var login: DashTypes.Login { session.login }

        var announcementsActivityReporter: CoreUserTracking.ActivityReporterProtocol {
        return activityReporter
    }

        var announcementsPremiumService: CorePremium.PremiumServiceProtocol {
        self.premiumService
    }

    var deepLinkingService: NotificationKit.NotificationKitDeepLinkingServiceProtocol { self.appServices.deepLinkingService }
    var brazeServiceProtocol: BrazeServiceProtocol { self.appServices.brazeService }

    var userSettings: CoreSettings.UserSettings { spiegelUserSettings }

    var notificationKitAutofillService: NotificationKit.NotificationKitAutofillServiceProtocol { autofillService }

    var abTestingService: CoreFeature.ABTestingServiceProtocol { authenticatedABTestingService }
}
