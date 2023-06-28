import CoreFeature
import CorePremium
import Foundation
import VaultKit

extension SessionServicesContainer: VaultKitServicesContainer {
    var vaultKitFeatureService: CoreFeature.FeatureServiceProtocol { featureService }
    var vaultKitPremiumService: CorePremium.PremiumServiceProtocol { premiumService }
    var vaultKitTeamSpacesServiceProcotol: VaultKit.TeamSpacesServiceProtocol { teamSpacesService }
    var vaultKitDeepLinkingService: VaultKit.DeepLinkingServiceProtocol { appServices.deepLinkingService }
}
