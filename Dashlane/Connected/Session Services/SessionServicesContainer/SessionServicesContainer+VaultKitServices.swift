import CoreFeature
import CorePremium
import CoreSettings
import Foundation
import VaultKit

extension SessionServicesContainer: VaultKitServicesContainer {
  var vaultKitFeatureService: CoreFeature.FeatureServiceProtocol { featureService }
  var userSpacesService: UserSpacesService { premiumStatusServicesSuit.userSpacesService }
  var vaultKitDeepLinkingService: VaultKit.DeepLinkingServiceProtocol {
    appServices.deepLinkingService
  }
  var vaultKitSharingServiceHandler: SharedVaultHandling { sharingService }
  var vaultKitSharingService: SharingServiceProtocol { sharingService }
  var vaultKitAccessControl: AccessControlProtocol { accessControl }
  var vaultKitPasteboardService: PasteboardServiceProtocol { pasteboardService }
  var vaultKitUserSettings: UserSettings { userSettings }
}
