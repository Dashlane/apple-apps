import Foundation
import CorePremium
import SecurityDashboard
import DashlaneAppKit
import CoreFeature

class BreachAlertsInfoProvider: SecurityDashboard.BreachesManagerAlertsInfoProvider {
    let premiumService: PremiumService
    let featureService: FeatureServiceProtocol

    init(premiumService: PremiumService, featureService: FeatureServiceProtocol) {
        self.premiumService = premiumService
        self.featureService = featureService
    }

    var requestInformation: AlertGenerator.RequestInformation {
        let format = AlertFormat(hiddenDataLeakForFreeUsersEnabled: isFreeUserHiddenAlertsFeatureEnabled)
        return AlertGenerator.RequestInformation(format: format, premiumInformation: premiumService)
    }

    private var isFreeUserHiddenAlertsFeatureEnabled: Bool {
        return premiumService.areDarkWebAlertsHidden
    }
}
