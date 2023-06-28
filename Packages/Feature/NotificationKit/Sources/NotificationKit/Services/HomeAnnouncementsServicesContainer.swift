import Foundation
import DashTypes
import CoreSession
import CoreUserTracking
import CorePremium
import CoreSettings
import CorePersonalData
import CoreFeature

public protocol HomeAnnouncementsServicesContainer: DependenciesContainer {
    var login: Login { get }
    var session: Session { get }
        var announcementsActivityReporter: ActivityReporterProtocol { get }
    var rootLogger: Logger { get }
    var syncedSettings: SyncedSettingsService { get }
        var announcementsPremiumService: PremiumServiceProtocol { get }
    var deepLinkingService: NotificationKitDeepLinkingServiceProtocol { get }
    var brazeServiceProtocol: BrazeServiceProtocol { get }
    var capabilityService: CapabilityServiceProtocol { get }
    var userSettings: UserSettings { get }
    var notificationKitAutofillService: NotificationKitAutofillServiceProtocol { get }
    var notificationKitFeatureService: FeatureServiceProtocol { get }
}
