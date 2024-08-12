import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation

public protocol HomeAnnouncementsServicesContainer: DependenciesContainer {
  var login: Login { get }
  var session: Session { get }
  var announcementsActivityReporter: ActivityReporterProtocol { get }
  var rootLogger: Logger { get }
  var syncedSettings: SyncedSettingsService { get }
  var productInfoUpdater: ProductInfoUpdater { get }
  var deepLinkingService: NotificationKitDeepLinkingServiceProtocol { get }
  var brazeServiceProtocol: BrazeServiceProtocol { get }
  var capabilityService: CapabilityServiceProtocol { get }
  var userDeviceAPIClient: UserDeviceAPIClient { get }

  var premiumStatusProvider: PremiumStatusProvider { get }
  var userSettings: UserSettings { get }
  var notificationKitAutofillService: NotificationKitAutofillServiceProtocol { get }
  var notificationKitFeatureService: FeatureServiceProtocol { get }
  var itemsLimitNotificationProvider: ItemsLimitNotificationProvider { get }
}
