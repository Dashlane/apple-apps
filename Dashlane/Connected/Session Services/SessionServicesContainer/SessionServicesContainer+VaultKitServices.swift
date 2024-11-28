import CoreFeature
import CorePremium
import CoreSettings
import DashTypes
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
  var vaultKitAccessControl: AccessControlHandler { accessControlService }
  var vaultKitPasteboardService: PasteboardServiceProtocol { pasteboardService }
  var vaultKitUserSettings: UserSettings { userSettings }
  var vaultKitVaultStateService: VaultStateServiceProtocol { vaultStateService }
}
