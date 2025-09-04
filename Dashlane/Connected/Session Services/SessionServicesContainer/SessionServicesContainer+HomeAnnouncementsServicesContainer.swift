import AutofillKit
import Combine
import CoreFeature
import CorePremium
import CoreSettings
import CoreTypes
import Foundation
import LoginKit
import NotificationKit
import UserTrackingFoundation

extension SessionServicesContainer: HomeAnnouncementsServicesContainer {

  var capabilityService: CorePremium.CapabilityServiceProtocol {
    premiumStatusServicesSuit.capabilityService
  }

  var premiumStatusProvider: CorePremium.PremiumStatusProvider {
    premiumStatusServicesSuit.statusProvider
  }

  var login: CoreTypes.Login { session.login }

  var announcementsActivityReporter: UserTrackingFoundation.ActivityReporterProtocol {
    return activityReporter
  }

  var productInfoUpdater: ProductInfoUpdater {
    self.appStoreServicesSuit.productInfoUpdater
  }

  var deepLinkingService: NotificationKit.NotificationKitDeepLinkingServiceProtocol {
    self.appServices.deepLinkingService
  }
  var brazeServiceProtocol: BrazeServiceProtocol { self.appServices.brazeService }

  var userSettings: CoreSettings.UserSettings { spiegelUserSettings }

  var notificationKitAutofillService: NotificationKit.NotificationKitAutofillServiceProtocol {
    autofillService
  }

  var notificationKitFeatureService: CoreFeature.FeatureServiceProtocol { featureService }

  var notificationKitVaultStateService: VaultStateServiceProtocol { vaultStateService }

  var notificationKitTeamSpaceService: CorePremium.UserSpacesService { userSpacesService }

  var itemsLimitNotificationProvider: NotificationKit.ItemsLimitNotificationProvider {
    vaultServicesSuit.vaultItemsLimitService
  }
}

extension AutofillStateService: NotificationKit.NotificationKitAutofillServiceProtocol {
  public var notificationKitActivationStatus: Published<AutofillActivationStatus>.Publisher {
    $activationStatus
  }
}
